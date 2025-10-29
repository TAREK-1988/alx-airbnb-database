# Task 0 — Write Complex Queries with Joins

This folder contains scripts for the **Unleashing Advanced Querying Power** module.

## Files
- `joins_queries.sql`: contains three queries:
  - INNER JOIN: bookings × users
  - LEFT JOIN: properties × (bookings → reviews), includes properties with no reviews
  - FULL OUTER JOIN: users ↔ bookings (with MySQL UNION fallback in comments)

## How to Run (PostgreSQL)
```sql
\i database-adv-script/joins_queries.sql
\timing on
EXPLAIN (ANALYZE, BUFFERS) <paste query>;
