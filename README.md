# database-script-0x-02

This folder contains the seed data SQL script for the Airbnb clone database.

## Files
- **seed.sql**: SQL INSERT statements to populate the database with sample users, properties, bookings, payments, reviews and messages.

## Notes
- The script uses UUID generators for primary keys (e.g., gen_random_uuid() for PostgreSQL). Replace with `UUID()` if using MySQL.
- Ensure you run `schema.sql` first before running this seed script.
