# Member 1: Safari Tour & Departure Schedule Management
**Role:** Safari Tour Operations Manager  
**Module:** SE2030 – Software Engineering (Year 2, Semester 1 - 2026)  
**Group:** Y2-S1-MLB-B8G1-09  

---

## 1. Functional Overview
Member 1 is responsible for **Core Function 1: Safari Tour & Departure Schedule Management**, enabling boat safari operators to define, catalog, price, and schedule luxury nautical expeditions across Sri Lanka's prime coastlines (Mirissa, Trincomalee, Kalpitiya, Galle, Colombo).

### Key Capabilities:
1. **Safari Tour Cataloging:** Create, edit, and deactivate tour packages with granular pricing (`Money` value object), duration, capacity, inclusions, and exclusions.
2. **Geographical Routing:** Link tours to designated nautical routes and coastal waypoints (`CoastRegion` classification: South Coast, East Coast, West Coast, North Coast).
3. **Dynamic Departure Scheduling:** Schedule morning/sunset departures, assign assigned vessels and skippers, and track remaining seats in real time.
4. **Public Tour Showcases:** Interactive guest views presenting itinerary details, boat specifications, weather safety protocols, and direct booking integration.

---

## 2. OOP Architecture & Design Patterns

### A. Abstraction & Interfaces
- Inherits from `com.boatsafari.common.core.BaseModel` implementing `Validatable` and `Displayable`.
- Extends `AbstractDAO<T>` and `CrudDAO<T, ID>` ensuring contract consistency across data access layers.

### B. Encapsulation
- Strictly private fields with defensive accessors and mutators.
- Financial figures are encapsulated in the immutable `Money` value object, preventing floating-point rounding errors.
- Capacity bounds are enforced via the immutable `Capacity` value object.

### C. Composition
- `Tour` has-a `Route` (1-to-1).
- `Tour` has-a `Money` base price (Value Object composition).
- `TourSchedule` has-a `Tour` and has-a assigned `Vessel` ID.

### D. Enums & Type Safety
- `TourType`: `WHALE_WATCHING`, `SUNSET_CRUISE`, `CORAL_SNORKELING`, `DEEP_SEA_FISHING`, `RIVER_SAFARI`, `PRIVATE_CHARTER`.
- `CoastRegion`: `SOUTH_COAST`, `EAST_COAST`, `WEST_COAST`, `NORTH_COAST`.
- `ScheduleStatus`: `SCHEDULED`, `BOARDING`, `DEPARTED`, `COMPLETED`, `CANCELLED`.

---

## 3. Directory Structure

```
member1/
├── backend/
│   ├── controller/
│   │   ├── TourController.java         # Tour package management endpoints
│   │   └── ScheduleController.java     # Departure scheduling endpoints
│   ├── dao/
│   │   ├── TourDAO.java                # Tour CRUD operations
│   │   ├── RouteDAO.java               # Nautical route data access
│   │   ├── DestinationDAO.java         # Coastal port & harbor points
│   │   └── TourScheduleDAO.java        # Departure timetable data access
│   ├── model/
│   │   ├── Tour.java                   # Primary Tour entity
│   │   ├── Route.java                  # Nautical route entity
│   │   ├── Destination.java            # Harbor waypoint entity
│   │   ├── TourSchedule.java           # Timetable departure entity
│   │   ├── TourType.java               # Classification enum
│   │   ├── CoastRegion.java            # Coastline enum
│   │   └── ScheduleStatus.java         # Timetable lifecycle enum
│   └── service/
│       └── TourService.java            # Business logic & scheduling orchestration
└── frontend/
    ├── tour-list.jsp                   # Admin & public tour inventory
    ├── tour-form.jsp                   # Tour creator / editor
    ├── tour-view.jsp                   # High-converting luxury tour showcase
    ├── schedule-list.jsp               # Departure timetable board
    └── schedule-form.jsp               # Schedule creator / vessel assigner
```

---

## 4. URL Endpoints & Access Control

| HTTP Method | URL Pattern | Role Requirement | Description |
|-------------|-------------|------------------|-------------|
| GET | `/tours` | Public / Guest | Browse public tour catalog |
| GET | `/tours/view?id={id}` | Public / Guest | Detailed safari tour view & itinerary |
| GET | `/admin/tours` | Admin, Officer | Manage all tour listings |
| GET | `/admin/tours/create` | Admin, Officer | Form to register new tour |
| POST | `/admin/tours` | Admin, Officer | Process new tour creation |
| GET | `/admin/tours/edit?id={id}` | Admin, Officer | Edit existing tour |
| POST | `/admin/tours/delete` | Admin | Soft/hard delete tour |
| GET | `/admin/schedules` | Admin, Officer, Guide | Timetable departure calendar |
| GET | `/admin/schedules/create` | Admin, Officer | Schedule new departure slot |
| POST | `/admin/schedules` | Admin, Officer | Save departure schedule |
| POST | `/admin/schedules/status` | Admin, Officer, Guide | Update schedule lifecycle |

---

## 5. Verification & Unit Testing
Tested via `src/test/java/com/boatsafari/SystemArchitectureTest.java`:
- `testTourModel`: Validates pricing encapsulation, regional categorization, and passenger capacity bounds.
