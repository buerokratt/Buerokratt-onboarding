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

---

# SQL-004: Restriction on Allowed SQL Query Types

## Context
Restricting the types of SQL queries that can be executed ensures better control, maintainability, and security within the system. Allowing only non-destructive queries enforces a read-and-append model, reducing the risk of data corruption, accidental deletions, or unauthorized modifications.

## Decision
- **Only `INSERT` and `SELECT` queries are allowed.**
- **All other query types** (e.g., `UPDATE`, `DELETE`, `DROP`, `ALTER`) **are strictly prohibited.**
- **Data modifications must be handled through alternative mechanisms**, such as versioned inserts or soft deletes.

### Example

#### Allowed (`SELECT` Query)
```sql
SELECT id, name, email
FROM customers
WHERE status = :status_param;
```

#### Allowed (`INSERT` Query)
```sql
INSERT INTO customers (id, name, email, status)
VALUES (:id_param, :name_param, :email_param, :status_param);
```

#### Prohibited (`UPDATE` Query)
```sql
UPDATE customers
SET status = 'inactive'
WHERE id = :id_param;
```

#### Prohibited (`UPDATE` Query)
```sql
DELETE FROM customers
WHERE status = 'inactive';
```

## Consequences

### Positive Outcomes
- **Ensures data integrity** by disallowing destructive operations.
- **Simplifies auditing and monitoring,** as data is never modified or deleted.
- **Promotes a read-and-append model,** making historical data fully traceable.
- **Reduces risk of accidental data loss,** enforcing a more controlled approach to data changes.

### Potential Trade-offs
- **Increased storage usage** since data cannot be modified or deleted directly.
- **Requires application-level handling** for changes, such as versioned updates or soft deletes.
- **May introduce additional complexity** in data retrieval when dealing with historical records.

---

# SQL-005: Prohibition of Cross-Table Joins and Enforced Separation of Database Tables

## Context
Allowing cross-table joins can introduce performance bottlenecks, unintended dependencies, and challenges in scaling database operations. Additionally, enforcing clear separation of database tables ensures structured data management and prevents unnecessary entanglement of unrelated datasets. Queries should retrieve full, meaningful results directly from individual tables without relying on database-level joins for aggregation.

## Decision
- **Each database table must be designed for a specific purpose** and store all necessary data for its function.
- **Cross-table joins are strictly prohibited.** Queries must not perform `JOIN` operations between multiple tables.
- **Tables must be structured to return complete, meaningful results on their own**, minimizing the need for additional processing.
- **Application-level data merging is allowed but should be kept minimal.** The intended approach is to retrieve **full results from applicable database tables** instead of assembling fragmented data at the application level.
- **Denormalization must be applied** to ensure that queries do not depend on external tables for execution.

### Example

#### Prohibited (Cross-Table Join Query)
```sql
SELECT customers.id, customers.name, orders.total_price
FROM customers
JOIN orders ON customers.id = orders.customer_id
WHERE customers.status = 'active';
```

#### Preferred (Separate Tables With Self-Contained Data)
```sql
SELECT id, name, status
FROM customers
WHERE status = 'active';

SELECT customer_id, total_price
FROM orders;
```

#### Allowed (Minimal Application-Level Data Merging)
Instead of joining in SQL, fetch relevant data from each table separately and merge only when necessary:
```sql
customers = db.execute("SELECT id, name FROM customers WHERE status = 'active'")
orders = db.execute("SELECT customer_id, total_price FROM orders WHERE customer_id IN (:customer_ids)")

# Merge only if absolutely necessary
customer_orders = merge_data(customers, orders)
```

## Consequences

### Positive Outcomes
- **Ensures database tables remain independent and purpose-driven,** avoiding complex dependencies.
- **Eliminates expensive join operations,** improving query performance and reducing execution time.
- **Enhances scalability,** allowing distributed database design without cross-table constraints.
- **Encourages structured data retrieval,** ensuring that each table provides full results on its own.
- **Minimizes application-level data merging,** reducing processing overhead.

### Potential Trade-offs
- **Requires careful database design** to ensure tables store all necessary data independently.
- **Increases data redundancy** in favor of performance and maintainability.
- **Application logic must be optimized** to handle minimal but necessary data merging when required.
