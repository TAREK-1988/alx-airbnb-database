/* ===========================================================
   Task 0 — Complex Queries with Joins
   File  : joins_queries.sql
   Schema: assumes -> users, bookings, properties, reviews
            (bookings.user_id -> users.user_id)
            (bookings.property_id -> properties.property_id)
            (reviews.booking_id -> bookings.booking_id)
   Dialect: PostgreSQL (MySQL notes inline)
   =========================================================== */

/* A) INNER JOIN — كل الحجوزات مع المستخدمين الذين قاموا بها */
SELECT
  b.booking_id,
  b.property_id,
  b.checkin,
  b.checkout,
  b.status,
  u.user_id,
  u.name      AS user_name,
  u.email     AS user_email
FROM bookings b
INNER JOIN users u
  ON u.user_id = b.user_id
ORDER BY b.booking_id;

/* B) LEFT JOIN — كل العقارات مع مراجعاتها (حتى العقارات بلا مراجعات)
   الربط عبر bookings -> reviews لأن التقييم مرتبط بالحجز */
SELECT
  p.property_id,
  p.city,
  r.review_id,
  r.rating,
  r.created_at AS review_created_at
FROM properties p
LEFT JOIN bookings b
  ON b.property_id = p.property_id
LEFT JOIN reviews r
  ON r.booking_id = b.booking_id
ORDER BY p.property_id, r.created_at NULLS LAST;
/* MySQL لا يدعم NULLS LAST → استخدم:
   ORDER BY p.property_id, (r.created_at IS NULL), r.created_at; */

/* C) FULL OUTER JOIN — كل المستخدمين وكل الحجوزات حتى لو غير مرتبطين */
-- PostgreSQL:
SELECT
  u.user_id,
  u.name  AS user_name,
  b.booking_id,
  b.property_id,
  b.checkin,
  b.status
FROM users u
FULL OUTER JOIN bookings b
  ON b.user_id = u.user_id
ORDER BY COALESCE(u.user_id, -1), COALESCE(b.booking_id, -1);

-- MySQL بديل (FULL OUTER JOIN غير مدعوم):
-- SELECT
--   u.user_id, u.name AS user_name,
--   b.booking_id, b.property_id, b.checkin, b.status
-- FROM users u
-- LEFT JOIN bookings b ON b.user_id = u.user_id
-- UNION
-- SELECT
--   u.user_id, u.name AS user_name,
--   b.booking_id, b.property_id, b.checkin, b.status
-- FROM users u
-- RIGHT JOIN bookings b ON b.user_id = u.user_id
-- ORDER BY COALESCE(u.user_id, -1), COALESCE(b.booking_id, -1);

