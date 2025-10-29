SET search_path = public;

-- ===== USERS =====
CREATE INDEX IF NOT EXISTS idx_users_email         ON users (email);
CREATE INDEX IF NOT EXISTS idx_users_created_at    ON users (created_at);
CREATE INDEX IF NOT EXISTS idx_users_country_city  ON users (country, city);
CREATE INDEX IF NOT EXISTS idx_users_lower_email   ON users ((lower(email)));

-- ===== PROPERTIES =====
CREATE INDEX IF NOT EXISTS idx_properties_country_city_price
  ON properties (country, city, price_per_night);
CREATE INDEX IF NOT EXISTS idx_properties_host_created
  ON properties (host_id, created_at);
CREATE INDEX IF NOT EXISTS idx_properties_price     ON properties (price_per_night);

-- ===== BOOKINGS =====
-- توفر العقار في نافذة تاريخية
CREATE INDEX IF NOT EXISTS idx_bookings_property_start_end
  ON bookings (property_id, start_date, end_date);

-- تاريخ حجوزات المستخدم
CREATE INDEX IF NOT EXISTS idx_bookings_user_start
  ON bookings (user_id, start_date);

-- تتبع الحالة زمنياً
CREATE INDEX IF NOT EXISTS idx_bookings_status_created
  ON bookings (status, created_at);

CREATE INDEX IF NOT EXISTS idx_bookings_created_at  ON bookings (created_at);

-- فهرس جزئي على المؤكدة فقط (يحسّن استعلامات التوفر)
CREATE INDEX IF NOT EXISTS idx_bookings_confirmed_property_window
  ON bookings (property_id, start_date, end_date)
  WHERE status = 'confirmed';

-- فهارس JOIN مساعدة (لو غير موجودة)
CREATE INDEX IF NOT EXISTS idx_bookings_user_id     ON bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings (property_id);
