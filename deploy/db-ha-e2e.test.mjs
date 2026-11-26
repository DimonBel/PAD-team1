// End to end (Lab 5): replication and failover of the services' databases, each a Patroni cluster of
// a leader and two streaming replicas behind an HAProxy router (db-replication/README.md). Every
// cluster's state is checked read-only; exam-db and world-db are also written to and failed over
// under load through exam-service and world-service.
//
//   node --test --test-concurrency=1 deploy/db-ha-e2e.test.mjs
//
// Prerequisites: `docker compose up -d` in this folder. Reads the secrets it needs from .env. It
// kills database nodes and starts them again, and leaves every node running at the end. Takes a few
// minutes (each failover ~20-30 s). COMPOSE_PROJECT overrides the compose project name.

import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { createHmac, randomBytes, randomUUID } from "node:crypto";
import { readFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { after, before, describe, it } from "node:test";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const PROJECT = process.env.COMPOSE_PROJECT ?? basename(ROOT).toLowerCase();
const GATEWAY = process.env.GATEWAY_URL ?? "http://localhost:8080";

function env(name, fallback = "") {
  if (process.env[name]) return process.env[name];
  try {
    const line = readFileSync(join(ROOT, ".env"), "utf8").split(/\r?\n/).findLast((l) => new RegExp(`^\\s*${name}\\s*=`).test(l));
    return line ? line.replace(/^[^=]*=\s*/, "").trim().replace(/^"|"$/g, "") : fallback;
  } catch {
    return fallback;
  }
}

const CLUSTERS = ["base", "crafting", "world", "exam", "zombie", "resource", "player", "game"];
const DB = Object.fromEntries(CLUSTERS.map((c) => [c, env(`${c.toUpperCase()}_DB_NAME`, `${c}_service`)]));
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const log = (...args) => console.log("   ", ...args);

// A stalled `docker compose exec` is killed after 30 s and asked again by the helpers below;
// stopping and starting containers waits for them, so those get 3 minutes.
const docker = (...args) =>
  execFileSync("docker", args, {
    cwd: ROOT,
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
    timeout: args.includes("start") || args.includes("kill") ? 180_000 : 30_000,
  });
const compose = (...args) => docker("compose", "-p", PROJECT, ...args);

function retried(fn) {
  let error;
  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      return fn();
    } catch (e) {
      error = e;
    }
  }
  throw error;
}

/** SQL on one node, as postgres over the local socket (trust inside the container). */
const psql = (node, cluster, sql) =>
  retried(() => compose("exec", "-T", node, "psql", "-U", "postgres", "-d", DB[cluster], "-v", "ON_ERROR_STOP=1", "-tAc", sql).trim());

/** `patronictl list` as JSON, asked of any node that answers. */
function members(cluster) {
  for (const n of [1, 2, 3]) {
    try {
      return JSON.parse(compose("exec", "-T", `${cluster}-db-${n}`, "patronictl", "-c", "/etc/patroni/patroni.yml", "list", "-f", "json"));
    } catch {}
  }
  throw new Error(`no ${cluster} node answers patronictl`);
}
const leaderOf = (cluster) => members(cluster).find((m) => m.Role === "Leader" && m.State === "running")?.Member;

async function until(what, check, ms = 90_000, every = 1_000) {
  const end = Date.now() + ms;
  let last;
  while (Date.now() < end) {
    try {
      last = await check();
      if (last) return last;
    } catch (error) {
      last = error.message;
    }
    await sleep(every);
  }
  throw new Error(`timed out waiting for ${what} (last: ${typeof last === "string" ? last : JSON.stringify(last)})`);
}

const b64 = (value) => Buffer.from(JSON.stringify(value)).toString("base64url");
function jwt(secret, claims) {
  const now = Math.floor(Date.now() / 1000);
  const head = `${b64({ alg: "HS256", typ: "JWT" })}.${b64({ iat: now, exp: now + 3600, ...claims })}`;
  return `${head}.${createHmac("sha256", secret).update(head).digest("base64url")}`;
}
const MODERATOR = () => jwt(env("JWT_SECRET"), { sub: randomUUID(), roles: ["player", "moderator"] });

async function call(method, url, { token, body, timeoutMs = 15_000 } = {}) {
  const res = await fetch(url, {
    method,
    headers: { ...(token ? { authorization: `Bearer ${token}` } : {}), ...(body !== undefined ? { "content-type": "application/json" } : {}) },
    body: body !== undefined ? JSON.stringify(body) : undefined,
    signal: AbortSignal.timeout(timeoutMs),
  });
  const text = await res.text();
  let json = null;
  try {
    json = JSON.parse(text);
  } catch {}
  return { status: res.status, body: json ?? text };
}

const tag = randomBytes(3).toString("hex");
let counter = 0;

// Each write goes through the Gateway to the service, so the service itself must survive the
// failover. Both take these writes from moderators only.
const createCourse = async () => {
  const id = `ha-course-${tag}-${++counter}`;
  const res = await call("POST", `${GATEWAY}/api/courses`, { token: MODERATOR(), body: { course_id: id, name: `HA ${id}` } });
  return { ok: res.status === 201, id, status: res.status };
};
const createZone = async () => {
  const res = await call("POST", `${GATEWAY}/api/world/zones`, { token: MODERATOR(), body: { name: `HA zone ${tag} ${++counter}` } });
  return { ok: res.status === 201, id: res.body?.zone_id, status: res.status };
};

