# Member 4: Boat Maintenance & Periodic Service Reminders
**Role:** Boat Maintenance & Service Manager  
**Module:** SE2030 – Software Engineering (Year 2, Semester 1 - 2026)  
**Group:** Y2-S1-MLB-B8G1-09  

---

## 1. Functional Overview
Member 4 is responsible for **Core Function 4: Boat Maintenance & Periodic Service Reminders**, ensuring fleet seaworthiness, adherence to marine engineering schedules, tracking dockyard repair costs, and managing recurring service alarms.

### Key Capabilities:
1. **Maintenance Job Logging:** Record routine services, drydock repairs, hull scraping, electrical overhauls, and annual marine surveys with assigned dockyard contractors.
2. **Expenditure Accounting:** Accumulates maintenance expenditures using the `Money` value object for fleet cost reporting.
3. **Automated Service Reminders:** Configures recurring maintenance intervals (e.g. Yanmar 100-hour oil change, 90-day bilge pump check, life raft certification) and calculates overdue states automatically.
4. **Vessel Availability Interlocking:** Notifies the fleet manager when boats need to be moved from `AVAILABLE` to `MAINTENANCE` status.

---

## 2. OOP Architecture & Design Patterns

### A. Encapsulation & Domain Logic
- Maintenance costs are encapsulated via `Money`, preventing floating point calculation discrepancies.
- `ServiceReminder.isOverdue()` calculates business logic internally by comparing `nextDueDate` against `LocalDate.now()`.

### B. Enums
- `MaintenanceType`: `ROUTINE_SERVICE`, `ENGINE_OVERHAUL`, `HULL_CLEANING`, `SAFETY_INSPECTION`, `ELECTRICAL_REPAIR`, `EMERGENCY_FIX`.
- `MaintenanceStatus`: `SCHEDULED`, `IN_PROGRESS`, `COMPLETED`, `CANCELLED`.

---

## 3. Directory Structure

```
member4/
├── backend/
│   ├── controller/
│   │   └── MaintenanceController.java  # Maintenance logging & reminders controller
│   ├── dao/
│   │   ├── MaintenanceDAO.java         # Work order persistence & expenditure sums
│   │   └── ReminderDAO.java            # Periodic reminder schedule persistence
│   ├── model/
│   │   ├── MaintenanceRecord.java      # Work order log entity
│   │   ├── ServiceReminder.java        # Recurring service interval entity
│   │   ├── MaintenanceType.java        # Classification enum
│   │   └── MaintenanceStatus.java      # Repair lifecycle enum
│   └── service/
│       └── MaintenanceService.java     # Maintenance scheduling & cost calculations
└── frontend/
    ├── maintenance-list.jsp            # Maintenance log table & cost KPI
    ├── maintenance-form.jsp            # Work order registration form
    └── service-reminders.jsp           # Periodic service reminder board
```

---

## 4. URL Endpoints & Access Control

| HTTP Method | URL Pattern | Role Requirement | Description |
|-------------|-------------|------------------|-------------|
| GET | `/admin/maintenance` | Admin, Officer, Captain | Maintenance history & expenditure KPI |
| GET | `/admin/maintenance/create` | Admin, Officer | Form to log repair/inspection job |
| POST | `/admin/maintenance/create` | Admin, Officer | Record maintenance work order |
| GET | `/admin/maintenance/reminders` | Admin, Officer, Captain | Periodic service reminder board |
| POST | `/admin/maintenance/reminders/create` | Admin, Officer | Configure new service interval |

---

## 5. Verification & Unit Testing
Tested via `src/test/java/com/boatsafari/SystemArchitectureTest.java`:
- `testMaintenanceAndReminders`: Validates maintenance cost recording, interval recurrence, and overdue date calculations.
