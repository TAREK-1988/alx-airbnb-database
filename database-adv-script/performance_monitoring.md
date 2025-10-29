## How to measure for Task 0
- PostgreSQL:
  - In psql: `\timing on`
  - Run: `EXPLAIN (ANALYZE, BUFFERS) <any join query>`
- MySQL 8.0.18+:
  - `EXPLAIN ANALYZE <query>;`
