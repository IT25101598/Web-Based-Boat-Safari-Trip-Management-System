# Common: Shared Architectural Foundation & Infrastructure
**Module:** SE2030 – Software Engineering (Year 2, Semester 1 - 2026)  
**Group:** Y2-S1-MLB-B8G1-09  
**System:** Web-Based Boat Safari Trip Management System (Sail Lanka Charter)  

---

## 1. Overview & Purpose
The `common/` package provides the shared foundational infrastructure, object-oriented framework, security layer, database connection manager, value objects, and user management subsystem leveraged by all six member modules.

---

## 2. Architectural Subsystems

### A. Core OOP Contracts & Base Classes (`common/backend/core/`)
- `BaseModel`: Abstract entity root encapsulating primary key `id`, audit timestamps (`createdAt`, `updatedAt`), and contracts for `validate()`, `getSummary()`, `getStatusLabel()`, and `getStatusBadgeClass()`.
- `Validatable`: Interface enforcing declarative entity validation with field-keyed error maps.
- `Displayable`: Interface mandating human-readable summary badges and labels for UI rendering.
- `CrudDAO<T, ID>`: Generic interface defining standard CRUD data access contracts (`findById`, `findAll`, `save`, `update`, `deleteById`).
- `AbstractDAO<T>`: Abstract data access base class providing safe JDBC resource management and SQL helpers.
- `BaseController`: Servlet controller base class with helper methods for parameter parsing, session management, CSRF validation, JSON responses, and JSP rendering.
- `ValidationException`: Specialized domain exception transporting validation error mappings to the controller layer.

### B. Database & Multi-Tier Storage Architecture (`common/backend/db/` & `common/database/`)
- `DatabaseConnection`: Thread-safe Singleton managing JDBC connection pooling to **Microsoft SQL Server** (`jdbc:sqlserver://localhost:1433;databaseName=boat_safari_db` and named instance `.\SQLEXPRESS`), with secondary fallback to MySQL 8.0.
- **SQL Server Management Studio (SSMS) Integration:**
  - `01_mssql_schema.sql`: T-SQL schema with 15 tables (`IDENTITY(1,1)`, `DATETIME2`, `NVARCHAR`, `BIT`, check constraints, referential integrity).
  - `02_mssql_seed.sql`: Realistic seed data using explicit `SET IDENTITY_INSERT` blocks.
  - `restart_sqlserver_service.bat`: 1-click admin script to restart `MSSQL$SQLEXPRESS` for TCP/IP port 1433 activation.
- **InMemory Fallback Engine:** Every DAO includes synchronized, thread-safe memory stores seeded with authentic Sri Lankan boat safari records. If the local grading environment lacks a running database instance, the application operates seamlessly with zero crashes.

### C. Domain Value Objects & Utilities (`common/backend/util/`)
- `Money`: Immutable Value Object representing currency amounts (LKR) with rounded arithmetic (`add`, `subtract`, `multiply`, `applyPercentageDiscount`), comparison, and formatting.
- `Capacity`: Immutable Value Object enforcing nautical passenger licensing constraints (1 to 100 passengers) and cabin capacities.
- `PasswordHasher`: Cryptographic SHA-256 hashing with salt for credential security.
- `Csrf`: Cryptographically random CSRF token generation and validation to safeguard all POST actions.
- `SessionHelper`: Helper methods for authenticated session retrieval, role queries, and logout.

### D. User Management & Role-Based Access Control (RBAC)
- **Inheritance Hierarchy:**
  ```
               +---------------+
               |    Person     |
               +---------------+
                       ^
                       |
               +---------------+
               |     User      |
               +---------------+
              /        |        \
             /         |         \
  +----------+   +----------+   +----------+
  | Customer |   |  Staff   |   |  Admin   |
  +----------+   +----------+   +----------+
  ```
- **User Roles (`UserRole`):** `ADMIN`, `OFFICER`, `GUIDE`, `CAPTAIN`, `OWNER`, `CUSTOMER`.
- **RBAC Filter (`AuthFilter`):** Intercepts `/admin/*`, `/book`, and `/my-bookings` requests to verify role permissions and prevent privilege escalation.

### E. Embedded Server Launcher (`ServerLauncher.java`)
- Embedded Tomcat 10 launcher enabling 1-click startup without needing an external Tomcat server installed:
  ```bash
  mvn compile exec:java
  ```

---

## 3. Directory Structure

```
common/
├── backend/
│   ├── core/                           # BaseModel, CrudDAO, BaseController, etc.
│   ├── db/                             # DatabaseConnection Singleton
│   ├── util/                           # Money, Capacity, PasswordHasher, Csrf
│   ├── model/                          # User, Customer, Staff, Admin, ActivityLog
│   ├── dao/                            # UserDAO, ActivityLogDAO
│   ├── service/                        # UserService
│   ├── filter/                         # CharacterEncodingFilter, AuthFilter
│   ├── controller/                     # AuthController, UserAdminController, HomeController
│   └── ServerLauncher.java             # Standalone Tomcat 10 runner
├── frontend/
│   ├── assets/                         # CSS (theme, navbar, footer) & JS (common.js)
│   ├── layouts/                        # header.jsp & footer.jsp
│   ├── views/                          # public-home.jsp, dashboard.jsp, login.jsp, etc.
│   └── index.jsp                       # Root welcome file
└── database/
    ├── 01_schema.sql                   # 15 relational tables with foreign keys
    ├── 02_seed.sql                     # Realistic Sri Lankan nautical data
    └── er-diagram.md                   # Mermaid ER diagram
```

---

## 4. Shared URL Endpoints

| HTTP Method | URL Pattern | Access | Description |
|-------------|-------------|--------|-------------|
| GET | `/` | Public | Luxury homepage showcasing Sri Lankan coastlines |
| GET | `/experiences` | Public | Safari experiences & activities showcase |
| GET | `/destinations` | Public | Coastal port guide (Mirissa, Trinco, etc.) |
| GET | `/login` | Public | Unified multi-role login with 1-click demo buttons |
| POST | `/login` | Public | Authenticate user credentials |
| GET | `/register` | Public | Customer registration form |
| POST | `/register` | Public | Create new customer account |
| GET | `/logout` | Authenticated | Destroy session |
| GET | `/dashboard` | Authenticated | Role-adaptive operations dashboard |
| GET | `/profile` | Authenticated | View/edit user profile |
| GET | `/admin/users` | Admin | Staff and customer user management |
| GET | `/admin/logs` | Admin | Security and activity audit ledger |
