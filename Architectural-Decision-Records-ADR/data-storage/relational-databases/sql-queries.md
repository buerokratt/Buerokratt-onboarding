# SQL-001: Enforce Standardized SQL Formatting

## Context
Consistency in SQL formatting is essential for readability, maintainability, and reducing errors during code reviews. Without a standardized format, SQL queries become harder to debug, review, and maintain over time. Enforcing a strict formatting standard ensures uniformity across all queries and improves collaboration between developers.

## Decision
- **SQL keywords must be capitalized** (e.g., `SELECT`, `FROM`, `WHERE`).
- **Indentation and alignment must be used** to enhance readability.
- **Column and table names must follow snake_case** to maintain naming consistency.

### Example

#### Avoid (Unformatted SQL)
```sql
select id,name,email from users where status='active' order by name;
```

#### Use (Standardized SQL Formatting)

```sql
SELECT id, name, email
FROM users
WHERE status = 'active'
ORDER BY name;
```

## Consequences

### Positive Outcomes
- **Improves readability** by maintaining a structured and predictable format.
- **Reduces review time** by ensuring queries follow a consistent style.
- **Prevents syntax errors** caused by misaligned or unclear formatting.
- **Facilitates collaboration,** making it easier for developers to read and modify SQL code.

### Potential Trade-offs
- Some existing queries **may need reformatting.**
