-- BEFORE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.*
FROM bookings b
WHERE b.user_id = 123
  AND b.checkin  >= DATE '2025-01-01'
  AND b.checkout <  DATE '2025-02-01';

-- AFTER
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.*
FROM bookings b
WHERE b.user_id = 123
  AND b.checkin  >= DATE '2025-01-01'
  AND b.checkout <  DATE '2025-02-01';

-- BEFORE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.id, u.email, p.title, b.status, b.checkin, b.checkout
FROM bookings b
JOIN users u      ON u.id = b.user_id
JOIN properties p ON p.id = b.property_id
WHERE b.status = 'confirmed';


-- AFTER
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT b.id, u.email, p.title, b.status, b.checkin, b.checkout
FROM bookings b
JOIN users u      ON u.id = b.user_id
JOIN properties p ON p.id = b.property_id
WHERE b.status = 'confirmed';

-- BEFORE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, title, city, status
FROM properties
WHERE city = 'Madrid' AND status = 'active'
ORDER BY created_at DESC
LIMIT 50;
-- AFTER
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, title, city, status
FROM properties
WHERE city = 'Madrid' AND status = 'active'
ORDER BY created_at DESC
LIMIT 50;

-- BEFORE
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, email
FROM users
WHERE email = 'alice@example.com';

-- AFTER
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT id, email
FROM users
WHERE email = 'alice@example.com';
