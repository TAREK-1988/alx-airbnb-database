# Task 3 — Implement Indexes for Optimization (Performance Report)

**Repo/Dir/File:** `alx-airbnb-database/database-adv-script/index_performance.md`  
**Objective:** Identify high-usage columns and create indexes (in `database_index.sql`), then measure query performance **before/after** using `EXPLAIN/ANALYZE`.

---

## 0) What was indexed (DDL lives in `database_index.sql`)
> Run this first to create the indexes, then re-run the benchmarks.

```sql
-- From psql:
\i database-adv-script/database_index.sql
ANALYZE;

