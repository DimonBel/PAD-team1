# Database replication and failover (Lab 5)

This folder holds the setup that keeps every service's database running when a node is lost.

`base-db`, `crafting-db`, `world-db`, `exam-db`, `zombie-db`, `resource-db`, `player-db` and `game-db` are each a
**Patroni cluster of three Postgres 16 nodes**: a leader and **two streaming replicas**, one of them synchronous.
Leader election runs through etcd, and HAProxy always routes to the current leader. **No service's code changed**:
each still connects to its database by the same name.

## Topology

```
                     etcd-1   etcd-2   etcd-3      leader election (quorum 2 of 3), one scope per database
                        ▲        ▲        ▲
  exam-db-1  ◀── WAL streaming ── exam-db-2 (sync standby), exam-db-3 (async replica)
       ▲  Patroni REST :8008  /primary  /replica  /health  /metrics
  exam-db  = HAProxy ×2   :5432 → leader (writes)   :5433 → replicas (reads)   :8404 stats
       ▲
  exam-service   ecto://exam:…@exam-db:5432/exam_service    (unchanged)
```

The other seven clusters (`<name>-db-1..3` with the router `<name>-db`) have the same shape. All eight share the
etcd, the Patroni image, `patroni.yml` and `haproxy.cfg`; only `PATRONI_SCOPE` / `CLUSTER` and the app database
differ.

**Hostnames didn't change.** The HAProxy service is the one named after the old database (`exam-db`, `player-db`,
...), so the services' `DATABASE_URL`s are exactly as before. No database publishes a host port any more (the leader
moves, and the router runs ×2); each service's own tests use its own compose, which keeps a single Postgres with a
port.

| | |
|---|---|
| Patroni image | [`patroni/Dockerfile`](patroni/Dockerfile): `postgres:16-bookworm` with Patroni 4.0.11 (etcd3, psycopg3). The only image this compose builds locally: `exam-db-1` builds it and the other nodes run it, so they don't race to tag the same image. `PATRONI_IMAGE` can point at a published one |
| Shared config | [`patroni/patroni.yml`](patroni/patroni.yml). Per-node values come from `PATRONI_*` env in the compose (`x-patroni` anchors) |
| First start | [`patroni/post_bootstrap.sh`](patroni/post_bootstrap.sh) creates the service's role and database on the node that initialises the cluster. The service migrates on start, as before |
| Router | [`haproxy/haproxy.cfg`](haproxy/haproxy.cfg), one file for all eight clusters (`CLUSTER=base\|crafting\|world\|exam\|zombie\|resource\|player\|game`) |

**Settings that matter** (`bootstrap.dcs`, changeable later with `patronictl edit-config`):

- **Timing:** `ttl: 20`, `loop_wait: 5`, `retry_timeout: 5`. A dead leader is replaced in about 20–30 s.
- **Synchronous replication:** `synchronous_mode: true`, `synchronous_node_count: 1`.
  - Every commit waits for one replica, so **a failover never loses an acknowledged write**.
  - `synchronous_mode_strict: false`: with no replica left, the leader still accepts writes.
- **Failover safety:** `maximum_lag_on_failover: 1MB`, so a replica far behind is never promoted.
- **Rejoining:** `use_pg_rewind: true`, so an old leader comes back as a replica of the new one.
- **HAProxy:**
  - It health-checks every node's `/primary` (port 5432) or `/replica` (port 5433) every 2 s.
  - `on-marked-down shutdown-sessions` cuts the connections to a node that stopped leading. The Ecto pools then
    reconnect to the new leader instead of writing into a read-only replica.
- **Restart policy:** every service has `restart: unless-stopped`. A failover that catches its boot migration
  mid-election only delays it.

Secrets: `PATRONI_SUPERUSER_PASSWORD`, `PATRONI_REPLICATION_PASSWORD` and `PATRONI_RESTAPI_PASSWORD` (the latter
for the REST user `patroni`, needed for switchover and restart) go in `.env`. See `.env.example`.

