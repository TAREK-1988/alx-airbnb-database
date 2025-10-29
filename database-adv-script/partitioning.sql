/* ===========================================================
 Task 5 — Partition bookings by start_date (PostgreSQL 16)
 Safe plan: keep original `bookings`, create `bookings_partitioned`,
 copy data, and expose a view `bookings_all`.
 Schema assumptions (from your repo):
   bookings(booking_id UUID PK, user_id UUID, property_id UUID,
            status TEXT, checkin DATE, checkout DATE, created_at TIMESTAMP)
   users(user_id UUID), properties(property_id UUID)
=========================================================== */

-- 0) Ensure start_date exists on original bookings (generated from checkin)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='bookings' AND column_name='start_date'
  ) THEN
    ALTER TABLE bookings
      ADD COLUMN start_date DATE GENERATED ALWAYS AS (checkin) STORED;
  END IF;
END $$;

-- 1) Create partitioned parent (drop old copy if present)
DROP TABLE IF EXISTS bookings_partitioned CASCADE;
CREATE TABLE bookings_partitioned (
  booking_id   UUID PRIMARY KEY,
  user_id      UUID NOT NULL,
  property_id  UUID NOT NULL,
  status       TEXT,
  checkin      DATE,
  checkout     DATE,
  start_date   DATE NOT NULL,   -- partition key
  created_at   TIMESTAMP
) PARTITION BY RANGE (start_date);

-- 2) Foreign keys on the parent (optional but useful)
ALTER TABLE bookings_partitioned
  ADD CONSTRAINT fk_bp_user
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE bookings_partitioned
  ADD CONSTRAINT fk_bp_property
    FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE CASCADE;

-- 3) Yearly partitions (adjust ranges as needed)
CREATE TABLE IF NOT EXISTS bookings_p_2024 PARTITION OF bookings_partitioned
  FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

CREATE TABLE IF NOT EXISTS bookings_p_2025 PARTITION OF bookings_partitioned
  FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');

CREATE TABLE IF NOT EXISTS bookings_p_2026 PARTITION OF bookings_partitioned
  FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');

-- default partition (anything outside defined ranges)
CREATE TABLE IF NOT EXISTS bookings_p_default PARTITION OF bookings_partitioned DEFAULT;

-- 4) Indexes per partition (match common joins/filters)
CREATE INDEX IF NOT EXISTS idx_b2024_user_id       ON bookings_p_2024(user_id);
CREATE INDEX IF NOT EXISTS idx_b2025_user_id       ON bookings_p_2025(user_id);
CREATE INDEX IF NOT EXISTS idx_b2026_user_id       ON bookings_p_2026(user_id);
CREATE INDEX IF NOT EXISTS idx_bdef_user_id        ON bookings_p_default(user_id);

CREATE INDEX IF NOT EXISTS idx_b2024_property_id   ON bookings_p_2024(property_id);
CREATE INDEX IF NOT EXISTS idx_b2025_property_id   ON bookings_p_2025(property_id);
CREATE INDEX IF NOT EXISTS idx_b2026_property_id   ON bookings_p_2026(property_id);
CREATE INDEX IF NOT EXISTS idx_bdef_property_id    ON bookings_p_default(property_id);

CREATE INDEX IF NOT EXISTS idx_b2024_status_date   ON bookings_p_2024(status, start_date);
CREATE INDEX IF NOT EXISTS idx_b2025_status_date   ON bookings_p_2025(status, start_date);
CREATE INDEX IF NOT EXISTS idx_b2026_status_date   ON bookings_p_2026(status, start_date);
CREATE INDEX IF NOT EXISTS idx_bdef_status_date    ON bookings_p_default(status, start_date);

CREATE INDEX IF NOT EXISTS idx_b2024_checkin_out   ON bookings_p_2024(checkin, checkout);
CREATE INDEX IF NOT EXISTS idx_b2025_checkin_out   ON bookings_p_2025(checkin, checkout);
CREATE INDEX IF NOT EXISTS idx_b2026_checkin_out   ON bookings_p_2026(checkin, checkout);
CREATE INDEX IF NOT EXISTS idx_bdef_checkin_out    ON bookings_p_default(checkin, checkout);

-- 5) Copy existing data into partitions
INSERT INTO bookings_partitioned (booking_id, user_id, property_id, status, checkin, checkout, start_date, created_at)
SELECT booking_id, user_id, property_id, status, checkin, checkout, start_date, created_at
FROM bookings;

-- 6) Analyze for fresh stats
VACUUM (ANALYZE) bookings_partitioned;
VACUUM (ANALYZE) bookings_p_2024;
VACUUM (ANALYZE) bookings_p_2025;
VACUUM (ANALYZE) bookings_p_2026;
VACUUM (ANALYZE) bookings_p_default;

-- 7) Compatibility view to read from partitioned data
DROP VIEW IF EXISTS bookings_all;
CREATE VIEW bookings_all AS
SELECT * FROM bookings_partitioned;

-- Done.
