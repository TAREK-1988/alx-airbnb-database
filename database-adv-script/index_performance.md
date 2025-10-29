# Index Performance Measurements (Before vs After)

## 1) Bookings by user within a date range

### Before indexes
```sql
-- BEFORE: run before creating indexes
EXPLAIN ANALYZE
SELECT b.*
FROM bookings b
WHERE b.user_id = 123
  AND b.checkin  >= DATE '2025-01-01'
  AND b.checkout <  DATE '2025-02-01';
-- expected plan snippet (example):
-- Seq Scan on bookings ...

-- AFTER: run after creating indexes
EXPLAIN ANALYZE
SELECT b.*
FROM bookings b
WHERE b.user_id = 123
  AND b.checkin  >= DATE '2025-01-01'
  AND b.checkout <  DATE '2025-02-01';
-- expected plan snippet (example):
-- Bitmap Index Scan / Index Scan using idx_bookings_user_id, idx_bookings_checkin_checkout ...

-- BEFORE
EXPLAIN ANALYZE
SELECT b.id, u.email, p.title, b.status, b.checkin, b.checkout
FROM bookings b
JOIN users u      ON u.id = b.user_id
JOIN properties p ON p.id = b.property_id
WHERE b.status = 'confirmed';
-- expected: Seq Scan on bookings and/or Hash Join without useful indexes

-- AFTER
EXPLAIN ANALYZE
SELECT b.id, u.email, p.title, b.status, b.checkin, b.checkout
FROM bookings b
JOIN users u      ON u.id = b.user_id
JOIN properties p ON p.id = b.property_id
WHERE b.status = 'confirmed';
-- expected: Bitmap/Index scans on FK columns; fewer rows visited

-- BEFORE
EXPLAIN ANALYZE
SELECT id, title, city, status
FROM properties
WHERE city = 'Madrid' AND status = 'active'
ORDER BY created_at DESC
LIMIT 50;
-- expected: Seq Scan + explicit Sort

-- AFTER
EXPLAIN ANALYZE
SELECT id, title, city, status
FROM properties
WHERE city = 'Madrid' AND status = 'active'
ORDER BY created_at DESC
LIMIT 50;
-- expected: index supports filter; order uses created_at index (less or no explicit sort)
-- BEFORE
EXPLAIN ANALYZE
SELECT id, email
FROM users
WHERE email = 'alice@example.com';
-- expected: Seq Scan on users
-- AFTER
EXPLAIN ANALYZE
SELECT id, email
FROM users
WHERE email = 'alice@example.com';
-- expected: Index Scan using idx_users_email


```sql
-- database-adv-script/database_index.sql

-- USERS
CREATE INDEX IF NOT EXISTS idx_users_email       ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at  ON users(created_at);

-- BOOKINGS
CREATE INDEX IF NOT EXISTS idx_bookings_user_id          ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id      ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_checkin_checkout ON bookings(checkin, checkout);
CREATE INDEX IF NOT EXISTS idx_bookings_status           ON bookings(status);
-- Optional partial for confirmed-only queries
CREATE INDEX IF NOT EXISTS idx_bookings_confirmed ON bookings(id) WHERE status = 'confirmed';

-- PROPERTIES
CREATE INDEX IF NOT EXISTS idx_properties_city_status ON properties(city, status);
CREATE INDEX IF NOT EXISTS idx_properties_created_at  ON properties(created_at DESC);
