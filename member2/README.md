# Member 2: Reservation & Guest Booking Management
**Role:** Reservation & Guest Booking Manager  
**Module:** SE2030 – Software Engineering (Year 2, Semester 1 - 2026)  
**Group:** Y2-S1-MLB-B8G1-09  

---

## 1. Functional Overview
Member 2 is responsible for **Core Function 2: Reservation & Guest Booking Management**, orchestrating end-to-end booking journeys for domestic and international safari tourists.

### Key Capabilities:
1. **Multi-Step Booking Wizard:** Interactive 3-step guest reservation process (Departure Selection -> Guest & Passenger Manifest -> Voucher & Payment Checkout).
2. **Passenger Manifest Collection:** Compliant with Sri Lanka Coast Guard regulations, recording name, passport/NIC, age, gender, nationality, and emergency contact for each passenger on board.
3. **Financial Breakdown:** Automatically calculates base rates, promo code deductions (integrating Member 6's Strategy Pattern), VAT/NBT taxes, and net balances.
4. **Autonomous Reference Generator:** Generates unique booking codes (e.g. `SL-2026-X9K3`).
5. **Guest Portal & Admin Auditing:** Dedicated "My Bookings" view for authenticated customers and a master reservation ledger for booking clerks.

---

## 2. OOP Architecture & Design Patterns

### A. Composition
- `Reservation` has-many `Passenger` records (`List<Passenger>`), enforcing strong lifecycle ownership (if reservation is cancelled or updated, passengers remain bounded).
- `Reservation` has-a `Money` total, discount, and final amount.
- `Reservation` has-a `TourSchedule` association.

### B. Encapsulation & Defensive Copying
- Unmodifiable or defensively cloned lists returned for passenger manifests.
- Status transitions managed through explicit domain methods (`confirm()`, `cancel()`, `checkIn()`).

### C. Enums
- `ReservationStatus`: `PENDING`, `CONFIRMED`, `CHECKED_IN`, `COMPLETED`, `CANCELLED`.

---

## 3. Directory Structure

```
member2/
├── backend/
│   ├── controller/
│   │   ├── BookingController.java      # Guest booking wizard & checkout flow
│   │   └── ReservationController.java  # Staff / Admin reservation ledger
│   ├── dao/
│   │   ├── ReservationDAO.java         # Booking persistence & status mutations
│   │   └── PassengerDAO.java           # Manifest passenger persistence
│   ├── model/
│   │   ├── Reservation.java            # Primary booking entity
│   │   ├── Passenger.java              # Passenger manifest entity
│   │   └── ReservationStatus.java      # Booking state enum
│   └── service/
│       └── ReservationService.java     # Booking validation & capacity locking
└── frontend/
    ├── booking-wizard.jsp              # 3-step luxury booking interface
    ├── booking-confirmation.jsp        # Printable boarding voucher & receipt
    ├── reservation-list.jsp            # Staff reservation ledger & search
    ├── reservation-view.jsp            # Detailed passenger manifest & ledger
    └── my-bookings.jsp                 # Customer self-service dashboard
```

---

## 4. URL Endpoints & Access Control

| HTTP Method | URL Pattern | Role Requirement | Description |
|-------------|-------------|------------------|-------------|
| GET | `/book` | Customer / Guest | Open multi-step booking wizard |
| POST | `/book` | Customer / Guest | Submit reservation with passenger manifest |
| GET | `/book/confirmation?ref={ref}` | Customer / Guest | View boarding voucher & confirmation |
| GET | `/my-bookings` | Customer | Customer booking history |
| GET | `/admin/reservations` | Admin, Officer | Staff reservation ledger & search |
| GET | `/reservations/view?id={id}` | Admin, Officer, Customer | Detailed booking & manifest sheet |
| POST | `/admin/reservations/status` | Admin, Officer | Update reservation status |

---

## 5. Verification & Unit Testing
Tested via `src/test/java/com/boatsafari/SystemArchitectureTest.java`:
- `testReservationComposition`: Validates passenger manifest composition, financial calculations, and status transitions.
