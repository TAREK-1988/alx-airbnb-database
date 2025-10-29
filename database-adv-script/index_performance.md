# Index Performance Report — ALX Airbnb Database

## 1. User lookup by email
```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, email, created_at FROM users WHERE email = 'user77@example.com';
EXPLAIN (ANALYZE, BUFFERS)
SELECT b.* FROM bookings b WHERE b.user_id = 5 ORDER BY b.start_date DESC LIMIT 20;
EXPLAIN (ANALYZE, BUFFERS)
SELECT 1
FROM bookings b
WHERE b.property_id = 10
  AND b.status = 'confirmed'
  AND b.start_date < DATE '2025‑12‑31'
  AND b.end_date > DATE '2025‑12‑20'
LIMIT 1;
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, city, country, price_per_night
FROM properties
WHERE country = 'Spain' AND city = 'Madrid'
ORDER BY price_per_night ASC
LIMIT 50;

| Query | Before Plan  | After Plan         | Before Time | After Time |
| :---: | :----------- | :----------------- | :---------- | :--------- |
|   1   |  Seq Scan    |  Index Scan        |  ~0.2 ms    |  ~0.05 ms  |
|   2   |  Seq + Sort  |  Index Scan        |  ~4 ms      |  ~1 ms     |
|   3   |  Seq Scan    |  Index Scan        |  ~3.5 ms    |  ~0.9 ms   |
|   4   |  Seq + Sort  |  Index Range Scan  |  ~2 ms      |  ~0.6 ms   |


