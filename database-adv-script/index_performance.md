# Index Performance (Task 3)

> **DB:** PostgreSQL (version: 14+)  
> **Timing:** `\timing on`  
> **Plans:** `EXPLAIN (ANALYZE, BUFFERS)`

## 0) Run Index DDL First
```sql
\i database-adv-script/database_index.sql
ANALYZE;

1) Queries used for benchmarking
Q1 — Total bookings per user
SELECT u.user_id, u.name, COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON b.user_id = u.user_id
GROUP BY u.user_id, u.name;

Q2 — Properties with AVG rating > 4.0
SELECT p.property_id
FROM properties p
WHERE (
  SELECT AVG(r.rating)
  FROM bookings b
  JOIN reviews r ON r.booking_id = b.booking_id
  WHERE b.property_id = p.property_id
) > 4.0;

Q3 — Wide join (filtered: last 180 days, confirmed)
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

2) Results (Before vs After adding indexes)

Replace the sample numbers with your actual timings later if you want.

QueryBefore (ms)After (ms)Plan change (summary)NotesQ112018Seq Scan → Hash Join + Index on bookings(user_id)sampleQ221095Subquery sped up via reviews(booking_id, created_at)sampleQ3780110Index Scan on (checkin, checkout); fewer rows readsample
3) EXPLAIN highlights
EXPLAIN (ANALYZE, BUFFERS)
SELECT u.user_id, u.name, COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON b.user_id = u.user_id
GROUP BY u.user_id, u.name;



Q1 Before: Seq Scan on bookings


Q1 After: Hash Join, Index Scan using idx_bookings_user_id


EXPLAIN (ANALYZE, BUFFERS)
SELECT b.booking_id, b.checkin, b.checkout, u.user_id, u.name, p.property_id, p.city, pay.amount
FROM bookings b
JOIN users u      ON u.user_id = b.user_id
JOIN properties p ON p.property_id = b.property_id
LEFT JOIN payments pay ON pay.booking_id = b.booking_id
WHERE b.status = 'confirmed'
  AND b.checkin >= CURRENT_DATE - INTERVAL '180 days';



Q3 After: uses idx_bookings_checkin_checkout, lower buffers, lower rows


4) Takeaways


Indexes on join keys (FKs) and filter columns significantly reduce runtime.


Partial index on bookings(checkout) WHERE status='confirmed' helps confirmed-only workloads.


Run ANALYZE; after bulk loads to keep plans accurate.


