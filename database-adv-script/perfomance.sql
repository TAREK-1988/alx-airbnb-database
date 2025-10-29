-- Initial complex query for Task 4 (before refactor)
-- Retrieves all bookings with user, property, and payment details

SELECT
  b.id                AS booking_id,
  b.user_id,
  b.property_id,
  b.status            AS booking_status,
  b.checkin,
  b.checkout,
  u.id                AS user_id_join,
  u.full_name,
  u.email,
  p.id                AS property_id_join,
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
