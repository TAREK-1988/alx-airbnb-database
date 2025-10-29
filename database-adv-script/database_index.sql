/* ===========================================================
 Task 3 — Implement Indexes for Optimization
 Target tables: users, bookings, properties, reviews, payments
 Dialect: PostgreSQL
 Notes:
 - ركّزنا على أعمدة WHERE / JOIN / ORDER BY
 - استخدمنا IF NOT EXISTS لتفادي الأخطاء عند إعادة التشغيل
 - بعد إنشاء الإندكسات يفضّل تشغيل VACUUM (ANALYZE)
=========================================================== */

-- يفضّل بعد تغييرات كبيرة:
-- VACUUM (ANALYZE);

-- =======================
-- Bookings
-- =======================
-- روابط شائعة: user_id, property_id
CREATE INDEX IF NOT EXISTS idx_bookings_user_id          ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id      ON bookings(property_id);

-- استعلامات المدى الزمني وفلاتر الحالة
CREATE INDEX IF NOT EXISTS idx_bookings_checkin_checkout ON bookings(checkin, checkout);
CREATE INDEX IF NOT EXISTS idx_bookings_status_checkin   ON bookings(status, checkin);

-- Partial index للحجوزات المؤكدة (يُستخدم مع WHERE status='confirmed')
CREATE INDEX IF NOT EXISTS idx_bookings_confirmed_checkout
  ON bookings(checkout)
  WHERE status = 'confirmed';

-- =======================
-- Properties
-- =======================
-- أمثلة فلاتر/ترتيب شائعة على properties
CREATE INDEX IF NOT EXISTS idx_properties_city        ON properties(city);
CREATE INDEX IF NOT EXISTS idx_properties_host_id     ON properties(host_id);

-- =======================
-- Users
-- =======================
-- Lookups متكررة بالبريد
CREATE INDEX IF NOT EXISTS idx_users_email            ON users(email);

-- =======================
-- Reviews (اختياري لو مستخدمة كثيرًا في التقارير/الرتبة)
-- =======================
CREATE INDEX IF NOT EXISTS idx_reviews_property_id    ON reviews(property_id);

-- =======================
-- Payments
-- =======================
-- Join شائع مع bookings + ترتيب زمني
CREATE INDEX IF NOT EXISTS idx_payments_booking_id    ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_paid_at       ON payments(paid_at);

-- ملاحظة:
-- - بعد إنشاء الإندكسات: يفضّل ANALYZE لتحديث الإحصاءات.
-- - للتأكد من الاستخدام: EXPLAIN (ANALYZE, BUFFERS) على الاستعلامات المستهدفة.
