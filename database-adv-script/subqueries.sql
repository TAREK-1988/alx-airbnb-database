/* ===========================================================
   Task 1 — Practice Subqueries
   Objective:
   1) Non-correlated subquery: properties with AVG rating > 4.0
   2) Correlated subquery: users with more than 3 bookings
   Assumes:
     - bookings(booking_id, user_id, property_id, ...)
     - properties(property_id, ...)
     - reviews(review_id, booking_id, rating, created_at, ...)
     - users(user_id, name, email, ...)
=========================================================== */

-- 1) Non-correlated subquery: properties whose average rating > 4.0
SELECT p.property_id
FROM properties p
WHERE (
  SELECT AVG(r.rating)
  FROM bookings b
  JOIN reviews r ON r.booking_id = b.booking_id
  WHERE b.property_id = p.property_id
) > 4.0
ORDER BY p.property_id;

-- 2) Correlated subquery: users who made more than 3 bookings
SELECT u.user_id, u.name, u.email
FROM users u
WHERE (
  SELECT COUNT(*)
  FROM bookings b
  WHERE b.user_id = u.user_id
) > 3
ORDER BY u.user_id;
