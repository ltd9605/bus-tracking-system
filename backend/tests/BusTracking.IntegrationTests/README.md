# Integration tests

Add real-MySQL integration tests using isolated databases (e.g., Testcontainers),
covering migrations, optimistic concurrency, unique assignments, authentication,
transactional outbox, and SignalR authorization. Do **not** use EF InMemory to
claim concurrency correctness.
