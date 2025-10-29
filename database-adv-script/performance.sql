-- Initial (Unoptimized) Query
-- This joins all bookings with user, property, and payment details
SELECT b.id AS booking_id,
       u.full_name,
       u.email,
       p.title AS property_title,
       pay.amount,
       b.start_date,
       b.end_date,
       b.status
FROM bookings b
JOIN users u ON b.user_id = u.id
JOIN properties p ON b.property_id = p.id
LEFT JOIN payments pay ON pay.booking_id = b.id;


-- Optimized Version
-- Adds LIMIT for batching, avoids unnecessary columns, and assumes proper indexes on:
-- bookings(user_id), bookings(property_id), payments(booking_id)
EXPLAIN (ANALYZE, BUFFERS)
SELECT b.id, u.full_name, p.title, pay.amount
FROM bookings b
JOIN users u ON b.user_id = u.id
JOIN properties p ON b.property_id = p.id
LEFT JOIN payments pay ON pay.booking_id = b.id
ORDER BY b.created_at DESC
LIMIT 100;
