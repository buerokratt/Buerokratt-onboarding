# MIG-001: Sample Data Population for All Database Tables

## Context
To ensure that **newly created, updated, and existing database tables function as expected**, all tables must be validated by inserting **sample data**. This ensures that schema modifications do not introduce unexpected errors and that tables are **capable of accepting new data**.

To maintain **consistency and automation**, sample data insertions must be handled through **separate pipelines**, with data read from **external CSV files**. Additionally, **emptying sample tables** must be **triggerable separately**, ensuring flexibility during testing.

## Decision

1. **All newly created, updated, and existing database tables must be populated with sample data.**
1. **Sample data must be read from an external CSV file** corresponding to each table.
1. **Data insertions must be handled via a separate pipeline** and must not be mixed with schema modifications.
1. **A separate process must allow triggering the removal of all sample data** without affecting production data.
1. **Sample data must be non-sensitive** and should not include real-world confidential information.
1. **Sample population must occur in a dedicated testing environment**, not in production.

## Example: Correct and Incorrect Sample Data Handling

### Forbidden (Hardcoded Sample Data in Schema Migration)
```sql
-- This should NOT be done within schema migrations
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL
);

INSERT INTO users (id, name) VALUES ('123e4567-e89b-12d3-a456-426614174000', 'Sample User');
```

### Use (Using an External CSV for Sample Data Insertion)
**Sample Data File** (`users_sample.csv`)

```csv
id,name
123e4567-e89b-12d3-a456-426614174001,John Doe
123e4567-e89b-12d3-a456-426614174002,Jane Smith
```

**Sample Data Insertion Script** (`load_sample_data.sql`)
```sql
COPY users (id, name)
FROM '/path/to/users_sample.csv'
DELIMITER ','
CSV HEADER;
```

### Use (Triggerable Sample Data Removal)
```sql
DELETE FROM users;
```

## Implementation Pipeline
1. **A pipeline must handle sample data insertion** for all tables after schema changes are applied.
1. **CSV files must be structured** to match the database schema format for smooth loading.
1. **A separate pipeline must allow triggering the removal of sample data** on demand.
1. **Validation checks must be performed** after inserting sample data to ensure that tables accept new records correctly.

## Consequences

**Positive Outcomes**
- **Ensures that all tables accept new data correctly** after schema changes.
- **Keeps schema changes and data insertions separate,** maintaining a clean migration process.
- **Provides an automated way to populate test databases** with structured sample data.
- **Allows controlled removal of sample data,** preventing test pollution.

**Potential Trade-offs**
- **Requires maintaining CSV files for each table,** increasing overhead.
- **Sample data pipelines must be maintained separately** from database migrations.
- **Developers must ensure test data does not contain sensitive or production data.**

---

# MIG-002: Historical Data Filtering and Migration

## Context
To **minimize the risk of data exposure** during a database breach and to **maintain an optimized production database**, historical records that have **lost operational relevance** must be identified and migrated to a secure backup location. These records **must not remain in the production database** once they are deemed irrelevant.

Since the system enforces the use of **denormalized database tables** (see related ADRs), historical data filtering and migration must follow the same principle, ensuring that each table remains independent and **does not rely on cross-table relationships for identifying stale records**.

## Decision

- **Each database table must have a stand-alone pipeline** for detecting and migrating historical data.
- **Data filtering criteria must be explicitly defined per table**, following operational requirements.
- **No cross-table joins are allowed** for detecting irrelevant data (following ADR on denormalized tables).
- **Historical records must be removed from the production database** and securely archived.
- **Archived data must remain accessible but must not affect active queries.**
- **Archived data storage must be isolated** from production and follow security best practices.
- **Automated migration jobs must be scheduled** at predefined intervals to enforce this rule consistently.

## Consequences

**Positive Outcomes**
- **Reduces the risk of data breaches** by limiting the amount of exposed production data.
- **Maintains optimized query performance** by keeping only relevant records in production.
- **Ensures compliance with denormalization rules,** preventing cross-table dependencies.
- **Provides structured and secure historical data storage** for auditing purposes.

**Potential Trade-offs**
- **Requires a scheduled migration process,** increasing operational complexity.
- **Archived data retrieval requires separate queries,** adding minor overhead for reporting.
- **Strict enforcement of deletion rules is necessary** to prevent production database growth.
