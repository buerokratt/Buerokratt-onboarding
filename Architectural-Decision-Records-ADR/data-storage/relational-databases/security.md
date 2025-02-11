# SECURITY-001: Security Declarations in Queries

## Context
To ensure secure query execution and facilitate the generation of OpenAPI specifications, every `.sql` file must include security declarations. These declarations define the allowed request type, expected input parameters, and expected output structure, enabling better validation, security enforcement, and automatic API documentation generation.

## Decision

1. **Every `.sql` file must include a security declaration**
<br>&emsp;1.1. Security metadata will be placed at the **top of each file** in the form of comments.
<br>&emsp;1.2. This metadata must be **structured** for easy parsing by documentation generators.

2. **Mandatory Security Declarations**
<br>&emsp;1.1. Allowed request type (e.g., `GET`, `POST`).
<br>&emsp;1.2. Expected input parameters, including data types.
<br>&emsp;1.3. Expected output fields, including data types.

**Example SQL File with Security Declarations**

```sql
/*  
declaration:
  version: 0.1
  description: "Fetch user details by user ID"
  method: get
  accepts: json
  returns: data
  namespace: users
  allowlist:
    query:
      - field: user_id
        type: uuid
        description: "Unique identifier for the user"
  response:
    fields:
      - field: id
        type: uuid
        description: "User's unique identifier"
      - field: name
        type: string
        description: "User's full name"
      - field: email
        type: string
        description: "User's email address"
      - field: created_at
        type: timestamp
        description: "Timestamp of when the user was created"
*/

SELECT id, name, email, created_at
FROM users
WHERE id = :user_id;
```

3. **Automated Parsing & OpenAPI Integration**
The structured comments allow for automatic parsing and conversion into OpenAPI documentation. This ensures the API specification is always in sync with the actual queries.

## Consequences

### Positive Outcomes
- **Enhances security** by enforcing clear input and output validation.
- **Reduces risks of SQL injection** by ensuring strict parameterization.
- **Simplifies OpenAPI documentation** by providing structured metadata in queries.
- **Facilitates automated API generation,** ensuring queries and documentation remain aligned.

### Potential Trade-offs:
- **Additional documentation effort** required for every `.sql` file.
- **Requires developers to follow a structured format,** increasing discipline in query management.

---

# SECURITY-002: Enforce Query Parameterization for Security and Reusability

## Context
Parameterized queries are essential for **preventing SQL injection attacks** and ensuring query **reusability**. Hardcoded values and in-line variables in SQL queries pose a security risk and reduce maintainability. By enforcing query parameterization, we improve both **security** and **query reusability** across the system.

## Decision
- **All SQL queries must use parameterized inputs** instead of embedding raw values or variables directly.
- **No inline variables** should be used within queries. Instead, values must be **strictly parameterized**.
- Query parameters should follow a **consistent naming convention**, such as `:input_param`.
- **Hardcoded values and dynamic variable substitution in queries are strictly prohibited** unless explicitly required for system logic.

### **Example**

#### Avoid (Hardcoded Values in SQL)
```sql
SELECT field1, field2 FROM customers WHERE id = 123 AND customer_name = 'John Doe';
```

#### Avoid (Using Variables Directly in SQL Queries)

```sql
SELECT field1, field2 FROM customers WHERE id = $userId AND customer_name = $customerName;
```

#### Use (Strict Parameterized Query Without Variables)

```sql
SELECT field1, field2 FROM customers WHERE id = :input_param AND customer_name = :another_param;
```

## Consequences

### Positive Outcomes
- **Enhances security** by enforcing clear input and output validation.
- **Reduces risks of SQL injection** by ensuring strict parameterization.
- **Simplifies OpenAPI documentation** by providing structured metadata in queries.
- **Facilitates automated API generation,** ensuring queries and documentation remain aligned.

### Potential Trade-offs:
- **Additional documentation effort** required for every `.sql` file.
- **Requires developers to follow a structured format,** increasing discipline in query management.
