-- Users table: email used in WHERE
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Bookings table: used in WHERE, JOIN, ORDER BY
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status_start_end ON bookings(status, start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_bookings_start_date ON bookings(start_date DESC);

-- Properties table: used in WHERE and ORDER BY
CREATE INDEX IF NOT EXISTS idx_properties_city_country_price ON properties(country, city, price_per_night);
