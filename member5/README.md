# Member 5: Maritime Safety & Emergency Notice Management
**Role:** Maritime Safety & Emergency Notice Manager  
**Module:** SE2030 – Software Engineering (Year 2, Semester 1 - 2026)  
**Group:** Y2-S1-MLB-B8G1-09  

---

## 1. Functional Overview
Member 5 is responsible for **Core Function 5: Maritime Safety & Emergency Notice Management**, providing real-time safety advisories, meteorological warnings (Department of Meteorology monsoon alerts), rough sea advisories, mechanical SOS dispatches, and port restriction notices.

### Key Capabilities:
1. **Multi-Channel Emergency Broadcasting:** Dispatches critical advisories across Web Portal Live Alert Ribbons, passenger SMS notifications, and captain VHF/email channels.
2. **Real-time Live Alert Ticker:** High-priority safety advisories appear prominently at the top of every public and administrative page via an animated alert ribbon.
3. **Emergency Feed REST API (`/api/emergency/feed`):** Delivers active notices in JSON format to external consumer apps, mobile clients, and coastal harbor monitors.
4. **Resolution Lifecycle:** Allows authorized officers and captains to issue "All-Clear / Resolved" notices with exact resolution timestamps.

---

## 2. OOP Architecture & Design Patterns

### A. Lifecycle State Pattern & Timestamps
- `EmergencyNotice` encapsulates status progression from `ACTIVE` to `RESOLVED`.
- Defensive timestamp cloning prevents mutable date side-effects.

### B. RESTful API Controller
- `EmergencyFeedController` outputs standard `application/json` responses for client-side ticker polling.

### C. Enums
- `EmergencyCategory`: `BAD_WEATHER`, `ROUGH_SEAS`, `MECHANICAL_FAILURE`, `MEDICAL_EMERGENCY`, `PORT_RESTRICTION`, `GENERAL_SAFETY`.
- `EmergencySeverity`: `CRITICAL`, `HIGH`, `MODERATE`, `LOW`, `ADVISORY`.
- `EmergencyStatus`: `ACTIVE`, `RESOLVED`, `ARCHIVED`.

---

## 3. Directory Structure

```
member5/
├── backend/
│   ├── controller/
│   │   ├── EmergencyController.java    # Safety notices admin & broadcast controller
│   │   └── EmergencyFeedController.java # Public JSON Feed API (/api/emergency/feed)
│   ├── dao/
│   │   └── EmergencyDAO.java           # Alert notice persistence & active query
│   ├── model/
│   │   ├── EmergencyNotice.java        # Primary emergency entity
│   │   ├── EmergencyCategory.java      # Hazard classification enum
│   │   ├── EmergencySeverity.java      # Severity enum with UI badge styling
│   │   └── EmergencyStatus.java        # Advisory state enum
│   └── service/
│       └── EmergencyService.java       # Broadcast dispatch & resolution logic
└── frontend/
    ├── emergency-list.jsp              # Safety notice broadcast log & resolution
    └── emergency-form.jsp              # Emergency advisory broadcaster form
```

---

## 4. URL Endpoints & Access Control

| HTTP Method | URL Pattern | Role Requirement | Description |
|-------------|-------------|------------------|-------------|
| GET | `/api/emergency/feed` | Public / System | Real-time JSON feed of active safety notices |
| GET | `/admin/emergency` | Admin, Officer, Captain, Guide | Safety alert broadcast log |
| GET | `/admin/emergency/create` | Admin, Officer, Captain | Form to broadcast emergency advisory |
| POST | `/admin/emergency/create` | Admin, Officer, Captain | Issue emergency notice to portal/SMS |
| POST | `/admin/emergency/resolve` | Admin, Officer, Captain | Mark notice as RESOLVED (All-Clear) |
| POST | `/admin/emergency/delete` | Admin | Archive notice |

---

## 5. Verification & Unit Testing
Tested via `src/test/java/com/boatsafari/SystemArchitectureTest.java`:
- `testEmergencyNoticeLifecycle`: Validates active state filtering, severity badge mapping, and resolution timestamp management.