/** Each service's write, and where its rows land: table and key column. */
const WRITES = {
  exam: { write: createCourse, table: "courses", key: "course_id" },
  world: { write: createZone, table: "zones", key: "id" },
};

/** Writes every `everyMs` until stopped; records each. */
function writer(write, everyMs = 250) {
  const results = [];
  let running = true;
  const done = (async () => {
    while (running) {
      const at = Date.now();
      try {
        results.push({ at, ...(await write()) });
      } catch (error) {
        results.push({ at, ok: false, error: error.message });
      }
      await sleep(everyMs);
    }
  })();
  return {
    results,
    stop: async () => {
      running = false;
      await done;
    },
  };
}

function failureWindow(results) {
  const failed = results.filter((r) => !r.ok);
  if (failed.length === 0) return "no failed writes";
  return `${failed.length} failed writes over ${((failed.at(-1).at - failed[0].at) / 1000).toFixed(1)} s`;
}

describe("every database: one leader and two streaming replicas (read-only checks)", { concurrency: 1 }, () => {
  for (const cluster of CLUSTERS) {
    it(`${cluster}-db: one leader and two streaming replicas, one of them synchronous, no lag; the replicas are read-only`, async () => {
      const list = await until(`${cluster} cluster healthy`, () => {
        const m = members(cluster);
        const streaming = m.filter((x) => x.State === "streaming");
        return m.filter((x) => x.Role === "Leader").length === 1 && streaming.length === 2 && m.some((x) => x.Role === "Sync Standby") ? m : null;
      });
      log(list.map((m) => `${m.Member}=${m.Role}/${m.State}/TL${m.TL}`).join("  "));
      assert.ok(list.filter((m) => m.Role !== "Leader").every((m) => Number(m["Lag in MB"] ?? 0) === 0));
      for (const m of list) {
        assert.equal(psql(m.Member, cluster, "SELECT pg_is_in_recovery()"), m.Role === "Leader" ? "f" : "t", `${m.Member} in recovery`);
      }
    });
  }
});

describe("exam-db and world-db: writes through the services, and failover under load", { concurrency: 1 }, () => {
  before(async () => {
    await until("the gateway", async () => (await call("GET", `${GATEWAY}/health`)).status === 200);
  });

  after(() => {
    // Whatever happened, leave every node running.
    for (const cluster of ["exam", "world"]) {
      for (const n of [1, 2, 3]) {
        try {
          compose("start", `${cluster}-db-${n}`);
        } catch {}
      }
    }
  });

  for (const cluster of ["exam", "world"]) {
    const { write, table, key } = WRITES[cluster];

    it(`${cluster}-db: a row written through ${cluster}-service is on both replicas, and replicas refuse writes`, async () => {
      const row = await until(`a ${cluster}-service write`, async () => {
        const r = await write();
        return r.ok ? r : null;
      }, 30_000);
      const replicas = members(cluster).filter((m) => m.Role !== "Leader").map((m) => m.Member);
      for (const node of replicas) {
        await until(`${row.id} on ${node}`, () => psql(node, cluster, `SELECT count(*) FROM ${table} WHERE ${key} = '${row.id}'`) === "1", 10_000, 200);
      }
      assert.throws(() => psql(replicas[0], cluster, `UPDATE ${table} SET updated_at = now() WHERE ${key} = '${row.id}'`), /read-only transaction/);
    });

    it(`${cluster}-db: killing the leader under load promotes a replica; no acknowledged write is lost; the old leader rejoins`, async () => {
      const old = leaderOf(cluster);
      const timelineBefore = Number(members(cluster).find((m) => m.Member === old).TL);
      const load = writer(write);
      await sleep(2_000);
      log(`killing leader ${old}`);
      const killedAt = Date.now();
      compose("kill", old);

      const promoted = await until(`a new ${cluster}-db leader`, () => {
        const l = leaderOf(cluster);
        return l && l !== old ? l : null;
      }, 60_000);
      log(`new leader ${promoted} after ${((Date.now() - killedAt) / 1000).toFixed(1)} s`);
      await until("writes succeeding again", () => {
        const tail = load.results.slice(-4);
        return tail.length === 4 && tail.every((r) => r.ok);
      }, 60_000);
      await load.stop();
      log(failureWindow(load.results));

      const acked = load.results.filter((r) => r.ok).map((r) => `'${r.id}'`);
      const found = Number(psql(promoted, cluster, `SELECT count(*) FROM ${table} WHERE ${key} IN (${acked.join(",")})`));
      assert.equal(found, acked.length, `every ${cluster}-service write that was answered 201 is on the new leader`);
      assert.ok(Number(members(cluster).find((m) => m.Member === promoted).TL) > timelineBefore, "the timeline moved on");

      compose("start", old);
      await until(`${old} back as a streaming replica`, () => members(cluster).find((m) => m.Member === old && m.Role !== "Leader" && m.State === "streaming"), 120_000);
      log(`${old} rejoined as a replica`);
    });
  }
});
