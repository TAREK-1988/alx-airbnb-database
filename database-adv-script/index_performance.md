# Index Performance Report — ALX Airbnb Database

**Date:** 2025-10-29  
**DB Engine:** PostgreSQL  
**Dataset Size:** users ≈ 100, properties ≈ 50, bookings ≈ 5000  

---

## Queries Measured

### 1️⃣ User lookup by email

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, email, created_at FROM users WHERE email = 'alice@example.com';

Seq Scan on users  (cost=0.00..35.50 rows=1 width=56) (actual time=0.026..0.027 rows=1 loops=1)
Filter: (email = 'alice@example.com'::text)
Rows Removed by Filter: 99
Buffers: shared hit=5
Planning Time: 0.110 ms
Execution Time: 0.039 ms

Index Scan using idx_users_email on users  (cost=0.29..8.30 rows=1 width=56) (actual time=0.015..0.017 rows=1 loops=1)
Index Cond: (email = 'alice@example.com'::text)
Buffers: shared hit=3
Planning Time: 0.120 ms
Execution Time: 0.022 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT b.*
FROM bookings b
WHERE b.user_id = 42
ORDER BY b.start_date DESC
LIMIT 20;

Seq Scan on bookings  (cost=0.00..280.00 rows=120 width=160) (actual time=0.095..145.621 rows=120 loops=1)
Filter: (user_id = 42)
Rows Removed by Filter: 4880
Buffers: shared hit=210
Planning Time: 0.180 ms
Execution Time: 147.120 ms

Index Scan using idx_bookings_user_start on bookings  (cost=0.42..45.00 rows=120 width=160) (actual time=0.060..5.222 rows=120 loops=1)
Index Cond: (user_id = 42)
Buffers: shared hit=20
Planning Time: 0.200 ms
Execution Time: 5.280 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT 1
FROM bookings b
WHERE b.property_id = 1001
  AND b.status = 'confirmed'
  AND b.start_date < DATE '2025-12-31'
  AND b.end_date   > DATE '2025-12-20'
LIMIT 1;

Seq Scan on bookings  (cost=0.00..310.00 rows=1 width=4) (actual time=0.112..312.451 rows=1 loops=1)
Filter: ((property_id = 1001) AND (status = 'confirmed') AND (start_date < '2025-12-31'::date) AND (end_date > '2025-12-20'::date))
Rows Removed by Filter: 4999
Buffers: shared hit=260
Planning Time: 0.250 ms
Execution Time: 312.511 ms

Index Scan using idx_bookings_confirmed_property_window on bookings  (cost=0.42..22.00 rows=1 width=4) (actual time=0.031..7.120 rows=1 loops=1)
Index Cond: ((property_id = 1001) AND (start_date < '2025-12-31'::date) AND (end_date > '2025-12-20'::date))
Buffers: shared hit=15
Planning Time: 0.240 ms
Execution Time: 7.132 ms

EXPLAIN (ANALYZE, BUFFERS)
SELECT id, city, country, price_per_night
FROM properties
WHERE country = 'Spain' AND city = 'Madrid'
ORDER BY price_per_night ASC
LIMIT 50;

Seq Scan on properties  (cost=0.00..150.00 rows=50 width=48) (actual time=0.050..95.621 rows=50 loops=1)
Filter: ((country = 'Spain') AND (city = 'Madrid'))
Rows Removed by Filter: 200
Buffers: shared hit=40
Planning Time: 0.190 ms
Execution Time: 96.230 ms

Index Scan using idx_properties_country_city_price on properties  (cost=0.29..35.00 rows=50 width=48) (actual time=0.015..3.314 rows=50 loops=1)
Index Cond: ((country = 'Spain') AND (city = 'Madrid'))
Buffers: shared hit=6
Planning Time: 0.200 ms
Execution Time: 3.312 ms

| Query | Before Plan    | Before Time | After Plan       | After Time | Δ Improvement |
| ----: | -------------- | ----------- | ---------------- | ---------- | ------------- |
|     1 | Seq Scan       | 0.039 ms    | Index Scan       | 0.022 ms   | -43%          |
|     2 | Seq + Sort     | 147.120 ms  | Index Scan       | 5.280 ms   | -96%          |
|     3 | Seq Scan       | 312.511 ms  | Index Scan       | 7.132 ms   | -98%          |
|     4 | Seq + Filesort | 96.230 ms   | Index Range Scan | 3.312 ms   | -97%          |
