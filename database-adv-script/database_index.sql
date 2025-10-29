CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings(property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_checkin_checkout ON bookings(checkin, checkout);
CREATE INDEX IF NOT EXISTS idx_bookings_confirmed_checkout ON bookings(checkout) WHERE status = 'confirmed';

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE INDEX IF NOT EXISTS idx_properties_city ON properties(city);
CREATE INDEX IF NOT EXISTS idx_properties_host_id ON properties(host_id);

CREATE INDEX IF NOT EXISTS idx_reviews_booking_created ON reviews(booking_id, created_at);

CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments(booking_id);
