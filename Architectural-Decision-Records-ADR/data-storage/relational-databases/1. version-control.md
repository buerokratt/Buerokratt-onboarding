# VC-001: Use Liquibase for Database Schema Management

## Context
To ensure consistency, traceability, and controlled schema modifications, Liquibase is required for all database schema changes. This approach guarantees that all changes are versioned, auditable, and reversible, reducing the risk of unintended modifications and schema drift across environments.

## Decision
1. **Liquibase must be used for all database schema modifications**, including:
<br>&emsp;1.1. Table creation and deletion.
<br>&emsp;1.2. Column additions, deletions, and modifications.
<br>&emsp;1.3. Index and constraint updates.
<br>&emsp;1.4. Other structural adjustments.
2. **Direct schema modifications (manual DDL execution) are strictly prohibited** outside Liquibase-managed migrations.
3. **Liquibase changelogs must be stored in version control** to maintain a history of schema changes.
4. **All environments (development, test, production) must apply schema changes exclusively through Liquibase** to ensure consistency.

## Consequences

**Positive Outcomes:**
- **Enforces version-controlled database changes**, reducing schema drift.
- **Simplifies rollbacks** by keeping a structured history of modifications.
- **Enhances collaboration** by providing a standardized way to apply schema updates.
- **Ensures consistency across environments**, preventing out-of-sync database states.

**Potential Trade-offs:**
- **Requires Liquibase setup and maintenance** in all database environments.
- **Developers must follow Liquibase syntax and structure**, adding a slight learning curve.

---

# VC-002: Enforcing SQL-Only for All Database Schema Changes

## Context
To maintain full control over database schema changes, all modifications must be written in SQL. This ensures that
- Native SQL execution is preserved, without relying on Liquibase-specific abstraction layers.
- Developers have full visibility into how database changes are applied.
- Debugging, optimization, and performance tuning can be done using standard SQL tools.
- Database portability and long-term maintainability are improved by preventing reliance on Liquibase's XML, YAML, or JSON schema definitions.

> [!NOTE]
> This ADR focuses **only on enforcing SQL for all schema changes**. The **tracking of changes via Liquibase XML** is covered in a separate ADR.

## Decision
1. **All schema changes must be defined in pure SQL files (`.sql`).**
2. **Liquibase XML/YAML/JSON must not be used for defining schema changes.**
3. **SQL must be the only source of truth for all:**
<br>&emsp;3.1. Table creation, deletion, and modifications.
<br>&emsp;3.2. Column additions, deletions, and changes.
<br>&emsp;3.3. Index and constraint management.
<br>&emsp;3.4. Stored procedures, triggers, and functions.
<br>&emsp;3.5. Any other database structure modifications.
4. **Rollback logic must be explicitly defined in SQL** instead of relying on Liquibase auto-generated rollbacks.

## Example

### Use (Using Pure SQL for Schema Changes)
```sql
--liquibase formatted sql
--changeset dev:005
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    amount NUMERIC NOT NULL
);

--rollback DROP TABLE transactions;
```

### Forbidden (Liquibase XML for Schema Changes)
```xml
<changeSet id="005" author="dev">
    <createTable tableName="transactions">
        <column name="id" type="UUID" />
        <column name="amount" type="NUMERIC" />
    </createTable>
</changeSet>
```

## Consequences

**Positive Outcomes**
- Ensures **all schema modifications remain in SQL,** maintaining database-native execution.
- **Prevents dependency on Liquibase-specific syntax,** making the database easier to manage.
- **Improves maintainability and performance** tuning with standard SQL tools.
- **Ensures explicit rollback definitions,** avoiding unexpected Liquibase-generated rollbacks.

**Potential Trade-offs**
- Developers **must manually define rollback logic.**
- **Loses some Liquibase automation benefits** for schema tracking (handled in a separate ADR).

---

# VC-003: Enforcing Liquibase XML for Change Tracking and Validations

## Context
Liquibase provides execution tracking, validations, and rollback management that cannot be fully handled using pure SQL. To ensure consistency, auditing, and controlled database changes, Liquibase XML must be used for these functionalities while keeping all schema modifications in SQL.

This ADR enforces the use of **XML as the only allowed format** for Liquibase tracking to maintain consistency across the project. **YAML and JSON are strictly prohibited.**

## Decision
1. **Liquibase XML must be used for tracking and validating database changes.**
2. **All schema changes must be defined in external `.sql` files**, which Liquibase XML files must reference.
3. **Liquibase YAML and JSON formats are strictly prohibited** to maintain a consistent tracking standard.
4. **Liquibase XML files must only be used for:**
<br>&emsp;4.1. **Change tracking and version control**
<br>&emsp;4.2. **Preconditions** (e.g., ensuring a table does not exist before creating it)
<br>&emsp;4.3. **Rollback definitions**
<br>&emsp;4.4. **Execution order enforcement**
<br>&emsp;4.5. **Environment-based execution control** (e.g., running specific changes in dev but not in production)
5. **Liquibase XML must not contain actual SQL statements**, only references to SQL files.

## Example

### Use (Using Liquibase XML for Tracking and Calling SQL Files)
```xml
<databaseChangeLog>
    <changeSet id="006" author="dev">
        <preConditions onFail="MARK_RAN">
            <not>
                <tableExists tableName="logs"/>
            </not>
        </preConditions>
        <sqlFile path="migrations/006_create_logs.sql" />
        <rollback>
            <sqlFile path="migrations/rollback/006_rollback.sql" />
        </rollback>
    </changeSet>
</databaseChangeLog>
```

### Forbidden (Using Liquibase XML for Schema Changes Instead of SQL)
```xml
<changeSet id="006" author="dev">
    <createTable tableName="logs">
        <column name="id" type="UUID" />
        <column name="message" type="TEXT" />
    </createTable>
</changeSet>
```

## Consequences

**Positive Outcomes**
- Ensures Liquibase’s **tracking and validation features are used effectively.**
- Keeps SQL as the **single source of truth for schema changes.**
- Maintains a **structured and auditable migration process.**
- Standardizes XML as **the only Liquibase tracking format.**

**Potential Trade-offs**
- Requires **maintaining both SQL and Liquibase XML files.**
- Developers **must ensure rollback SQL files exist and are properly linked in XML.**
- YAML/JSON-based tracking is not allowed, **requiring migration for existing setups using these formats.**
