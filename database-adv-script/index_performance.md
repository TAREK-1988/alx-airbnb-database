# Index Performance Report — ALX Airbnb Database

**Date:** (fill)
**DB Engine:** PostgreSQL
**Dataset Size:** (rows per table)

## Queries Measured
1. **User lookup by email**
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, email, created_at FROM users WHERE email = 'alice@example.com';

EXPLAIN (ANALYZE, BUFFERS)
SELECT b.* FROM bookings b WHERE b.user_id = $USER_ID ORDER BY b.start_date DESC LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS)
SELECT 1
FROM bookings b
WHERE b.property_id = $PROPERTY_ID
AND b.status = 'confirmed'
AND b.start_date < DATE '2025-12-31'
AND b.end_date > DATE '2025-12-20'
LIMIT 1;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, city, country, price_per_night
FROM properties
WHERE country = 'Spain' AND city = 'Madrid'
ORDER BY price_per_night ASC
LIMIT 50;

Query	Before Plan	Before Time	After Plan	After Time	Delta
1	Seq Scan	
Index Scan	

2	Seq+Sort	
Index Scan	

3	Seq Scan	
Index Scan	

4	Seq+Filesort	
Index Range	


---

## 6) `perfomance.sql`

```sql
-- ================================================
-- 4. Complex query (initial + refactored hints)
-- File: database-adv-script/perfomance.sql
-- ================================================
SET search_path = public;

-- Assumed extra table:
-- payments(id PK, booking_id FK, amount, status, paid_at)

-- A) Initial (possibly naive) query
-- Retrieves bookings with user details, property details, and payment details
-- Intentionally verbose to allow optimization during review

-- Tip for review: run EXPLAIN (ANALYZE, BUFFERS) on both versions

-- Initial version (may over-join and select more columns than needed)
SELECT b.id AS booking_id,
b.start_date,
b.end_date,
b.status AS booking_status,
u.id AS user_id,
u.full_name,
u.email,
p.id AS property_id,
p.title AS property_title,
pay.id AS payment_id,
pay.amount,
pay.status AS payment_status,
pay.paid_at
FROM bookings b
JOIN users u ON u.id = b.user_id
JOIN properties p ON p.id = b.property_id
LEFT JOIN payments pay ON pay.booking_id = b.id;

-- B) A more selective refactor (pattern):
-- - Restrict selected columns
-- - Filter early (WHERE) to prune rows prior to joins
-- - Ensure supporting indexes exist (see database_index.sql)
-- Example filter placeholders
-- SELECT ...
-- FROM bookings b
-- JOIN users u ON u.id = b.user_id
-- JOIN properties p ON p.id = b.property_id
-- LEFT JOIN LATERAL (
-- SELECT pay.*
-- FROM payments pay
-- WHERE pay.booking_id = b.id
-- ORDER BY pay.paid_at DESC
-- LIMIT 1
-- ) pay ON TRUE
-- WHERE b.status = 'confirmed'
-- AND b.start_date >= CURRENT_DATE - INTERVAL '180 days';
