# Postman collections

One collection per service, plus `new-endpoints` for the Gateway cache, the broker's sagas and the
ETL. **Every collection runs through the API Gateway** (`http://localhost:8080`) against the whole
`docker compose` stack. Nothing is minted by hand: each collection registers its own players,
logs them in through the Gateway, signs the service tokens it needs, and stocks the resources it
uses. Every run picks a fresh `run_id`, so the collections can be run again and again.

| Collection | What it shows | Gateway variable |
| --- | --- | --- |
| `player-service` | register, login (Gateway JWT), profile, XP (idempotent), inventory, friends, trades between two players, logout → `401 SESSION_REVOKED` | `base_url` |
| `game-service` | **player-, resource-, zombie- and game-service together**: two real players, a lobby and a session, a lobby trade that moves stock in resource-service, an XP steal that player-service shows, the semester end charging the steal once | `base_url` |
| `exam-service` | courses, exams, attempts; a passed exam runs the broker's exam-passed saga (XP in player-service, the wing unlocked in world-service) | `base_url` |
| `world-service` | maps, zones, rooms, resource nodes; `exam.passed` through the broker | `base_url` |
| `base-service` | bases, facilities, rooms, barricades, decorations, Kiki, with a real player and a base stocked in resource-service | `baseUrl` |
| `crafting-service` | recipes, unlocks, jobs, with the player's materials stocked in resource-service | `baseUrl` |
| `zombie-service` | zombie routes (service-only) | `baseUrl` |
| `resource-service` | entity stock, idempotent by `event_id` (service-only) | `baseUrl` |
| `new-endpoints` | Gateway cache (`X-Cache` MISS→HIT, `/cache/stats`), sessions, broker sagas, ETL runs | `gateway_url`, `broker_url`, `etl_url` |

## Before you run

Set these collection variables from the root `.env` (they default to `change_me`, the
`.env.example` placeholders):

| Variable | From `.env` | Used by |
| --- | --- | --- |
| `jwt_secret` | `JWT_SECRET` | every collection except `new-endpoints`: player and moderator tokens the Gateway accepts |
| `service_jwt_secret` | `SERVICE_JWT_SECRET` | every collection except `new-endpoints`: service tokens (`sub: "service:<name>"`) |
| `cache_admin_key` | `CACHE_ADMIN_KEY` | `new-endpoints`: `GET /cache/stats` (404 while the key is empty) |
| `broker_admin_secret` | `BROKER_ADMIN_SECRET` | `new-endpoints`: the saga list (open to anyone while the secret is empty) |
| `etl_admin_key` | `ETL_ADMIN_KEY` | `new-endpoints`: `POST /v1/runs` (`503 RUNS_DISABLED` while the key is empty) |
| `logs_admin_key` | `LOGS_ADMIN_KEY` | exam / world folder 5 log checks (skipped while empty) |

The three admin keys are empty in `.env.example`; put any random value in `.env`
(`openssl rand -hex 24`) and recreate `gateway`, `message-broker` and `etl-service`.

Health folders ask Service Discovery (`discovery_url`, default `http://localhost:8500`) which
instances are up: the services run as replicas with no host port, and Service Discovery calls
each one's `/health` every 10 s.

The Gateway answers a player token on a service-only route with `404 ROUTE_NOT_FOUND` (the route
is hidden from players), and a request without a token with `401 UNAUTHORIZED`; the collections
expect exactly that.

## Running

In Postman: import the collection, set the variables above, open the Collection Runner and run
the whole collection top to bottom. Later requests use ids the earlier ones saved (players,
lobby, session, base, job).

Headless with [Newman](https://github.com/postmanlabs/newman), from the repository root:

```bash
set -a; . ./.env; set +a
for c in player-service game-service exam-service world-service base-service crafting-service zombie-service resource-service; do
  npx newman run "postman/$c.postman_collection.json" \
    --env-var jwt_secret="$JWT_SECRET" --env-var service_jwt_secret="$SERVICE_JWT_SECRET"
done
npx newman run postman/new-endpoints.postman_collection.json \
  --env-var cache_admin_key="$CACHE_ADMIN_KEY" \
  --env-var broker_admin_secret="$BROKER_ADMIN_SECRET" \
  --env-var etl_admin_key="$ETL_ADMIN_KEY"
```

## Player and game service together

`game-service` is the end-to-end story. Every check reads the other service's own answer, not
game-service's:

1. Register and log in a host and a guest (player-service, JWTs from the Gateway).
2. Give the host 120 XP (player-service) and stock the players in resource-service: the host
   2 `coffee-01`, the guest 5 `metal-01`.
3. The host creates a lobby, the guest joins with their own JWT, a second join is `409`.
4. Start the session (day 1, both alive); start, read and cancel an action.
5. Trade 2 `coffee-01` for 5 `metal-01`: resource-service now shows the host with 5 `metal-01`
   and no coffee, the guest with 2 `coffee-01`; the same trade again is `409`.
6. A tourist zombie steals XP from the host: player-service shows the XP down by exactly the
   stolen amount (the broker's zombie-steal saga).
7. End the semester (`ENDING`, then `FINISHED` once the broker's session-end saga is done):
   player-service still shows XP minus the steal, so the steal was charged once.

## Last run

Against the dev `docker-compose.yaml` (broker mode, 3 replicas per database), through the
Gateway, with only the variables above set, twice in a row:

| Collection | Requests | Assertions | Failures |
| --- | --- | --- | --- |
| player-service | 37 | 62 | 0 |
| game-service | 34 | 55 | 0 |
| exam-service | 37 | 60 | 0 (folder 4 skipped by design) |
| world-service | 36 | 64 | 0 |
| base-service | 38 | 42 | 1, the known annex bug below |
| crafting-service | 26 | 29 | 0 |
| zombie-service | 38 | 80 | 0 |
| resource-service | 16 | 17 | 0 |
| new-endpoints | 13 | 15 | 0 |

## Known bugs these collections expose

- **base-service, Annex room → 409.** `world.v1.Room` (`proto/world/v1`) has no `cleared` field,
  so over gRPC (the compose default) base-service never sees a cleared room. The test stays red
  until the proto carries `cleared` and `GrpcWorldClient#room` maps it.
- **crafting-service, timed jobs never finish.** A job with `craft_time_seconds` (e.g.
  `barricade_kit`, 60 s) takes the materials from resource-service but stays `in_progress`, and
  the item never reaches player-service. The collection only checks a job is created.
- **player-service, 500 instead of 404/422** on a player id that is not a UUID.

## A note on ordering

The error-case folders run near the end on purpose: "join again → 409" needs the guest already in
the lobby, "the same trade again → 409" needs the stock already moved. Running a single request
out of order can fail for that reason rather than because a service is broken.
