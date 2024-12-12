# Architectural Decision Records (ADRs) for Relational Database Queries

## ADR-001: File Organization and Structure

### **Context**
To ensure modularity and maintainability, all database queries will be stored as stand-alone `.sql` files. Queries will be grouped by type (`POST` and `GET`) and further sub-categorized based on modules or features.

### **Decision**
- Each query will reside in a dedicated `.sql` file.
- Files will be organized under `POST` and `GET` folders.
- Subfolders must be used to group queries by related modules or features.

### **Consequences**
- Improves organization and facilitates modular development.
- Simplifies tracking and management of queries.

---

## ADR-002: Naming Conventions

### **Context**
Consistent naming conventions are critical for query discoverability and uniformity across the project.

### **Decision**
- File names will follow the convention: `{action}_{resource}_{operation}.sql`.
- Use descriptive names that avoid ambiguity or reserved words.
- Example: `get_customer_details.sql`, `post_order_create.sql`.

### **Consequences**
- Enhances readability and searchability.
- Reduces confusion during development and maintenance.

---

## ADR-003: Security Declarations in Queries

### **Context**
To ensure secure query execution and facilitate the generation of OpenAPI specifications, each `.sql` file must include security declarations.

### **Decision**
- Every `.sql` file will declare:
  - Allowed request type (`GET` or `POST`).
  - Expected input structure (parameters and their data types).
  - Expected output structure (fields and types).
- Metadata must be provided in comments for easy parsing.

### **Consequences**
- Improves security by defining and validating inputs and outputs.
- Simplifies the creation of API documentation.

---

## ADR-004: Liquibase Compatibility

### **Context**
Liquibase will be used for database version control and migration management to ensure consistency and traceability of database schema changes.

### **Decision**
- Liquibase must be used for any changes to the database schema, including table modifications, field updates, and other structural adjustments.
- Query `.sql` files will remain stand-alone and not include Liquibase-specific headers or metadata.

### **Consequences**
- Ensures a clear separation between query logic and schema migration.
- Maintains modularity and reusability of `.sql` query files.
- Provides robust version control and easy rollback of schema changes.

---

## ADR-005: Query Parameterization

### **Context**
Parameterized queries are essential to prevent SQL injection vulnerabilities and ensure reusability.

### **Decision**
- Queries must use parameterized inputs (e.g., `:input_param`, `:another_param`) instead of hardcoding values.
- Example:
  ```sql
  SELECT field1, field2 FROM customers WHERE id = :input_param AND customer_name = :another_param;
  ```

### **Consequences**
- Enhances security by mitigating SQL injection risks.
- Promotes reusability of queries.

---

## ADR-006: Searchable Query Declarations

### **Context**
Reusability and discoverability of queries are critical to reduce redundancy and improve maintainability.

### **Decision**
- Query declarations (security and metadata) must be structured in a way that allows automated indexing and searching.
- An external tool will be used to parse `.sql` files and generate an index for searching based on declarations.

### **Consequences**
- Simplifies finding and reusing existing queries.
- Reduces duplication and enhances maintainability.

---

## ADR-007: Testing and Validation

### **Context**
Automated testing ensures that queries function as expected and meet performance requirements.

### **Decision**
- Each query will have associated test cases to validate:
  - Syntax correctness.
  - Input-output validation.
  - Performance benchmarks.
- Tests will be automated as part of the CI pipeline.

### **Consequences**
- Ensures reliability and correctness of queries.
- Identifies performance bottlenecks early.

---

## ADR-008: Standardized SQL Formatting

### **Context**
Consistency in SQL formatting improves readability and reduces errors during code reviews.

### **Decision**
- Use standardized formatting, including:
  - Capitalized SQL keywords (e.g., `SELECT`, `FROM`, `WHERE`).
  - Indentation and alignment for readability.
- Adopt a linting tool such as `SQLFluff` to enforce formatting.

