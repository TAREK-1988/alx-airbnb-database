# Partitioning Performance Report — PostgreSQL 16.10

## Setup
- Implemented **range partitioning** on `start_date`.
- Parent table: `bookings_partitioned`
- Partitions: `bookings_p_2024`, `bookings_p_2025`, `bookings_p_2026`, and `bookings_p_default`.
- Added a compatibility view: `bookings_all` to read unified data.

## Query Tested
Confirmed bookings in **Q1 2025** (date range filter to benefit from pruning):

```sql
-- BEFORE (non-partitioned): FROM bookings
SELECT 
  b.booking_id, b.status, b.checkin, b.checkout,
  u.user_id, (u.first_name || ' ' || u.last_name) AS user_name,
  p.property_id, p.title
FROM bookings b
JOIN users u      ON u.user_id     = b.user_id
JOIN properties p ON p.property_id = b.property_id
WHERE b.checkin >= DATE '2025-01-01'
  AND b.checkin <  DATE '2025-04-01'
  AND b.status = 'confirmed';

-- AFTER (partitioned): FROM bookings_all (partitioned parent view)
SELECT 
  b.booking_id, b.status, b.checkin, b.checkout,
  u.user_id, (u.first_name || ' ' || u.last_name) AS user_name,
  p.property_id, p.title
FROM bookings_all b
JOIN users u      ON u.user_id     = b.user_id
JOIN properties p ON p.property_id = b.property_id
WHERE b.start_date >= DATE '2025-01-01'
  AND b.start_date <  DATE '2025-04-01'
  AND b.status = 'confirmed';
