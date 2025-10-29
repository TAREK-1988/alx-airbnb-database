# Index Performance (Task 3)

> DB: PostgreSQL (version: ___)  
> Timing: `\timing on`  
> Plans: `EXPLAIN (ANALYZE, BUFFERS)`

## 1) Queries used for benchmarking
### Q1 — Total bookings per user
```sql
SELECT u.user_id, u.name, COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON b.user_id = u.user_id
GROUP BY u.user_id, u.name;
