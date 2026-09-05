# Step-by-Step Guide: Connecting SQL Server Management Studio (SSMS) with IntelliJ IDEA
## Web-Based Boat Safari Trip Management System (Sail Lanka)

**Group:** Y2-S1-MLB-B8G1-09 | SLIIT SE2030 Software Engineering  
**Database Name:** `boat_safari_db`  
**SQL Server Instance:** `localhost\SQLEXPRESS` (or `.\SQLEXPRESS`)  

---

## 1. Quick Connection Reference Table

| Parameter | SQL Server Management Studio (SSMS) | IntelliJ IDEA (Database Tool Window) | Java Application (`db.properties`) |
| :--- | :--- | :--- | :--- |
| **Server / Host** | `localhost\SQLEXPRESS` (or `.\SQLEXPRESS`) | `localhost` (Instance: `SQLEXPRESS`) | `localhost` (Instance: `SQLEXPRESS`) |
| **Database** | `boat_safari_db` | `boat_safari_db` | `boat_safari_db` |
| **Authentication** | **Windows Authentication** (Recommended) | **Windows credentials** OR **User/Password** | `user=boat_safari_user;password=BoatSafari@2026;` OR Windows Auth |
| **User ID** | Current Windows Account | `boat_safari_user` or Windows Account | `boat_safari_user` or `sa` |
| **Password** | (Windows Login) | `BoatSafari@2026` | `BoatSafari@2026` |
| **Port / Protocol** | Shared Memory / Named Pipes / TCP | Named Instance / Port 1433 | JDBC Named Instance URL |
| **Trust Certificate**| Encrypt: Optional / Mandatory | Check `Trust server certificate` | `trustServerCertificate=true;` |

---

## 2. Connecting via SQL Server Management Studio (SSMS)

Follow these steps to open and view the database inside SSMS:

1. **Launch SSMS:**
   - Press `Windows Key`, type **SQL Server Management Studio**, and press `Enter`.
2. **Connect to Server Dialog:**
   - **Server type:** `Database Engine`
   - **Server name:** `localhost\SQLEXPRESS` (or `.\SQLEXPRESS`)
   - **Authentication:** Select **Windows Authentication**
   - Click **Connect**.
3. **Locate `boat_safari_db`:**
   - In the **Object Explorer** (left panel), expand:
     `Databases` &rarr; `boat_safari_db` &rarr; `Tables`.
   - You will see all 17 tables:
     - `dbo.users`
     - `dbo.destinations`
     - `dbo.routes`
     - `dbo.tours`
     - `dbo.vessels`
     - `dbo.tour_schedules`
     - `dbo.reservations`
     - `dbo.passengers`
     - `dbo.safety_check_logs`
     - `dbo.maintenance_records`
     - `dbo.service_reminders`
     - `dbo.emergency_notices`
     - `dbo.emergency_acknowledgments`
     - `dbo.promotions`
     - `dbo.promo_redemptions`
     - `dbo.activity_logs`
4. **View Live Data in SSMS:**
   - Right-click `dbo.users` &rarr; click **Select Top 1000 Rows**.
   - Right-click `dbo.reservations` &rarr; click **Select Top 1000 Rows**.

---

## 3. Connecting inside IntelliJ IDEA (Database Tool Window)

IntelliJ IDEA Ultimate has a full built-in SQL database client. The project has already been pre-configured with data sources in `.idea/dataSources.xml`.

### Method A: Using the Pre-Configured Database Panel (Immediate 1-Click)
1. In IntelliJ IDEA, look at the **right-hand sidebar** and click on **Database** (or press `View` &rarr; `Tool Windows` &rarr; `Database`).
2. You will see:
   - 🟢 **Microsoft SQL Server (SSMS) - boat_safari_db**
   - 🟢 **MySQL 8.0 - boat_safari_db**
3. If prompted to download the driver:
   - Click **Download Driver Files** (IntelliJ automatically installs Microsoft JDBC Driver for SQL Server).
4. Click the 🔄 **Refresh** icon.
5. Double-click any table (`users`, `vessels`, `reservations`) to open a live spreadsheet view inside IntelliJ!

---

### Method B: Adding a New SQL Server Connection Manually in IntelliJ
If you ever want to re-add the connection from scratch:
1. Open the **Database** tool window (`View` &rarr; `Tool Windows` &rarr; `Database`).
2. Click the **`+`** (Add) icon in the top left &rarr; **Data Source** &rarr; **Microsoft SQL Server**.
3. Fill in the fields:
   - **Name:** `SQL Server - boat_safari_db`
   - **Host:** `localhost`
   - **Instance:** `SQLEXPRESS`
   - **Authentication:** Select **Windows credentials** (or User & Password with `boat_safari_user` / `BoatSafari@2026`)
   - **Database:** `boat_safari_db`
   - Under the **Advanced** tab, ensure:
     `trustServerCertificate` = `true`
4. Click **Test Connection**.
   - A green checkmark appears: `Succeeded`.
5. Click **Apply** and **OK**.

---

## 4. Connecting the Java Application (`db.properties`) to SQL Server

To switch the active backend database from MySQL to Microsoft SQL Server in the Java application:

1. Open `src/main/resources/db.properties`.
2. Change the primary connection to SQL Server:
   ```properties
   # Primary: Microsoft SQL Server (SQLEXPRESS / SSMS)
   db.driver=com.microsoft.sqlserver.jdbc.SQLServerDriver
   db.url=jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=boat_safari_db;user=boat_safari_user;password=BoatSafari@2026;encrypt=true;trustServerCertificate=true;
   db.username=boat_safari_user
   db.password=BoatSafari@2026
   ```
   *(Or using Windows Authentication)*:
   ```properties
   db.url=jdbc:sqlserver://localhost;instanceName=SQLEXPRESS;databaseName=boat_safari_db;integratedSecurity=true;trustServerCertificate=true;
   ```
3. Recompile and start the server:
   ```bash
   mvn compile
   mvn exec:java
   ```
4. `DatabaseConnection.java` will output:
   `INFO: Successfully connected to Microsoft SQL Server database`

---

## 5. Summary: Dual Database Setup (SSMS & MySQL)

| Database Engine | Port / Instance | Status on System | Authentication |
| :--- | :--- | :--- | :--- |
| **Microsoft SQL Server 2022 (SSMS)** | `localhost\SQLEXPRESS` | **Active & Running** (`MSSQL$SQLEXPRESS`) | Windows Authentication / `boat_safari_user` |
| **MySQL 8.0** | `localhost:3306` | **Active & Running** (`MySQL80`) | `root` / `0000` |

Both databases contain identical synchronized schemas and seed data (`boat_safari_db`) ready for viva demonstrations.
