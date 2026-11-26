# Service-to-service contracts (gRPC)

Lab 4 moves every call one service makes to another from REST to gRPC, and every such call goes
through the Message Broker. Clients outside the platform keep using REST through the Gateway.

| File | Server | Called by |
| --- | --- | --- |
| `player/v1/player.proto` | player-service | game, exam, base, crafting, zombie |
| `exam/v1/exam.proto` | exam-service | game, crafting |
| `world/v1/world.proto` | world-service | game, exam, base, crafting |
| `crafting/v1/crafting.proto` | crafting-service | exam, world |
| `resource/v1/resource.proto` | resource-service | game, world, base, crafting, zombie |
| `zombie/v1/zombie.proto` | zombie-service | game |
| `game/v1/game.proto` | game-service | zombie (the Communication Contract has the Zombie Service push encounters and zombie actions, and a service can advance a cycle) |
| `events/v1/events.proto` | `Publish`: the Message Broker. `Deliver`: every service that subscribes to a topic | any service firing an event; the broker |

base-service receives no calls from other services, so it has no file here.
Every RPC is the gRPC form of one REST endpoint, named in the comment above it, with the same
fields and the same idempotency key (`event_id` or `operation_id`). The REST endpoints stay
until every caller has moved.

## How a call travels

```
caller ──gRPC──▶ message-broker:9090 ──gRPC──▶ one instance of the target, at its grpc_url
```

1. The caller dials the broker (`BROKER_GRPC_URL`, e.g. `message-broker:9090`), never a service.
   It sends this metadata:

   | Key | Value |
   | --- | --- |
   | `authorization` | `Bearer <service JWT>`, signed with `SERVICE_JWT_SECRET` as for REST |
   | `x-request-id` | the id of the request being served, so it can be followed in the logs |
   | `x-broker-service` | the target, e.g. `resource-service` (optional, see below) |

2. The broker finds the target from the method path: the first part of the package plus
   `-service`, so `/resource.v1.Resources/Gather` goes to `resource-service`. `x-broker-service`
   wins when present. The broker doesn't need the `.proto` files: it forwards the request and
   response messages as bytes.
3. It verifies the JWT, picks an instance with the same load balancing and circuit breakers as
   for REST, and sends the call to that instance's `grpc_url`. Instead of `authorization` the
   instance receives what the Gateway sends over REST: `x-gateway-secret`, `x-service-name`,
   `x-roles`, `x-request-id`. A server refuses a call without the right `x-gateway-secret`
   (`UNAUTHENTICATED`) or without the `service` role (`PERMISSION_DENIED`).
4. Only `UNAVAILABLE`, `DEADLINE_EXCEEDED`, `INTERNAL` and `UNKNOWN` count against an
   instance's circuit, as only a 5xx or no answer does for REST.

## Servers

- Listen on `GRPC_PORT` (default `50051`) next to the HTTP port. Replicas don't share a host
  port, so the port is never published.
- Register with Service Discovery as before and add `"grpc_url": "<host>:<GRPC_PORT>"` to the
  registration's `metadata`. The broker reads it from there.

## Errors

The status a server answers with, for the HTTP status its REST endpoint uses:

| REST | gRPC |
| --- | --- |
| 400, 422 invalid input | `INVALID_ARGUMENT` |
| 401 | `UNAUTHENTICATED` |
| 403 | `PERMISSION_DENIED` |
| 404 | `NOT_FOUND` |
| 409, the thing already exists | `ALREADY_EXISTS` |
| 409, the state doesn't allow it (not enough stock, an attempt already open) | `FAILED_PRECONDITION` |
| 429 | `RESOURCE_EXHAUSTED` |
| 500 | `INTERNAL` |
| 502, 503 | `UNAVAILABLE` |
| 504 | `DEADLINE_EXCEEDED` |

The error message is the one the REST endpoint puts in `{"error": ...}`.

## Conventions

- One package per service, `<service>.v1`. A change that breaks callers goes into `v2`, next
  to `v1`, until every caller has moved.
- Field numbers are never reused. Removed fields are `reserved`.
- Times are ISO 8601 strings, as in the REST answers.
- `optional` marks a field whose absence means something (a filter, an id generated when it is
  left out). Otherwise an empty string or 0 means "not set", as proto3 can't tell them apart.
- Enums start with an `_UNSPECIFIED = 0` value, which servers refuse with `INVALID_ARGUMENT`.
- A deadline on every call, normally the caller's task timeout.

## Generating code

Each service keeps its generated code in its own tree, so it builds without this directory.
Regenerate it after changing a file here, e.g. for the Ruby services:

```sh
cd zombie-service && bin/generate-protos     # reads ../proto, writes app/grpc/gen
```

Elixir uses `protoc --elixir_out=plugins=grpc:...` from `protobuf` / `grpc` on hex, and
TypeScript uses `@grpc/grpc-js` with `@grpc/proto-loader`, or loads the files at runtime.
