# Index Performance (Task 3)

> **DB:** PostgreSQL (version: 14+)  
> **Timing:** `\timing on`  
> **Plans:** `EXPLAIN (ANALYZE, BUFFERS)`

## 0) Run Index DDL First
Execute the index script and refresh stats before benchmarking:
```sql
\i database-adv-script/database_index.sql
ANALYZE;

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

EXPLAIN (ANALYZE, BUFFERS)
SELECT u.user_id, u.name, COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b ON b.user_id = u.user_id
GROUP BY u.user_id, u.name;

EXPLAIN (ANALYZE, BUFFERS)
SELECT b.booking_id, b.checkin, b.checkout, u.user_id, u.name, p.property_id, p.city, pay.amount
FROM bookings b
JOIN users u      ON u.user_id = b.user_id
JOIN properties p ON p.property_id = b.property_id
LEFT JOIN payments pay ON pay.booking_id = b.booking_id
WHERE b.status = 'confirmed'
  AND b.checkin >= CURRENT_DATE - INTERVAL '180 days';


