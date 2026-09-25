# Member 6: Promotion & Discount Strategy Management
**Role:** Promotion & Discount Strategy Manager  
**Module:** SE2030 – Software Engineering (Year 2, Semester 1 - 2026)  
**Group:** Y2-S1-MLB-B8G1-09  

---

## 1. Functional Overview
Member 6 is responsible for **Core Function 6: Promotion & Discount Strategy Management**, providing flexible pricing algorithms, seasonal vouchers, corporate discounts, off-peak promotions, and real-time coupon validation during booking checkout.

### Key Capabilities:
1. **Polymorphic Strategy Pattern:** Discount calculations are abstracted behind the `DiscountStrategy` interface, allowing dynamic algorithm selection at runtime without modifying client code.
2. **Multiple Discount Models:** Supports Percentage discounts (with optional maximum ceiling cap), Fixed Amount discounts, and Seasonal/Monsoon Off-Peak dynamic pricing.
3. **Real-time AJAX Validation API (`/api/promotions/validate`):** Verifies coupon code validity, date windows, minimum booking spend thresholds, and remaining redemption caps asynchronously during checkout.
4. **Audit Log & Redemption Analytics:** Logs each redeemed voucher along with guest information and financial savings for ROI tracking.

---

## 2. OOP Architecture & Design Patterns

### A. The Strategy Design Pattern
```
             +-----------------------+
             |  <<interface>>        |
             |   DiscountStrategy    |
             +-----------------------+
             | + calculateDiscount() |
             +-----------------------+
                     ^     ^     ^
                    /      |      \
                   /       |       \
+--------------------+ +--------------------+ +--------------------+
| PercentageDiscount | | FixedAmountDiscount| |  SeasonalDiscount  |
+--------------------+ +--------------------+ +--------------------+
```

### B. Factory Method & Lazy Loading
- `Promotion.getStrategy()` evaluates `discountType` and lazily instantiates the appropriate concrete `DiscountStrategy` instance with required parameters.

### C. Value Objects Integration
- All discount limits, minimum spends, and computed deductions strictly utilize the immutable `Money` value object.

---

## 3. Directory Structure

```
member6/
├── backend/
│   ├── controller/
│   │   ├── PromotionController.java     # Admin campaign management & redemption ledger
│   │   └── PromoValidateController.java # AJAX JSON validation API (/api/promotions/validate)
│   ├── dao/
│   │   ├── PromotionDAO.java            # Promotion campaign database persistence
│   │   └── PromoRedemptionDAO.java      # Voucher usage audit logging
│   ├── model/
│   │   ├── Promotion.java               # Campaign entity & Strategy host
│   │   ├── PromoRedemption.java         # Redemption audit record
│   │   ├── DiscountType.java            # Algorithm selector enum
│   │   ├── DiscountStrategy.java        # Strategy interface
│   │   ├── PercentageDiscount.java      # Concrete Strategy: % off with ceiling cap
│   │   ├── FixedAmountDiscount.java     # Concrete Strategy: Flat rate LKR deduction
│   │   └── SeasonalDiscount.java        # Concrete Strategy: Off-peak monsoon strategy
│   └── service/
│       └── PromotionService.java        # Voucher validation & redemption processing
└── frontend/
    ├── promo-list.jsp                   # Campaign table & usage gauges
    ├── promo-form.jsp                   # Campaign creator / strategy editor
    └── promo-analytics.jsp              # Redemption audit log & ROI metrics
```

---

## 4. URL Endpoints & Access Control

| HTTP Method | URL Pattern | Role Requirement | Description |
|-------------|-------------|------------------|-------------|
| GET | `/api/promotions/validate` | Public / Guest | AJAX JSON verification of promo codes |
| GET | `/admin/promotions` | Admin, Officer | Promotional campaign manager |
| GET | `/admin/promotions/create` | Admin, Officer | Create new campaign |
| POST | `/admin/promotions` | Admin, Officer | Save promotion parameters |
| GET | `/admin/promotions/edit?id={id}` | Admin, Officer | Edit existing promotion |
| POST | `/admin/promotions/delete` | Admin | Delete campaign |
| GET | `/admin/promotions/redemptions` | Admin, Officer | Voucher redemption analytics log |

---

## 5. Verification & Unit Testing
Tested via `src/test/java/com/boatsafari/SystemArchitectureTest.java`:
- `testPercentageDiscountStrategy`: Tests percentage calculation, ceiling cap limits, and minimum spend boundaries.
- `testFixedAmountDiscountStrategy`: Tests flat-rate deduction and minimum spend boundaries.
- `testSeasonalDiscountStrategy`: Tests seasonal off-peak dynamic deduction calculation.
