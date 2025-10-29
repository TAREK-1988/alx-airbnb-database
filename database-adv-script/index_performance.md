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
