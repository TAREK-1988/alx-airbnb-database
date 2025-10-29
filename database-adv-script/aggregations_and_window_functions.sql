/* ===========================================================
   Task 2 — Aggregations & Window Functions
   Objective:
   1) إجمالي عدد الحجوزات لكل مستخدم (COUNT + GROUP BY)
   2) ترتيب العقارات حسب إجمالي الحجوزات (RANK/ROW_NUMBER)
   Assumes tables:
     users(user_id, name, email, ...)
     bookings(booking_id, user_id, property_id, status, checkin, checkout, ...)
     properties(property_id, city, room_type, ...)
=========================================================== */

-- 1) إجمالي عدد الحجوزات لكل مستخدم
SELECT
  u.user_id,
  u.name,
  COUNT(b.booking_id) AS total_bookings
FROM users u
LEFT JOIN bookings b
  ON b.user_id = u.user_id
GROUP BY u.user_id, u.name
ORDER BY total_bookings DESC, u.user_id;

-- 2) ترتيب العقارات حسب إجمالي الحجوزات التي استلمتها
WITH booking_counts AS (
  SELECT
    p.property_id,
    COUNT(b.booking_id) AS bookings_count
  FROM properties p
  LEFT JOIN bookings b
    ON b.property_id = p.property_id
       AND b.status = 'confirmed'      -- اختياري: اعتبر الحجوزات المؤكدة فقط
  GROUP BY p.property_id
)
SELECT
  property_id,
  bookings_count,
  RANK()       OVER (ORDER BY bookings_count DESC) AS rnk,
  ROW_NUMBER() OVER (ORDER BY bookings_count DESC) AS row_num
FROM booking_counts
ORDER BY rnk, property_id;
