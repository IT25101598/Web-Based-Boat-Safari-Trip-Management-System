# Member 3: Boat Fleet & Vessel Hierarchy Management
**Role:** Boat Fleet & Vessel Manager  
**Module:** SE2030 – Software Engineering (Year 2, Semester 1 - 2026)  
**Group:** Y2-S1-MLB-B8G1-09  

---

## 1. Functional Overview
Member 3 is responsible for **Core Function 3: Boat Fleet & Vessel Hierarchy Management**, handling the maritime registration, classification, seating capacity, safety gear inspection, and operational availability of all safari boats operating under Sail Lanka Charter.

### Key Capabilities:
1. **Fleet Cataloging:** Register catamarans, motor yachts, and rapid patrol speedboats with unique marine registration numbers and licensing details.
2. **Polymorphic Vessel Hierarchy:** Specific attributes for distinct craft types (e.g. trampolines and dual hulls for catamarans; staterooms and flybridge decks for yachts; outboard counts and horsepower for speedboats).
3. **Availability Lifecycle Management:** Track vessel statuses (`AVAILABLE`, `ON_TOUR`, `MAINTENANCE`, `CHARTERED`, `DECOMMISSIONED`) to prevent scheduling collisions.
4. **Capacity Controls:** Integrates `Capacity` value object to guarantee compliance with maximum allowable passenger loads.

---

## 2. OOP Architecture & Design Patterns

### A. Inheritance Hierarchy
```
           +-------------------------+
           |   com.boatsafari.common |
           |        BaseModel        |
           +-------------------------+
                        ^
                        |
           +-------------------------+
           |   <<abstract>> Vessel   |
           +-------------------------+
            /           |           \
           /            |            \
+-------------+  +-------------+  +---------------+
|  Catamaran  |  |    Yacht    |  |   SpeedBoat   |
+-------------+  +-------------+  +---------------+
```

### B. Polymorphism
- Abstract method `getVesselArchitecture()` declared in `Vessel` and polymorphically overridden in `Catamaran`, `Yacht`, and `SpeedBoat` to describe specific engineering features.
- Dynamic Factory Mapping in `BoatDAO.mapResultSetToVessel()` instantiates the exact concrete subclass at runtime based on `vessel_type`.

### C. Enums
- `VesselType`: `CATAMARAN`, `YACHT`, `SPEEDBOAT`.
- `VesselStatus`: `AVAILABLE`, `ON_TOUR`, `MAINTENANCE`, `CHARTERED`, `DECOMMISSIONED`.

---

## 3. Directory Structure

```
member3/
├── backend/
│   ├── controller/
│   │   └── BoatController.java         # Fleet management CRUD endpoints
│   ├── dao/
│   │   └── BoatDAO.java                # Polymorphic vessel database mapping
│   ├── model/
│   │   ├── Vessel.java                 # Abstract base vessel entity
│   │   ├── Catamaran.java              # Subclass: Sailing Catamaran
│   │   ├── Yacht.java                  # Subclass: Motor Yacht
│   │   ├── SpeedBoat.java              # Subclass: Speedboat
│   │   ├── VesselType.java             # Vessel classification enum
│   │   └── VesselStatus.java           # Vessel operational state enum
│   └── service/
│       └── BoatService.java            # Fleet business logic & availability queries
└── frontend/
    ├── boat-list.jsp                   # Fleet overview & status board
    └── boat-form.jsp                   # Vessel registration & spec editor
```

---

## 4. URL Endpoints & Access Control

| HTTP Method | URL Pattern | Role Requirement | Description |
|-------------|-------------|------------------|-------------|
| GET | `/boats` | Public / Guest | Browse public boat fleet |
| GET | `/admin/boats` | Admin, Officer, Captain | Fleet management table & status |
| GET | `/admin/boats/create` | Admin, Officer | Register new vessel |
| POST | `/admin/boats/create` | Admin, Officer | Save new vessel specs |
| GET | `/admin/boats/edit?id={id}` | Admin, Officer | Edit vessel specifications |
| POST | `/admin/boats/edit` | Admin, Officer | Update vessel specs |
| POST | `/admin/boats/status` | Admin, Captain | Toggle vessel operational status |
| POST | `/admin/boats/delete` | Admin | Decommission vessel |

---

## 5. Verification & Unit Testing
Tested via `src/test/java/com/boatsafari/SystemArchitectureTest.java`:
- `testVesselPolymorphism`: Validates polymorphic instantiation of `Catamaran`, `Yacht`, and `SpeedBoat`, subtype-specific fields, and `getVesselArchitecture()` override.
