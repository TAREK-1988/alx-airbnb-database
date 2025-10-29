-- Initial complex query to fetch booking, user, property, and payment details
SELECT
  b.id AS booking_id,
  u.full_name,
  u.email,
  p.title AS property_title,
  p.city,
  pay.amount,
  pay.status AS payment_status,
  b.start_date,
  b.end_date,
  b.status AS booking_status
FROM bookings b
JOIN users u ON b.user_id = u.id
JOIN properties p ON b.property_id = p.id
LEFT JOIN payments pay ON pay.booking_id = b.id;
