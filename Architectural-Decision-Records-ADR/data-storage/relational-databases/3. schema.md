# SCHEMA-001: Mandatory Use of Defined Schemas Instead of `public` in PostgreSQL

## Context  
By default, PostgreSQL places all tables, functions, and other database objects in the `public` schema. This approach **lacks structure, increases security risks, and makes permission management more difficult**.  

To enforce **better database organization, security, and maintainability**, all database objects must be placed in **explicitly defined schemas** instead of using `public`.  

## Decision  

1. **All database objects (tables, indexes, views, stored procedures, etc.) must be placed in explicitly defined schemas.**  
1. **The `public` schema may not be used** for any application-related database objects.  
1. **Each functional area or service must have its own schema** (e.g., `auth`, `orders`, `users`).  
1. **Schemas must be explicitly referenced in queries** when necessary.  
1. **Permissions must be granted at the schema level**, preventing unnecessary exposure.  

## Example

### **Prohibited (Using the `public` Schema)**  
```sql
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);
```

### Use (Using a Defined Schema)
```sql
CREATE SCHEMA auth;

CREATE TABLE auth.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL
);
```

### Use (Setting Default Schema for Role-Based Access Control)
```sql
ALTER ROLE app_user SET search_path TO auth;
```

## Consequences

**Positive Outcomes**
- **Improves database organization** by separating concerns into functional schemas.
- **Enhances security** by restricting schema access to specific roles.
- **Reduces risk of accidental exposure,** as objects are not placed in public.
- **Facilitates better permission management,** allowing granular access control.

**Potential Trade-offs**
- **Requires additional schema setup and management.**
- **Queries must explicitly reference schemas** if `search_path` is not set.
- **Existing databases using** `public` **will require migration** to a defined schema.

---

# SCHEMA-002: Use UUIDs for All Objects

## Context
To ensure **consistent object identification** across distributed systems, all database objects must use **UUIDs** as their primary identifier instead of incremental IDs. Additionally, in **denormalized structures**, uniqueness constraints should be avoided where possible to improve performance and maintain flexibility in data replication and caching scenarios.

## Decision

1. All objects **must use UUIDs** as their primary key (`uuid DEFAULT gen_random_uuid()` in PostgreSQL).
2. **Using incremental integer IDs is forbidden**, as it create conflicts in distributed environments.

### Example

#### Use (Using UUID as Primary Key)
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Use (Using multiple UUIDs)
```sql
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    status ENUM('pending', 'completed', 'failed') NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Forbidden (Using AUTO_INCREMENT)
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,  -- ❌ Auto-increment is not allowed
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Consequences

**Positive Outcomes**
- **Globally Unique Identifiers** – Ensures object uniqueness across distributed environments.
- **Better Scalability** – UUIDs allow horizontal scaling without risk of primary key collisions.
- **Flexible Denormalized Data** – Avoiding unique constraints in denormalized structures allows better replication, caching, and historical logging.

**Potential Trade-offs**
- **Slightly Larger Storage Size** – UUIDs take more space (16 bytes) compared to integers (4-8 bytes).
- **Slower Index Performance** – UUID-based indexes can be less efficient than sequential integer-based indexes.
- **Application-Level Validation Required** – Since uniqueness is not enforced in denormalized tables, application logic must handle potential duplicates.

---

# SCHEMA-003: Mandatory Use of ENUM Data Type Where Applicable

## Context
Using **ENUM** for predefined categorical values improves **data integrity, readability, and query efficiency** by restricting values to a **fixed set**. This approach reduces storage requirements, minimizes errors, and partially replaces documentation by making valid values explicit in the schema.

By enforcing **ENUM usage where applicable**, we ensure that databases maintain **consistent, structured categorical data** instead of relying on loosely validated text fields.

## Decision

- **ENUM must be used for columns containing a fixed set of possible values** (e.g., statuses, categories, types).
- **Plain `TEXT` or `VARCHAR` must not be used** when ENUM is applicable.
- **All ENUM values must be explicitly defined at table creation** and should not be stored as separate lookup tables unless dynamic changes to values are required.
- **ENUM values must be documented in the schema** to improve maintainability.

## Example

### Use (Using ENUM for Predefined Values)
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status ENUM('pending', 'processing', 'shipped', 'delivered', 'canceled') NOT NULL
);
```

