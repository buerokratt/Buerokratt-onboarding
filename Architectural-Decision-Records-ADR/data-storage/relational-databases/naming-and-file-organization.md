# NAMING-001: Standardized File Organization for SQL Queries  

## Context  
To ensure modularity, maintainability, and ease of navigation, all database queries must be stored as stand-alone `.sql` files. Queries will be categorized based on operation type (e.g., `POST`, `GET`) and further organized into subfolders based on modules or features. This structure ensures that queries are easily traceable, supports scalability, and prevents clutter.  

## Decision  

1. **Dedicated SQL Files for Each Query**
<br>&emsp;1.1. Every SQL query must be stored in its own `.sql` file.
<br>&emsp;1.2. No multiple queries within a single file.  
2. **Folder Organization by Operation Type**
<br>&emsp;1.1. Queries must be grouped into `POST/` and `GET/` directories, based on the type of request they serve.  
&emsp;1.2. Each module or feature must have its own subfolder under `POST/` or `GET/`.  

**Example directory structure**

   ```plaintext
   ├── queries/
   │   ├── POST/
   │   │   ├── user_management/
   │   │   │   ├── create_user.sql
   │   │   │   ├── update_user_profile.sql
   │   │   ├── orders/
   │   │   │   ├── create_order.sql
   │   │   │   ├── cancel_order.sql
   │   ├── GET/
   │   │   ├── user_management/
   │   │   │   ├── get_user_by_id.sql
   │   │   │   ├── list_users.sql
   │   │   ├── orders/
   │   │   │   ├── get_order_by_id.sql
   │   │   │   ├── list_orders.sql
   ```

## Consequences

### Positive Outcomes
- **Improves organization** by keeping queries modular and easy to find.
- **Simplifies maintenance,** making it easier to track and modify queries.
- **Enhances scalability,** allowing for structured expansion of database queries.
- **Encourages consistency,** ensuring all developers follow the same query storage format.

### Potential Trade-offs
- **Enforces strict file management,** requiring developers to adhere to the folder structure.
- **Slightly more overhead in setup,** but provides long-term benefits in maintainability.

---

# NAMING-002: SQL Naming Policy for CRUD Operations  

## Context  
A standardized naming convention for SQL queries ensures clarity, maintainability, and consistency across database operations. By enforcing a structured format, we enhance query readability and facilitate efficient collaboration between developers and database administrators.  

## Decision  
All SQL queries must adhere to the following naming convention, aligning with RESTful principles and CRUD (Create, Read, Update, Delete) operations:

1. **Retrieving multiple records** (List) → `list_{resource}` (GET)  
1. **Retrieving a single record** (Get) → `get_{resource}` (GET)  
1. **Creating a new record** → `create_{resource}` (POST)  
1. **Updating an existing record** → `update_{resource}` (PUT)  
1. **Deleting a record** → `delete_{resource}` (DELETE)  

**Example for LLM training data**
1. `list_llm_training (GET)` → Retrieves all LLM training records.  
1. `get_llm_training (GET)` → Retrieves a single LLM training record.  
1. `create_llm_training (POST)` → Inserts a new LLM training record.  
1. `update_llm_training (PUT)` → Updates an existing LLM training record.  
1. `delete_llm_training (DELETE)` → Deletes an LLM training record.  

### **Additional Rules**  
1. Use **snake_case** for all SQL query names.  
1. Use **plural or singular form based on the resource** (e.g., `list_users`, `get_user`).  
1. Avoid abbreviations unless widely recognized (`llm_training` instead of `lt`).  

## Consequences

### Positive Outcomes
- **Enhances readability** and **maintainability** of SQL queries.  
- **Ensures uniformity** across all database operations.  
- **Reduces ambiguity**, making it easier to **understand query intent** at a glance.  
- **Facilitates collaboration** by providing clear naming conventions for database interactions.  

### Potential Trade-offs:
- **Requires strict adherence** to the policy, which may necessitate training for new developers.  
- **Might require some refactoring** for legacy queries that do not follow this standard.  
