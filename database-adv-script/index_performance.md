# Index Performance (Task 3)

> **DB:** PostgreSQL (version: ___)  
> **Timing:** `\timing on`  
> **Plans:** `EXPLAIN (ANALYZE, BUFFERS)`

## 1) Queries used for benchmarking

### Q1 — Total bookings per user
```sql
SELECT u.user_id, u.name, COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON b.user_id = u.user_id
GROUP BY u.user_id, u.name;

SELECT p.property_id
FROM properties p
WHERE (
  SELECT AVG(r.rating)
  FROM bookings b
  JOIN reviews r ON r.booking_id = b.booking_id
  WHERE b.property_id = p.property_id
) > 4.0;

SELECT b.booking_id, b.checkin, b.checkout,
       u.user_id, u.name,
       p.property_id, p.city,
       pay.amount
FROM bookings b
JOIN users u      ON u.user_id = b.user_id
JOIN properties p ON p.property_id = b.property_id
LEFT JOIN payments pay ON pay.booking_id = b.booking_id
WHERE b.status = 'confirmed'
  AND b.checkin >= CURRENT_DATE - INTERVAL '180 days';


## 2) Results (Before vs After adding indexes)

| Query | Before (ms) | After (ms) | Plan change (summary)                                | Notes |
|------:|------------:|-----------:|------------------------------------------------------|------|
| Q1    |     ___     |    ___     | Seq Scan → Hash Join + Index on bookings(user_id)    |      |
| Q2    |     ___     |    ___     | Subquery sped up via reviews(booking_id, created_at) |      |
| Q3    |     ___     |    ___     | Index Scan on (checkin, checkout); fewer rows read   |      |

## 3) EXPLAIN highlights (paste key lines)

- **Q1 Before:** `Seq Scan on bookings`  
- **Q1 After:** `Hash Join`, `Index Scan using idx_bookings_user_id`  
- **Q3 After:** uses `idx_bookings_checkin_checkout`, lower buffers, lower rows

## 4) Takeaways

- Indexes on join keys (FKs) and filter columns significantly reduce runtime.  
- Partial index on `bookings(checkout) WHERE status='confirmed'` helps confirmed-only workloads.  
- Run `ANALYZE;` after bulk loads to keep plans accurate.
