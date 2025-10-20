-- Seed sample data

-- Users
INSERT INTO users (user_id, first_name, last_name, email, password_hash, phone_number, role)
VALUES
(gen_random_uuid(), 'Tarek', 'Sayed', 'tarek@example.com', 'hashed_pw', '01000000001', 'host'),
(gen_random_uuid(), 'Mona', 'Ali', 'mona@example.com', 'hashed_pw', '01000000002', 'guest'),
(gen_random_uuid(), 'Ahmed', 'Khaled', 'ahmed@example.com', 'hashed_pw', '01000000003', 'guest');

-- Properties
INSERT INTO properties (property_id, host_id, name, description, location, price_per_night)
VALUES
(gen_random_uuid(), (SELECT user_id FROM users WHERE email='tarek@example.com'), 'Modern Apartment in Zamalek', '2-bedroom with Nile view', 'Zamalek, Cairo', 950.00),
(gen_random_uuid(), (SELECT user_id FROM users WHERE email='tarek@example.com'), 'Beach House', 'Seaside villa', 'Alexandria', 1250.00);

-- Bookings (example using placeholders)
INSERT INTO bookings (booking_id, property_id, user_id, start_date, end_date, total_price, status)
VALUES
(gen_random_uuid(), (SELECT property_id FROM properties WHERE name='Modern Apartment in Zamalek'), (SELECT user_id FROM users WHERE email='mona@example.com'), '2025-10-10', '2025-10-15', 4750.00, 'confirmed');

-- Payments
INSERT INTO payments (payment_id, booking_id, amount, payment_method)
VALUES
(gen_random_uuid(), (SELECT booking_id FROM bookings LIMIT 1), 4750.00, 'credit_card');

-- Reviews
INSERT INTO reviews (review_id, property_id, user_id, rating, comment)
VALUES
(gen_random_uuid(), (SELECT property_id FROM properties WHERE name='Modern Apartment in Zamalek'), (SELECT user_id FROM users WHERE email='mona@example.com'), 5, 'Amazing stay!');

-- Messages
INSERT INTO messages (message_id, sender_id, recipient_id, message_body)
VALUES
(gen_random_uuid(), (SELECT user_id FROM users WHERE email='mona@example.com'), (SELECT user_id FROM users WHERE email='tarek@example.com'), 'Hi Tarek, I loved the apartment!');
