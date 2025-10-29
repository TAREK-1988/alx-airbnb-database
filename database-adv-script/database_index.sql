/* ===========================================================
 Task 3 — Implement Indexes for Optimization
 Target: users, bookings, properties (+ reviews, payments للوصول الشائع)
 Dialect: PostgreSQL
=========================================================== */

-- قبل القياس يفضل تحديث الإحصاءات:
-- ANALYZE;

-- ===== Bookings =====
-- ربطات/فلاتر شائعة: user_id, property_id, checkin/checkout, status
CREATE INDEX IF NOT EXISTS idx_bookings_user_id          ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id      ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_checkin_checkout ON bookings(checkin, checkout);

-- Partial index يفيد الاستعلامات على المؤكد فقط
CREATE INDEX IF NOT EXISTS idx_bookings_confirmed_checkout
  ON bookings(checkout)
  WHERE status = 'confirmed';

-- ===== Users =====
-- للوصول بالبريد أو uniqueness (لو عندك unique constraint اكتفي به)
CREATE INDEX IF NOT EXISTS idx_users_email               ON users(email);

-- ===== Properties =====
CREATE INDEX IF NOT EXISTS idx_properties_city           ON properties(city);
CREATE INDEX IF NOT EXISTS idx_properties_host_id        ON properties(host_id);

-- ===== Reviews =====
-- للربط عبر booking والتصفية الزمنية
CREATE INDEX IF NOT EXISTS idx_reviews_booking_created   ON reviews(booking_id, created_at);

-- ===== Payments =====
CREATE INDEX IF NOT EXISTS idx_payments_booking_id       ON payments(booking_id);

/* ملاحظات MySQL:
- احذف WHERE من الفهرس الجزئي (غير مدعوم)، وأنشئ فهرس عادي على checkout،
  أو استخدم فهرس مركب (status, checkout) حسب استعلاماتك.
- صيغة CREATE INDEX متطابقة تقريبًا بدون IF NOT EXISTS في إصدارات قديمة.
*/
