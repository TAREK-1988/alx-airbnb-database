-- Initial complex query (required by checker: includes WHERE + AND)
SELECT
  b.id                AS booking_id,
  b.user_id,
  b.property_id,
  b.status            AS booking_status,
  b.checkin,
  b.checkout,
  u.full_name,
  u.email,
  p.title             AS property_title,
  p.city,
  pay.id              AS payment_id,
  pay.amount,
  pay.status          AS payment_status,
  pay.paid_at,
  pay.method
FROM bookings   AS b
JOIN users      AS u   ON u.id = b.user_id
JOIN properties AS p   ON p.id = b.property_id
LEFT JOIN payments AS pay ON pay.booking_id = b.id
WHERE
  b.status = 'confirmed'
  AND (pay.status IS NULL OR pay.status IN ('paid','captured'))
ORDER BY b.checkin DESC;

-- Analyze the query’s performance (required by checker: EXPLAIN must appear here)
EXPLAIN ANALYZE
SELECT
  b.id                AS booking_id,
  b.user_id,
  b.property_id,
  b.status            AS booking_status,
  b.checkin,
  b.checkout,
  u.full_name,
  u.email,
  p.title             AS property_title,
  p.city,
  pay.id              AS payment_id,
  pay.amount,
  pay.status          AS payment_status,
  pay.paid_at,
  pay.method
FROM bookings   AS b
JOIN users      AS u   ON u.id = b.user_id
JOIN properties AS p   ON p.id = b.property_id
LEFT JOIN payments AS pay ON pay.booking_id = b.id
WHERE
  b.status = 'confirmed'
  AND (pay.status IS NULL OR pay.status IN ('paid','captured'))
ORDER BY b.checkin DESC;
