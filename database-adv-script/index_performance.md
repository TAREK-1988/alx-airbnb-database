Index Performance Measurements (Before vs After)
Repo path: database-adv-script/index_performance.md
Tooling: psql with EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
1) Bookings by user with date filter
Before indexes
-- BEFORE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.*
FROM bookings b
WHERE b.user_id = 123
  AND b.checkin  >= DATE '2025-01-01'
  AND b.checkout <  DATE '2025-02-01';
After indexes
Indexes used (see database_index.sql):
idx_bookings_user_id ON bookings(user_id)
idx_bookings_checkin_checkout ON bookings(checkin, checkout)
-- AFTER
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.*
FROM bookings b
WHERE b.user_id = 123
  AND b.checkin  >= DATE '2025-01-01'
  AND b.checkout <  DATE '2025-02-01';
Observation: plan switches from Seq Scan on bookings to Bitmap Index Scan/Index Scan using idx_bookings_user_id and idx_bookings_checkin_checkout, with fewer buffers read and lower total time.
2) Join: bookings → users → properties (common dashboard query)
Before indexes
-- BEFORE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.id, u.email, p.title, b.status, b.checkin, b.checkout
FROM bookings b
JOIN users u      ON u.id = b.user_id
JOIN properties p ON p.id = b.property_id
WHERE b.status = 'confirmed';
After indexes
Indexes used:
idx_bookings_property_id ON bookings(property_id)
(optional) partial index for confirmed: CREATE INDEX IF NOT EXISTS idx_bookings_confirmed ON bookings(id) WHERE status='confirmed';
Foreign-key join helpers already in database_index.sql.
-- AFTER
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.id, u.email, p.title, b.status, b.checkin, b.checkout
FROM bookings b
JOIN users u      ON u.id = b.user_id
JOIN properties p ON p.id = b.property_id
WHERE b.status = 'confirmed';
Observation: join strategy improves (nested loop/bitmap heap) and uses indexes on FK columns; fewer rows visited and lower cost.
3) Properties search by city & status with ordering
Before indexes
-- BEFORE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, title, city, status
FROM properties
WHERE city = 'Madrid' AND status = 'active'
ORDER BY created_at DESC
LIMIT 50;
After indexes
Indexes used:
idx_properties_city_status ON properties(city, status)
idx_properties_created_at ON properties(created_at DESC)
-- AFTER
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, title, city, status
FROM properties
WHERE city = 'Madrid' AND status = 'active'
ORDER BY created_at DESC
LIMIT 50;
Observation: filter uses composite index; ORDER BY can use the created_at index to avoid full sort; noticeable drop in total time.
4) Users lookup by email (login flow)
Before indexes
-- BEFORE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, email
FROM users
WHERE email = 'alice@example.com';
After indexes
Index used:
idx_users_email ON users(email)
-- AFTER
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, email
FROM users
WHERE email = 'alice@example.com';
Observation: switches from sequential scan to index scan on users(email); lookups become O(log N).
How we measured
Ran each query before creating indexes, captured EXPLAIN (ANALYZE, BUFFERS) plan.
Applied indexes from database_index.sql.
Re-ran the same queries and compared:
Scan type: Seq Scan ➜ Index Scan/Bitmap Index Scan.
Fewer buffers/read I/O and lower execution time.
Representative outputs show the plan change and confirm index usage.
Notes
For very small datasets the time may look similar; the win appears with realistic volumes.
Consider VACUUM ANALYZE after bulk loads to refresh stats so the planner prefers the new indexes.
