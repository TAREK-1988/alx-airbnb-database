cp database-adv-script/database_index.sql database-adv-script/database_index.sql.bak

cat > database-adv-script/database_index.sql <<'SQL'
/* ===========================================================
 Task 3 — Implement Indexes for Optimization (PostgreSQL)
 Safe version: checks columns before creating indexes
 Matches UUID schema: users(user_id), properties(property_id), bookings(booking_id, user_id, property_id)
=========================================================== */

-- =======================
-- Users
-- =======================
CREATE INDEX IF NOT EXISTS idx_users_email                 ON users(email);
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='users' AND column_name='created_at'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at)';
  END IF;
END $$;

-- =======================
-- Properties
-- =======================
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

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='properties' AND column_name='price'
  ) THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_properties_price ON properties(price)';
  END IF;
END $$;

-- =======================
-- Bookings
-- =======================
CREATE INDEX IF NOT EXISTS idx_bookings_user_id            ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id        ON bookings(property_id);

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='bookings' AND column_name='checkin')
     AND EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_schema='public' AND table_name='bookings' AND column_name='checkout') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_bookings_checkin_checkout ON bookings(checkin, checkout)';
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='bookings' AND column_name='status') THEN
    IF EXISTS (SELECT 1 FROM information_schema.columns
               WHERE table_schema='public' AND table_name='bookings' AND column_name='checkin') THEN
      EXECUTE 'CREATE INDEX IF NOT EXISTS idx_bookings_status_checkin ON bookings(status, checkin)';
    END IF;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='bookings' AND column_name='status')
     AND EXISTS (SELECT 1 FROM information_schema.columns
                 WHERE table_schema='public' AND table_name='bookings' AND column_name='checkout') THEN
    EXECUTE $$CREATE INDEX IF NOT EXISTS idx_bookings_confirmed_checkout
             ON bookings(checkout) WHERE status = 'confirmed'$$;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.columns
             WHERE table_schema='public' AND table_name='bookings' AND column_name='created_at') THEN
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_bookings_created_at ON bookings(created_at)';
  END IF;
END $$;

-- =======================
-- Reviews
-- =======================
CREATE INDEX IF NOT EXISTS idx_reviews_property_id         ON reviews(property_id);

-- =======================
-- Payments
-- =======================
CREATE INDEX IF NOT EXISTS idx_payments_booking_id         ON payments(booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_paid_at            ON payments(paid_at);
SQL
