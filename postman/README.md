# Postman collections

One collection per service. Import the `.json` files into Postman, or run them
headless with [Newman](https://github.com/postmanlabs/newman).

| Collection | Service | Default `baseUrl` |
| --- | --- | --- |
| `base-service.postman_collection.json` | base-service | `http://localhost:4007` |
| `crafting-service.postman_collection.json` | crafting-service | `http://localhost:4008` |
| `zombie-service.postman_collection.json` | zombie-service | `http://localhost:4003` |
| `resource-service.postman_collection.json` | resource-service | `http://localhost:4006` |
| `exam-service.postman_collection.json` | exam-service | `http://localhost:8080`, the API Gateway (collection variable is `base_url`) |
| `player-service.postman_collection.json` | player-service | `http://localhost:4001` (collection variable is `base_url`) |
| `game-service.postman_collection.json` | game-service | `http://localhost:4002` (collection variable is `baseUrl`) |
| `world-service.postman_collection.json` | world-service | `http://localhost:8080`, the API Gateway (collection variable is `base_url`) |

## Before you run anything

**base-service / crafting-service** — start the service, then mint the two tokens it expects:

```bash
docker compose exec app bundle exec rake token:player
docker compose exec app bundle exec rake token:service
```

Paste them into the collection variables `playerToken` and `serviceToken`.
Public endpoints take the player token; the ones the contract marks `[internal]`
take the service token, and a player token on those correctly returns 401.

**zombie-service** — start the service, then mint both tokens it expects:

```bash
docker compose exec zombie-service bundle exec rake token:service
docker compose exec zombie-service bundle exec rake token:player
```

Paste them into `serviceToken` and `playerToken`. Zombie endpoints require the
service token; the player token is used by the authentication folder to verify
that it is rejected.

**resource-service** — start the service, then mint its service token:

```bash
docker compose exec resource-service bundle exec rake token:service
```

Paste it into the collection variable `serviceToken`. All resource endpoints
except health require the service token.

**player-service** — nothing to mint by hand. It is the service that issues tokens, so the
collection registers a player and logs in, then stores the returned JWT in `jwt` and reuses it
for every protected request. The service-token requests read `service_token`, which the
collection mints through the dev-only route `POST /api/_dev/mint_service_token` (guarded by
the `X-Dev-Token` header, default `dev`). Those `/api/_dev` routes are compiled in only when
`MIX_ENV=dev`, so on a production image they are absent and `service_token` must be supplied
by hand.

**game-service** — nothing to mint by hand either, but read this before trusting a green run.
The collection ships placeholder values in `token` and `serviceToken` and relies on the
service's `BYPASS_AUTH=true`, which accepts any Authorization header and also waves through
the endpoints the contract marks internal. `docker-compose.yaml` sets `BYPASS_AUTH=false` for
the shared stack, because the real Player Service is in it — so against that stack you must
put a real player JWT in `token` and a real service JWT in `serviceToken`, or every request
comes back 401.

**exam-service / world-service** — nothing to mint by hand, but the Gateway must be running.
Since 2.0.0 both services only accept requests the API Gateway forwarded (a direct call gets
`401`), so `base_url` defaults to the Gateway, `http://localhost:8080`. The collection-level
pre-request script signs its own JWTs the way the Gateway checks them (bundled `CryptoJS`,
HS256 with `exp`; player tokens with `jwt_secret`, service tokens with `service_jwt_secret`
and `sub: "service:<name>"`), stored in `player_token` / `moderator_token` / `service_token`.

- `jwt_secret` / `service_jwt_secret` must equal the `JWT_SECRET` / `SERVICE_JWT_SECRET` the
  Gateway runs with, i.e. the root `.env`. They default to `change_me`, the `.env.example`
  placeholders. A wrong value gives `401 {"error":"UNAUTHORIZED"}` from the Gateway.
- **Temporary, until the Gateway is in `docker-compose.yaml`:** to call a service directly, set
  `base_url` to it (`http://localhost:4005` / `http://localhost:4004`) and `gateway_secret` to
  `GATEWAY_SECRET` from `.env`. The pre-request script then adds the headers the Gateway would
  send (`X-Gateway-Secret`, `X-Player-Id`, `X-Roles`, `X-Service-Name`). Leave `gateway_secret`
  empty to go through the Gateway; in direct mode the `jwt_secret`s don't matter.

## Running in Postman

Open the Collection Runner and run the folders top to bottom. They are numbered
because later requests depend on earlier ones: creating a base stores `baseId`
into a collection variable, building a facility stores `facilityId`, and so on.

**exam-service / world-service** can be run again and again, in the app too: the first request
of a run (`Create Course` / `Create Map`) picks a fresh `run_id` and clears the ids the previous
run left in the collection variables, so a second run never hits a 422 on re-created data or
a stale `diploma_progress`. exam-service's folder 4 (the 410 expired-attempt case) is manual:
its request is skipped unless you set `expired_attempt_id` (see the folder description), so a
normal run reports 0 failures.

`event_id` uses Postman's `{{$guid}}`, so every run sends a fresh value. These
services are idempotent by `event_id`, so a fixed one would replay the first
response forever instead of exercising the endpoint.

## Running headless

```bash
newman run postman/base-service.postman_collection.json \
  --env-var playerToken="$PLAYER_TOKEN" \
  --env-var serviceToken="$SERVICE_TOKEN"
newman run postman/zombie-service.postman_collection.json \
  --env-var serviceToken="$SERVICE_TOKEN" \
  --env-var playerToken="$PLAYER_TOKEN"
newman run postman/resource-service.postman_collection.json \
  --env-var serviceToken="$SERVICE_TOKEN"

# exam-service / world-service don't need --env-var tokens (see above). Through the Gateway
# (default base_url http://localhost:8080), pass the JWT secrets from the root .env:
newman run postman/exam-service.postman_collection.json \
  --env-var jwt_secret="$JWT_SECRET" \
  --env-var service_jwt_secret="$SERVICE_JWT_SECRET"
newman run postman/world-service.postman_collection.json \
  --env-var jwt_secret="$JWT_SECRET" \
  --env-var service_jwt_secret="$SERVICE_JWT_SECRET"
# Temporary, without a Gateway: straight at the service, with the Gateway secret
newman run postman/exam-service.postman_collection.json \
  --env-var base_url=http://localhost:4005 --env-var gateway_secret="$GATEWAY_SECRET"

newman run postman/player-service.postman_collection.json \
  --env-var base_url=http://localhost:4001 \
  --env-var dev_token="$DEV_TOKEN"
# game-service against the shared stack, where BYPASS_AUTH is false:
newman run postman/game-service.postman_collection.json \
  --env-var baseUrl=http://localhost:4002 \
  --env-var token="$PLAYER_TOKEN" \
  --env-var serviceToken="$SERVICE_TOKEN"
```

Each request asserts its status code, including the failure paths the contract
promises: 401 without a token, 403 on a locked recipe, 404 on an unknown id,
409 on a duplicate, 422 on a bad payload, 429 while Kiki is on cooldown.

Last run against a freshly migrated and seeded database:

| Collection | Requests | Assertions | Failures |
| --- | --- | --- | --- |
| base-service | 35 | 36 | 0 |
| crafting-service | 24 | 25 | 0 |
| exam-service | 26 | 43 | 0 (2.0.1 through the Gateway, two runs in a row; folder 4 skipped) |
| world-service | 25 | 46 | 0 (2.0.1 through the Gateway, two runs in a row) |
| player-service | not run yet | | |
| game-service | not run yet | | |

The player-service and game-service collections are the ones each service already ships in
its own repository (`postman.json` on `main`), copied here unchanged except for the base URL,
which now points at the port the shared stack publishes (4001 and 4002) instead of each
service's standalone default of 4000. Neither has been run headlessly against the shared
stack yet, so their rows are deliberately blank rather than filled in with numbers from a
standalone run — the two caveats above (player-service's dev-only token route, game-service's
`BYPASS_AUTH=false`) both change the result.

## A note on ordering

The error-case folders run near the end on purpose. "Duplicate lobby -> 409"
only conflicts once a base exists, and "Cancel a finished job -> 409" only
applies after the job has been cancelled. Running a single request out of order
can fail for that reason rather than because the service is broken.