### Forbidden (Using TEXT Instead of ENUM for Fixed Values)
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    status TEXT NOT NULL-- Incorrect: Status should be ENUM instead of TEXT
);
```

## Implementation Guidelines
1. **Use ENUM for categorical data that does not frequently change** (e.g., order statuses, user roles).
1. **Document ENUM values in database schema comments** to provide clarity for developers.

## Consequences

**Positive Outcomes**
- **Ensures data consistency,** preventing invalid values.
- **Reduces storage size,** as ENUM is stored as integers internally.
- **Improves readability,** making valid values explicit in the schema.
- **Enhances query performance,** reducing indexing overhead compared to TEXT columns.

**Potential Trade-offs**
- **Schema changes required** if new ENUM values need to be added.
- **Less flexibility** compared to storing values in a separate lookup table.
- **ENUMs cannot be modified dynamically** without altering the schema.

---

# SCHEMA-004: Mandatory Indexing for Optimized Query Performance

## Context
Indexes improve **query performance** by allowing the database engine to locate data more efficiently. Without proper indexing, queries that filter, sort, or group large datasets can cause **performance bottlenecks**.

Given the **denormalized structure** of our database (see related ADRs), indexing plays an even more **critical role** in ensuring that queries execute efficiently without relying on joins.

## Decision

1. **Indexes must be created for all columns used in**:
<br>&emsp;1.1. `WHERE` conditions
<br>&emsp;1.2. `ORDER BY` clauses
<br>&emsp;1.3. `GROUP BY` operations
2. **Primary keys are always indexed by default** (e.g., UUID-based primary keys).
3. **Indexes must be explicitly created for frequently queried columns** to prevent full table scans.
4. **Unique constraints must be enforced with unique indexes** instead of application-side validation.
5. **Composite indexes must be used when multiple columns are always queried together.**
6. **Avoid over-indexing**, as excessive indexes can **slow down insert/update operations**.

## Example

### Prohibited (No Indexing on Frequently Queried Columns)
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    order_date TIMESTAMPTZ DEFAULT NOW(),
    status ENUM('pending', 'shipped', 'delivered', 'canceled') NOT NULL
);
```

### Use (Indexing Frequently Queried Columns)
```sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL,
    order_date TIMESTAMPTZ DEFAULT NOW(),
    status ENUM('pending', 'shipped', 'delivered', 'canceled') NOT NULL
);

-- Index on customer_id to speed up customer lookups
CREATE INDEX idx_orders_customer ON orders (customer_id);

-- Index on order_date for efficient sorting and filtering
CREATE INDEX idx_orders_date ON orders (order_date);

-- Index on status for quick filtering
CREATE INDEX idx_orders_status ON orders (status);
```

### Preferred (Composite Index for Multi-Column Queries)
Composite indexes are more efficient when multiple columns are always queried together.

```sql
-- When queries frequently filter by both customer_id and order_date:
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date);
```

## Guidelines for Indexing Strategy
1. **Always index primary keys** (automatic for `PRIMARY KEY`).
1. **Create indexes on frequently filtered, sorted, or grouped columns.**
1. **Use composite indexes for multi-column filtering** (but only when necessary).
1. **Unique constraints must be enforced using** `UNIQUE INDEX`.
1. **Avoid redundant or excessive indexes,** as they slow down inserts and updates.
1. **Regularly analyze query performance** to optimize indexing strategy.


## Consequences

**Positive Outcomes**
- **Speeds up queries** by avoiding full table scans.
- **Improves efficiency in filtering, sorting, and aggregations.**
- **Ensures database performance scales as data grows.**
- **Reduces database load,** improving system stability.

**Potential Trade-offs**
- **Excessive indexing increases storage usage.**
- **Indexes slow down insert, update, and delete operations.**
- **Requires ongoing performance monitoring** to adjust indexes based on query patterns.

---

# SCHEMA-005: Mandatory Use of `TEXT` Instead of `VARCHAR` in PostgreSQL

## Context
PostgreSQL **treats `TEXT` and `VARCHAR` identically** in terms of performance and storage. The only difference is that `VARCHAR(n)` enforces a character length limit, which is **redundant when validation should be handled at the application level**.

Using `TEXT` simplifies schema management, **avoids unnecessary constraints**, and ensures **consistent data handling** across all tables.

## Decision

- **`TEXT` must be used instead of `VARCHAR` for all string-based columns.**
- **`VARCHAR(n)` is strictly prohibited**, as it provides no benefit in PostgreSQL.
- **Length validation must be handled at the application level**, not the database level.
- **Indexes on `TEXT` columns must be created where necessary** to optimize queries.

## Example

### Use (`TEXT` Instead of `VARCHAR`)
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT NOT NULL,  -- Allowed
    email TEXT UNIQUE NOT NULL  -- Allowed
);
```

### **Prohibited (`VARCHAR(n)` with Length Constraint)**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) NOT NULL,-- Not allowed
    email VARCHAR(255) UNIQUE NOT NULL-- Not allowed
);
```

## Consequences

**Positive Outcomes**
- **Simplifies schema management,** as length constraints are no longer required.
- **Reduces the need for schema modifications** when length requirements change.
- **Optimizes PostgreSQL performance,** as `TEXT` and `VARCHAR(n)` behave the same.
- **Encourages application-layer validation,** allowing more flexibility.

**Potential Trade-offs**
- **Developers must enforce length constraints at the application level.**
- **Lack of length constraints in the database may lead to unexpected large inputs if not validated properly.**
