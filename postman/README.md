# Postman collections

One collection per service. Import the `.json` files into Postman, or run them
headless with [Newman](https://github.com/postmanlabs/newman).

| Collection | Service | Default `baseUrl` |
| --- | --- | --- |
| `base-service.postman_collection.json` | base-service | `http://localhost:4007` |
| `crafting-service.postman_collection.json` | crafting-service | `http://localhost:4008` |
| `exam-service.postman_collection.json` | exam-service | `http://localhost:4005` (collection variable is `base_url`) |
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

# exam-service / world-service don't need --env-var tokens (see above) — just the base_url
# if the service isn't on its default port:
newman run postman/exam-service.postman_collection.json
newman run postman/world-service.postman_collection.json --env-var base_url=http://localhost:4004
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

## A note on ordering

The error-case folders run near the end on purpose. "Duplicate lobby -> 409"
only conflicts once a base exists, and "Cancel a finished job -> 409" only
applies after the job has been cancelled. Running a single request out of order
can fail for that reason rather than because the service is broken.
