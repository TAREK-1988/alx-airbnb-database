# Database Normalization for Airbnb Clone

## 1NF (First Normal Form)
- Ensure each table has atomic values and a primary key.
- No repeating groups or arrays in a single column.

## 2NF (Second Normal Form)
- Must be in 1NF.
- All non-key attributes fully depend on the primary key (no partial dependencies).

## 3NF (Third Normal Form)
- Must be in 2NF.
- No transitive dependencies: non-key columns must depend only on the primary key.

## Conclusion
- Users, Properties, Bookings, Payments, Reviews, and Messages are separate tables.
- Foreign keys link related records to avoid redundancy.
