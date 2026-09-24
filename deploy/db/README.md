# Database scripts

Schema and seed data for the services, dumped from freshly migrated and seeded databases.

| File | What it is |
| --- | --- |
| `base-service-schema.sql` | tables, indexes and constraints for base-service |
| `base-service-seed.sql` | the upgrade catalog: facilities, storage tiers, expansion |
| `crafting-service-schema.sql` | tables, indexes and constraints for crafting-service |
| `crafting-service-seed.sql` | the five starting recipes from the contract |
| `game-service-schema.sql` | tables, indexes and constraints for game-service |
| `game-service-seed.sql` | 2 demo lobbies, a running session, and sample actions, encounters, trades and zombies |
| `player-service-schema.sql` | tables, indexes and constraints for player-service |
| `player-service-seed.sql` | 3 demo players with their starting inventory (see the note below) |
| `exam-service-schema.sql` | tables, indexes and constraints for exam-service |
| `exam-service-seed.sql` | 2 demo courses/exams and 2 players with contrasting pass/fail grades |
| `resource-service-schema.sql` | tables, indexes and constraints for resource-service |
| `resource-service-seed.sql` | 4 resource entities and 3 resource points |
| `world-service-schema.sql` | tables, indexes and constraints for world-service |
| `world-service-seed.sql` | a small demoable campus: 1 map, 2 zones, 6 rooms, 6 resource nodes, 7 zombie spawns |
| `zombie-service-schema.sql` | tables, indexes and constraints for zombie-service |
| `zombie-service-seed.sql` | 3 zombie types, 2 zombie instances and sample inventory |

The containers run their own migrations and seed themselves on boot, so you do not need
these to run the stack. They are here for inspection, and for loading the data into a
Postgres you manage yourself:

```bash
psql -h localhost -p 5433 -U base -d base_service -f base-service-schema.sql
psql -h localhost -p 5433 -U base -d base_service -f base-service-seed.sql

psql -h localhost -p 5433 -U postgres -d exam_service_dev -f exam-service-schema.sql
psql -h localhost -p 5433 -U postgres -d exam_service_dev -f exam-service-seed.sql

psql -h localhost -p 5434 -U postgres -d world_service_dev -f world-service-schema.sql
psql -h localhost -p 5434 -U postgres -d world_service_dev -f world-service-seed.sql

psql -h localhost -p 5436 -U resource -d resource_service -f resource-service-schema.sql
psql -h localhost -p 5436 -U resource -d resource_service -f resource-service-seed.sql

psql -h localhost -p 5433 -U zombie -d zombie_service -f zombie-service-schema.sql
psql -h localhost -p 5433 -U zombie -d zombie_service -f zombie-service-seed.sql

psql -h localhost -p 5432 -U player -d player_service -f player-service-schema.sql
psql -h localhost -p 5432 -U player -d player_service -f player-service-seed.sql

psql -h localhost -p 5432 -U game -d game_service -f game-service-schema.sql
psql -h localhost -p 5432 -U game -d game_service -f game-service-seed.sql
```

Neither `*-db` service in `docker-compose.yaml` publishes a host port, so the ports above
are for a Postgres you run yourself. To load a file into the shared stack instead, pipe it
into the database container, the same way the exam/world seeds are loaded from the root
README:

```bash
docker compose exec -T player-db psql -U player -d player_service < deploy/db/player-service-seed.sql
```

The seed files insert without checking first, so load them once into an empty database.
The seeding built into the service is the skip-if-present one (exam/world's own
`priv/repo/seed.sql` in each service's repo does this via `ON CONFLICT DO NOTHING` — these
dumps are a snapshot of running that once, not a separate source of truth).

### player-service seeds are incomplete

`player-service-seed.sql` carries 3 players, 8 inventory items and 8 idempotency keys.
`player_levels`, `xp_ledger`, `friendships`, `trades` and `presence` are empty because the
service's own `priv/repo/seeds.exs` aborts partway through, and it does so for two separate
reasons:

1. The container entrypoint runs `mix run --no-start priv/repo/seeds.exs`. With `--no-start`
   the repo is never started, so line 7's `Repo.aggregate/2` raises
   `could not lookup Ecto repo PlayerService.Repo because it was not started`. The entrypoint
   ends that line with `|| true`, so the failure is swallowed and boot looks clean while
   nothing at all has been inserted.
2. Started properly, the script gets as far as awarding XP and then dies on
   `null value in column "updated_at" of relation "player_levels" violates not-null
   constraint`.

This dump is what a clean `mix ecto.migrate` plus `mix run priv/repo/seeds.exs` actually
produces today, so it is a faithful snapshot rather than a hand-written wishlist. Both fixes
belong in the player-service repository; refresh this file once they land.

### game-service will not boot on its published image alone

`rel/overlays/bin/server` is committed with mode `100644`, so the release's start script
lands in the image without the executable bit and the image's own `CMD` exits with
`permission denied`. `docker-compose.yaml` therefore runs it as `sh /app/bin/server`, which
executes the same script and migrates and seeds exactly as intended. Drop that `command:`
once the bit is fixed upstream.

Verified by loading both exam/world pairs into fresh, empty databases and confirming the
actual Phoenix app reads the data back correctly through Ecto, not just that the SQL applies
without error. The player-service and game-service pairs were checked the same way: dumped
from a database created by that service's own migrations and seeds, then reloaded into an
empty Postgres with `psql -v ON_ERROR_STOP=1` (10 and 9 tables restored, no errors).
