# Postman collections

One collection per service. Import the `.json` files into Postman, or run them
headless with [Newman](https://github.com/postmanlabs/newman).

| Collection | Service | Default `baseUrl` |
| --- | --- | --- |
| `base-service.postman_collection.json` | base-service | `http://localhost:4007` |
| `crafting-service.postman_collection.json` | crafting-service | `http://localhost:4008` |
| `zombie-service.postman_collection.json` | zombie-service | `http://localhost:4003` |
| `resource-service.postman_collection.json` | resource-service | `http://localhost:4006` |
| `exam-service.postman_collection.json` | exam-service | `http://localhost:4005` (collection variable is `base_url`) |
| `player-service.postman_collection.json` | player-service | `http://localhost:4001` (collection variable is `base_url`) |
| `game-service.postman_collection.json` | game-service | `http://localhost:4002` (collection variable is `baseUrl`) |
| `world-service.postman_collection.json` | world-service | `http://localhost:4004` (collection variable is `base_url`) |

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

**exam-service / world-service** — nothing to mint by hand. Each request self-signs its own
JWT in a pre-request script (bundled `CryptoJS`, HS256, signed with the same dev secrets the
service itself uses), stored in the collection variables `player_token` / `moderator_token` /
`service_token`. Just import and run — no token-pasting step.

## Running in Postman

Open the Collection Runner and run the folders top to bottom. They are numbered
because later requests depend on earlier ones: creating a base stores `baseId`
into a collection variable, building a facility stores `facilityId`, and so on.

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

# exam-service / world-service don't need --env-var tokens (see above). Against the shared
# compose stack, pass the base_url plus the same JWT secrets you put in the root .env — the
# collections default to each service's local dev secrets otherwise, and every request
# would come back 401:
newman run postman/exam-service.postman_collection.json \
  --env-var base_url=http://localhost:4005 \
  --env-var jwt_secret="$JWT_SECRET" \
  --env-var service_jwt_secret="$SERVICE_JWT_SECRET"
newman run postman/world-service.postman_collection.json \
  --env-var base_url=http://localhost:4004 \
  --env-var jwt_secret="$JWT_SECRET" \
  --env-var service_jwt_secret="$SERVICE_JWT_SECRET"

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
| exam-service | 27 | 44 | 1 (`Reference — Manual Only`, needs a hand-seeded expired attempt — not a real failure) |
| world-service | 25 | 46 | 0 |
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