The shell scripts must keep LF endings, or every node fails with `exec entrypoint.sh: no such file or directory`.
The root `.gitattributes` makes sure of that on a Windows checkout too.

## Runbook

```powershell
docker compose exec exam-db-1 patronictl -c /etc/patroni/patroni.yml list
docker compose exec exam-db-1 patronictl -c /etc/patroni/patroni.yml switchover exam --leader exam-db-1 --candidate exam-db-2 --force
docker compose exec exam-db-1 patronictl -c /etc/patroni/patroni.yml reinit exam exam-db-3 --force
docker compose exec exam-db-1 curl -s localhost:8008/cluster
```

- The `list` output shows Role (Leader / Sync Standby / Replica), State (running / streaming), TL (timeline: +1 per
  failover) and the lag.
- `reinit` rebuilds a replica from the leader.
- HAProxy's stats page is at `http://exam-db:8404/stats` inside the network.
- The clusters start empty: the old single-node `<name>-pgdata` volumes are left alone. Load the demo
  data again (`deploy/db/README.md`) into the leader node (`patronictl list` names it), e.g. when exam-db-1 leads:
  `Get-Content dump.sql | docker compose exec -T exam-db-1 psql -U postgres -d exam_service`.

## Seeing the replication with your own eyes

The tests prove it, but these let you watch it.

1. **pgAdmin** (a database GUI), optional and off by default:
   ```powershell
   docker compose --profile dbadmin up -d pgadmin
   ```
   Open http://localhost:5050. No login is needed. Every node of the eight clusters is already listed under its cluster group, plus each router's `:5432` (the leader) and `:5433` (a replica), from [`pgadmin/servers.json`](pgadmin/servers.json). pgAdmin logs in as `postgres` with `PATRONI_SUPERUSER_PASSWORD`.
   - pgAdmin reads `servers.json` only on its first start. After the list changes, start it from scratch: `docker compose --profile dbadmin rm -sfv pgadmin`, then `up -d pgadmin` again.
   - **The same row on every node:** create a course through the Gateway, then open `exam-db-1`, `exam-db-2` and `exam-db-3` → `exam_service` → Schemas → public → Tables → `courses` → View Data. The row is on all three. For world, a zone in `zones`.
   - **Only the leader takes writes:** in the Query Tool on a replica, `INSERT INTO courses (course_id, name, required_exam_ids, inserted_at, updated_at) VALUES ('x', 'x', '{}', now(), now());` fails with `cannot execute INSERT in a read-only transaction`.
   - **Who streams from whom:** on the leader, `SELECT application_name, state, sync_state, replay_lag FROM pg_stat_replication;` shows the two replicas (one `sync`, one `async`). On a replica, `SELECT pg_is_in_recovery();` is `true`.
   - **Failover:** `docker compose kill exam-db-1` (if it is the leader). Refresh: that node is gone, another one answers `pg_is_in_recovery() = false`, and the `exam-db :5432` entry reaches the new leader without changing anything.
2. **Watch the cluster change live** in a second terminal while you kill nodes:
   ```powershell
   while ($true) { Clear-Host; docker compose exec exam-db-2 patronictl -c /etc/patroni/patroni.yml list; Start-Sleep 2 }
   ```
   You see the Leader move, TL (timeline) go up by one, and the old leader come back as `Replica` / `streaming` after `docker compose start exam-db-1`.
3. **Patroni's REST API**, readable as JSON:
   ```powershell
   docker compose exec exam-db-1 curl -s localhost:8008/cluster
   ```

## Tests

`node --test --test-concurrency=1 deploy/db-ha-e2e.test.mjs` on the running stack:
- every one of the eight clusters: one leader and two streaming replicas, one of them synchronous, no lag, and the
  replicas in recovery (read-only); nothing is written into the databases for this;
- exam-db and world-db, through their services: a course (exam) or a zone (world) written through the Gateway is on
  both replicas, and a replica refuses writes;
- the leader killed under constant writes through the service: a replica is promoted, no write that was answered `201` is lost, the timeline moves on, and the old leader rejoins as a replica.
