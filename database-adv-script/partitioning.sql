/* ===========================================================
 Task 5 — Partitioning the bookings table by start_date (PostgreSQL 16)
 Safe migration without breaking existing FKs:
 - keep original bookings as-is
 - create bookings_partitioned (parent) + yearly partitions
 - copy data
 - provide a read-only view bookings_all (union of partitions)
=========================================================== */

-- 0) Ensure extension for gen UUID if needed (optional)
-- CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 1) Add start_date if missing (generated from checkin)
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

-- 2) Create partitioned parent table (same columns subset; adjust types to your schema)
-- Note: we don't drop/rename original bookings to avoid breaking FKs.
-- You can later switch application reads to the view (bookings_all).
DROP TABLE IF EXISTS bookings_partitioned CASCADE;
CREATE TABLE bookings_partitioned (
  booking_id   UUID PRIMARY KEY,
  user_id      UUID NOT NULL,
  property_id  UUID NOT NULL,
  status       TEXT,
  checkin      DATE,
  checkout     DATE,
  start_date   DATE NOT NULL,          -- partition key
  created_at   TIMESTAMP
) PARTITION BY RANGE (start_date);

-- (Optional) Recreate FKs on the parent (they will apply logically to inserts):
ALTER TABLE bookings_partitioned
  ADD CONSTRAINT fk_bookings_user
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE;

ALTER TABLE bookings_partitioned
  ADD CONSTRAINT fk_bookings_property
    FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE CASCADE;

-- 3) Yearly partitions (adjust ranges to your dataset window)
-- 2024
CREATE TABLE IF NOT EXISTS bookings_p_2024 PARTITION OF bookings_partitioned
  FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');
-- 2025
CREATE TABLE IF NOT EXISTS bookings_p_2025 PARTITION OF bookings_partitioned
  FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');
-- 2026
CREATE TABLE IF NOT EXISTS bookings_p_2026 PARTITION OF bookings_partitioned
  FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');
-- default (anything outside the above ranges)
CREATE TABLE IF NOT EXISTS bookings_p_default PARTITION OF bookings_partitioned DEFAULT;

-- 4) Indexes per-partition (Postgres requires per-partition indexes)
-- Note: create the same set of indexes you rely on
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

-- 5) Copy data from the original table into partitions
-- Make sure column order matches
INSERT INTO bookings_partitioned (booking_id, user_id, property_id, status, checkin, checkout, start_date, created_at)
SELECT booking_id, user_id, property_id, status, checkin, checkout, start_date, created_at
FROM bookings;

-- 6) Optional but recommended: analyze for fresh stats
VACUUM (ANALYZE) bookings_partitioned;
VACUUM (ANALYZE) bookings_p_2024;
VACUUM (ANALYZE) bookings_p_2025;
VACUUM (ANALYZE) bookings_p_2026;
VACUUM (ANALYZE) bookings_p_default;

-- 7) Read-only compatibility view to query all partitioned data
DROP VIEW IF EXISTS bookings_all;
CREATE VIEW bookings_all AS
SELECT * FROM bookings_partitioned;

-- Tip: For app code, you can switch reads from "bookings" -> "bookings_all"
-- without touching existing FKs on the original "bookings".
