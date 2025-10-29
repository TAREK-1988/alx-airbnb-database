/* ===========================================================
 Task 3 — Implement Indexes for Optimization
 File: database-adv-script/database_index.sql
 Goal: Show BEFORE/AFTER measurements using EXPLAIN ANALYZE
       and create the required indexes.
=========================================================== */

-- =========================
-- BEFORE: performance checks
-- =========================

-- 1) Bookings by user within a date range
EXPLAIN ANALYZE
SELECT b.*
FROM bookings b
WHERE b.user_id = 123
  AND b.checkin  >= DATE '2025-01-01'
  AND b.checkout <  DATE '2025-02-01';

-- 2) Join: bookings → users → properties (confirmed only)
EXPLAIN ANALYZE
SELECT b.id, u.email, p.title, b.status, b.checkin, b.checkout
FROM bookings b
JOIN users u      ON u.id = b.user_id
JOIN properties p ON p.id = b.property_id
WHERE b.status = 'confirmed';

-- 3) Properties search by city & status with ordering
EXPLAIN ANALYZE
SELECT id, title, city, status
FROM properties
WHERE city = 'Madrid' AND status = 'active'
ORDER BY created_at DESC
LIMIT 50;

-- 4) Users lookup by email (login flow)
EXPLAIN ANALYZE
SELECT id, email
FROM users
WHERE email = 'alice@example.com';

-- =========================================
-- CREATE INDEX statements (optimization set)
-- =========================================

-- USERS
CREATE INDEX IF NOT EXISTS idx_users_email       ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_created_at  ON users(created_at);

-- BOOKINGS
CREATE INDEX IF NOT EXISTS idx_bookings_user_id          ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id      ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_checkin_checkout ON bookings(checkin, checkout);
CREATE INDEX IF NOT EXISTS idx_bookings_status           ON bookings(status);
-- Optional partial index for confirmed-only filters
CREATE INDEX IF NOT EXISTS idx_bookings_confirmed ON bookings(id) WHERE status = 'confirmed';

-- PROPERTIES
CREATE INDEX IF NOT EXISTS idx_properties_city_status ON properties(city, status);
CREATE INDEX IF NOT EXISTS idx_properties_created_at  ON properties(created_at DESC);

-- ========================
-- AFTER: performance checks
-- (same queries, expected to use indexes)
-- ========================

-- 1) Bookings by user within a date range
EXPLAIN ANALYZE
SELECT b.*
FROM bookings b
WHERE b.user_id = 123
  AND b.checkin  >= DATE '2025-01-01'
  AND b.checkout <  DATE '2025-02-01';

-- 2) Join: bookings → users → properties (confirmed only)
EXPLAIN ANALYZE
SELECT b.id, u.email, p.title, b.status, b.checkin, b.checkout
FROM bookings b
JOIN users u      ON u.id = b.user_id
JOIN properties p ON p.id = b.property_id
WHERE b.status = 'confirmed';

-- 3) Properties search by city & status with ordering
EXPLAIN ANALYZE
SELECT id, title, city, status
FROM properties
WHERE city = 'Madrid' AND status = 'active'
ORDER BY created_at DESC
LIMIT 50;

-- 4) Users lookup by email (login flow)
EXPLAIN ANALYZE
SELECT id, email
FROM users
WHERE email = 'alice@example.com';
