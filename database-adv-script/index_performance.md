# Index Performance Report — ALX Airbnb Database

**Date:** 2025-10-29  
**DB Engine:** PostgreSQL  
**Dataset Size:** (users: N, properties: N, bookings: N)

## Queries Measured

1) User lookup by email
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, email, created_at FROM users WHERE email = 'alice@example.com';

EXPLAIN (ANALYZE, BUFFERS)
SELECT b.*
FROM bookings b
WHERE b.user_id = 42
ORDER BY b.start_date DESC
LIMIT 20;

EXPLAIN (ANALYZE, BUFFERS)
SELECT 1
FROM bookings b
WHERE b.property_id = 1001
  AND b.status = 'confirmed'
  AND b.start_date < DATE '2025-12-31'
  AND b.end_date   > DATE '2025-12-20'
LIMIT 1;

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, city, country, price_per_night
FROM properties
WHERE country = 'Spain' AND city = 'Madrid'
ORDER BY price_per_night ASC
LIMIT 50;

| Query | Before Plan  | Before Time | After Plan  | After Time | Delta |
| ----: | ------------ | ----------- | ----------- | ---------- | ----- |
|     1 | Seq Scan     | xx ms       | Index Scan  | yy ms      | -zz%  |
|     2 | Seq+Sort     | xx ms       | Index Scan  | yy ms      | -zz%  |
|     3 | Seq Scan     | xx ms       | Index Scan  | yy ms      | -zz%  |
|     4 | Seq+Filesort | xx ms       | Index Range | yy ms      | -zz%  |


