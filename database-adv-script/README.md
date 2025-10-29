# Advanced Database Scripts — Unleashing Advanced Querying Power

This folder contains the deliverables for the Advanced Module.

## How to Run (PostgreSQL)
```sql
\timing on
-- Run any file:
\i database-adv-script/joins_queries.sql
\i database-adv-script/subqueries.sql
\i database-adv-script/aggregations_and_window_functions.sql
\i database-adv-script/performance.sql
\i database-adv-script/partitioning.sql
-- For plans:
EXPLAIN (ANALYZE, BUFFERS) <your query>;
