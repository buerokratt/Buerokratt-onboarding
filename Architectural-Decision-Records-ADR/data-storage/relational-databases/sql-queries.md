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

---

# SQL-002: Execution Expectation Comments for SQL Queries

## Context
Providing metadata comments for execution expectations ensures clarity regarding the expected performance and behavior of SQL queries. These comments serve as documentation for developers, aiding in performance monitoring, troubleshooting, and optimization. By explicitly defining execution expectations, we improve transparency, accountability, and collaboration in database query development.

## Decision
1. **Every `.sql` file must include metadata comments** specifying execution expectations.
2. **Metadata comments must be placed at the top of each SQL file**.
3. **Required metadata fields:**
<br>&emsp;3.1. **Expected Runtime** – The anticipated average runtime for the query under normal conditions.
<br>&emsp;3.2. **Expected Input Size** – The estimated size of data inputs for which the query is optimized.
<br>&emsp;3.3. **Performance Constraints** – Any known limitations or considerations.

### Example

#### Avoid (Missing Execution Metadata)

```sql
SELECT id, name  
FROM customers  
WHERE status = :status_param;
```

#### **Use (Including Execution Metadata)**
```sql
-- Expected Runtime: < 100ms
-- Expected Input Size: Up to 10,000 rows
-- Performance Constraints: Optimized for indexed fields only

SELECT id, name
FROM customers
WHERE status = :status_param;
```

## Consequences

### Positive Outcomes
- **Improves readability** by maintaining a structured and predictable format.
- **Reduces review time** by ensuring queries follow a consistent style.
- **Prevents syntax errors** caused by misaligned or unclear formatting.
- **Facilitates collaboration,** making it easier for developers to read and modify SQL code.

### Potential Trade-offs
- Existing queries **may need reformatting.**

---

# SQL-003: Prohibition of `SELECT *` in SQL Queries

## Context
Using `SELECT *` in SQL queries can lead to inefficiencies, unintended data exposure, and maintainability issues. Fetching all columns from a table may cause performance bottlenecks, especially when dealing with large datasets. Additionally, queries that rely on `SELECT *` are more prone to breaking if schema changes introduce new columns. By explicitly specifying required columns, queries remain clear, predictable, and optimized.

## Decision
- **`SELECT *` is strictly prohibited** in all SQL queries.
- **All retrieved columns must be explicitly listed** in the query.
- **Queries must be optimized to fetch only the necessary fields**, avoiding unnecessary data retrieval.

### Example

#### **Avoid (`SELECT *` Fetches All Columns)**
```sql
SELECT *
FROM customers
WHERE status = :status_param;
```

#### Use (Explicit Column Selection)
```sql
SELECT id, name, email
FROM customers
WHERE status = :status_param;
```

## Consequences

### Positive Outcomes
- **Reduces ambiguity** in query results, making queries more predictable.
- **Improves performance** by retrieving only the necessary data, reducing memory and I/O load.
- **Enhances maintainability,** ensuring queries remain stable even when table structures change.
- **Minimizes risk of unintended data exposure,** as only explicitly required columns are fetched.

### Potential Trade-offs
- **Requires careful query design** to ensure all required fields are explicitly selected.
- **Query needs to be updated** if new columns are needed.
