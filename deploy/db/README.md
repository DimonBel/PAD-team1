# Database scripts

Schema and seed data for the services, dumped from a freshly migrated (and, for exam/world,
freshly seeded) database.

| File | What it is |
| --- | --- |
| `base-service-schema.sql` | tables, indexes and constraints for base-service |
| `base-service-seed.sql` | the upgrade catalog: facilities, storage tiers, expansion |
| `crafting-service-schema.sql` | tables, indexes and constraints for crafting-service |
| `crafting-service-seed.sql` | the five starting recipes from the contract |
| `exam-service-schema.sql` | tables, indexes and constraints for exam-service |
| `exam-service-seed.sql` | 2 demo courses/exams and 2 players with contrasting pass/fail grades |
| `world-service-schema.sql` | tables, indexes and constraints for world-service |
| `world-service-seed.sql` | a small demoable campus: 1 map, 2 zones, 6 rooms, 6 resource nodes, 7 zombie spawns |

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
```

The seed files insert without checking first, so load them once into an empty database.
The seeding built into the service is the skip-if-present one (exam/world's own
`priv/repo/seed.sql` in each service's repo does this via `ON CONFLICT DO NOTHING` — these
dumps are a snapshot of running that once, not a separate source of truth).

Verified by loading both exam/world pairs into fresh, empty databases and confirming the
actual Phoenix app reads the data back correctly through Ecto, not just that the SQL applies
without error.
