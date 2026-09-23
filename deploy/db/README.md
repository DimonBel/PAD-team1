# Database scripts

Schema and seed data for the two Ruby services, dumped from a freshly migrated database.

| File | What it is |
| --- | --- |
| `base-service-schema.sql` | tables, indexes and constraints for base-service |
| `base-service-seed.sql` | the upgrade catalog: facilities, storage tiers, expansion |
| `crafting-service-schema.sql` | tables, indexes and constraints for crafting-service |
| `crafting-service-seed.sql` | the five starting recipes from the contract |

The containers run their own migrations and seed themselves on boot, so you do not need
these to run the stack. They are here for inspection, and for loading the data into a
Postgres you manage yourself:

```bash
psql -h localhost -p 5433 -U base -d base_service -f base-service-schema.sql
psql -h localhost -p 5433 -U base -d base_service -f base-service-seed.sql
```

The seed files insert without checking first, so load them once into an empty database.
The seeding built into the service is the skip-if-present one.