### **Consequences**
- Improves readability and reduces review time.
- Ensures consistency across all queries.

---

## ADR-009: Execution expectations as comments

### **Context**
Providing metadata comments for execution expectations helps ensure clarity regarding the expected performance and behavior of queries. This metadata serves as a reference for developers and aids in performance monitoring and optimization.

### **Decision**
- Every `.sql` file must include metadata comments specifying execution expectations:
  - **Expected Runtime**: The anticipated average runtime for the query under normal conditions.
  - **Expected Input Size**: The estimated size of data inputs for which the query is optimized.
  - **Performance Constraints**: Any known limitations or considerations.

### **Examples**
```sql
-- Expected Runtime: < 100ms
-- Expected Input Size: Up to 10,000 rows
-- Performance Constraints: Optimized for indexed fields only
SELECT id, name FROM customers WHERE status = :status_param;
```

### **Consequences**
- Promotes transparency and accountability regarding query performance.
- Aids in identifying and addressing performance bottlenecks.
- Improves collaboration by providing clear expectations to all stakeholders.

---

## ADR-010: Prohibition of `SELECT *`

### **Context**
Using `SELECT *` in SQL queries can lead to inefficiencies, unintended data exposure, and maintainability issues. Explicitly specifying required columns improves query performance and ensures clarity.

### **Decision**
- `SELECT *` is not allowed in any query.
- All columns to be retrieved must be explicitly listed in the query.
  ```sql
  SELECT id, name, email FROM customers WHERE status = :status_param;
  ```

### **Consequences**
- Reduces ambiguity in query results.
- Improves performance by retrieving only necessary columns.
- Enhances maintainability by making query structure explicit.

---

## ADR-011: Allowed Query Types

### **Context**
Restricting the types of SQL queries allowed ensures better control, maintainability, and security within the system.

### **Decision**
- Only `INSERT` and `SELECT` queries will be allowed.
- Any other query types (e.g., `UPDATE`, `DELETE`, `DROP`) are strictly prohibited.

### **Consequences**
- Ensures data integrity by disallowing destructive operations.
- Simplifies query auditing and monitoring.
- Promotes a read-and-append model for data handling.

---

## ADR-012: Prohibition of Cross-Table Joins

### **Context**
Allowing cross-table joins can lead to significant performance bottlenecks, unintended dependencies, and challenges in maintaining the state of individual tables.

### **Decision**
- Cross-table joins or similar operations are strictly prohibited.
- Each table must maintain its state independently.
- Queries interacting with multiple tables must handle data aggregation or reconciliation at the application layer instead of the database layer.

### **Consequences**
- Simplifies database design and maintenance.
- Improves performance by avoiding expensive join operations.
- Ensures clear separation of concerns between data storage and processing.

---

## ADR-013: Historical Data Filtering and Migration

### **Context**
To minimize the risk of data exposure during a database breach, historical entries that have lost their operational relevance must be identified and moved to a secure backup location. These entries should not remain in the production database.

### **Decision**
- Queries to filter and move outdated data must:
  - Be implemented as separate `.sql` files, triggered by scheduled cron jobs.
  - Include metadata linking them to the operational queries they are derived from.
  - Ensure that all removed data is backed up securely before deletion from the production database.

### **Examples**
```sql
-- Linked Query: get_customer_details.sql
-- Description: Archive inactive customer records older than 5 years.
-- Execution Frequency: Weekly
INSERT INTO backup_customers (id, name, email, archived_at)
SELECT id, name, email, NOW()
FROM customers
WHERE last_active_date < NOW() - INTERVAL '5 years';

DELETE FROM customers
WHERE last_active_date < NOW() - INTERVAL '5 years';
```

### **Consequences**
- Reduces the amount of historical data in the production database, minimizing the potential impact of breaches.
- Ensures historical data is preserved in a secure location.
- Improves production database performance by reducing its size.

---
