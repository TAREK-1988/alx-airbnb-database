/* ===========================================================
 Task 3 — Implement Indexes for Optimization (PostgreSQL)
 Matches UUID schema: users(user_id), properties(property_id), bookings(booking_id, user_id, property_id)
=========================================================== */

-- =======================
-- Bookings
-- =======================
CREATE INDEX IF NOT EXISTS idx_bookings_user_id            ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id        ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_checkin_checkout   ON bookings(checkin, checkout);
CREATE INDEX IF NOT EXISTS idx_bookings_status_checkin     ON bookings(status, checkin);

-- Partial index for confirmed bookings
CREATE INDEX IF NOT EXISTS idx_bookings_confirmed_checkout
  ON bookings(checkout)
  WHERE status = 'confirmed';

-- =======================
-- Properties
-- (create if column exists to avoid errors on missing columns)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema='public' AND table_name='properties' AND column_name='city'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_properties_city ON properties(city)';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema='public' AND table_name='properties' AND column_name='host_id'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_properties_host_id ON properties(host_id)';
  END IF;
END $$;

-- =======================
-- Users
CREATE INDEX IF NOT EXISTS idx_users_email                 ON users(email);

-- =======================
-- Reviews
CREATE INDEX IF NOT EXISTS idx_reviews_property_id         ON reviews(property_id);

-- =======================
-- Payments
CREATE INDEX IF NOT EXISTS idx_payments_booking_id         ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_paid_at            ON payments(paid_at);
