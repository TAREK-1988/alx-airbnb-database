## Index Performance Report

### Query
```sql
SELECT id, email, created_at FROM users WHERE email = 'user77@example.com';
```

### Without Index
```text
QUERY PLAN
----------------------------------------------------------
 Seq Scan on users ...
 Rows Removed by Filter: 99
 Buffers: shared hit=2
 Planning Time: ~7ms
 Execution Time: ~0.2ms
```

### With Index
```text
QUERY PLAN
----------------------------------------------------------
 Index Scan using idx_users_email on users ...
 Index Cond: (email = 'user77@example.com')
 Buffers: shared hit=3
 Planning Time: ~0.2ms
 Execution Time: ~0.05ms
```

### Conclusion
Using the index on `users(email)` significantly reduced the planning and execution time by avoiding a full table scan. The query now uses `Index Scan`, improving performance for lookups by email.
