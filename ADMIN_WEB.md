# 🏢 ApexGym Admin Web Application (Portal)

> **Official Specification & Architectural Documentation for Gym Owners, Facility Managers & Front-Desk Admins**

---

## 1. Executive Summary & Purpose

**ApexGym Admin Web** is a dedicated enterprise operations dashboard engineered for desktop and tablet web browsers. It equips gym owners, receptionists, and head trainers with a command center to oversee gym membership registrations, track cash flow and monthly fee settlements, analyze member progression, and manage facility operations.

---

## 2. Target Audience & Roles

* **Gym Owners**: High-level visibility into monthly revenue, collection percentages, active membership counts, and churn/overdue trends.
* **Front-Desk / Facility Managers**: Day-to-day operations, member registrations, collecting payments (Cash, UPI, Card), generating invoice receipts, and sending payment reminders.
* **Head Coaches / Trainers**: Inspecting individual athlete lifting volume, consistency, attendance streaks, and assigned nutrition protocols.

---

## 3. Core Functional Modules

### A. Operations Command Center (KPI Dashboard)
* **Real-Time Revenue Metrics**: Total all-time collections and current billing cycle revenue.
* **Monthly Pending Dues**: Summary of pending vs collected dues with progress bars.
* **Defaulter Alerts**: Instant alert banners identifying members with overdue payments.
* **Recent Activity Feed**: Quick stream of recent member registrations and payment settlements.

### B. Member Directory & Onboarding Management
* **Onboarding Form (`AddMemberDialog`)**:
  * **Personal Information**: Full name, contact phone number, email address, gender, age, initial bodyweight.
  * **Membership Plan**: Tier selection (*Monthly, Quarterly, Half-Yearly, Annual*), custom monthly fee amount, and fee due day of the month (1st to 28th).
  * **Protocol Assignment**: Assigning initial workout splits (*Push/Pull/Legs, Upper/Lower, Bro Split, Full Body*) and scientific diet plans (*Hypertrophy, Lean Shred, Bulking, Vegetarian, Keto*).
  * **Emergency & Medical Notes**: Emergency contact details and injury/medical considerations.
* **Member Directory & Search**:
  * Live search by name, phone, or email.
  * Filter chips: `All`, `Active`, `Pending Fee`, `Overdue`, `Inactive`.
  * Member Profile Modal: Detailed view of joining date, workout volume, and direct switch context.

### C. Fees & Monthly Pending Matrix
* **Month-by-Month Financial Ledger**:
  * Grouped cards by month (*e.g., August 2026, July 2026, June 2026...*).
  * Progress gauge showing collected amount vs expected total fee volume.
* **Pending & Overdue Member Matrix**:
  * Identifies exactly which members have unpaid dues for each month.
* **Payment Settlement Dialog**:
  * Record payment method: `UPI / GPay`, `Cash`, `Credit/Debit Card`, `Bank Transfer`.
  * Auto-generated receipt reference ID (e.g. `REC-2026-1042`).
  * Add custom transaction notes and instant balance settlement.

### D. Athlete Progress & Volume Inspector
* **Athlete Selector**: Pick any registered member from the facility database.
* **Adaptation Charts**: Interactive line charts tracking bodyweight changes and body composition checkpoints over time.
* **Training Volume**: Overview of recent workout sessions logged, duration, and total weight tonnage lifted.

---

## 4. Clean Architecture Structure & Layer Mapping

```
lib/
├── core/
│   ├── di/
│   │   └── service_locator.dart             # Dependency Injection Container (sl)
│   └── theme/
│       └── gym_theme.dart                   # Visual Tokens & Styles
│
├── features/
│   └── admin/
│       ├── domain/                          # Core Business Logic (Pure Dart)
│       │   ├── entities/                    # MemberEntity, FeeRecordEntity, MonthlyFeeSummaryEntity
│       │   ├── repositories/                # MemberRepository, FeeRepository (Contracts)
│       │   └── usecases/                    # AddMemberUseCase, RecordFeePaymentUseCase, GetMonthlyFeeSummariesUseCase, etc.
│       ├── data/                            # Data Access & Storage Layer
│       │   ├── models/                      # MemberModel, FeeRecordModel (DTOs with fromMap/toMap)
│       │   ├── datasources/                 # AdminLocalDataSource (Hive), AdminRemoteDataSource (Firestore)
│       │   └── repositories/                # MemberRepositoryImpl, FeeRepositoryImpl
│       └── presentation/                    # UI Components
│           └── screens/admin/
│               ├── admin_shell.dart         # Responsive sidebar layout
│               ├── admin_overview_view.dart # KPI Command Center
│               ├── admin_members_view.dart  # Member Directory & Filters
│               ├── add_member_dialog.dart   # Onboarding Form
│               ├── admin_fees_view.dart     # Monthly Pending Matrix & Settlement
│               └── admin_member_progress_view.dart # Volume & Progress Inspector
│
└── main_admin.dart                          # Standalone Admin Web Application Entry Point
```

---

## 5. Development & Deployment Commands

### Run Locally on Web
```bash
# Run standalone Admin Web Portal on Chrome browser
flutter run -t lib/main_admin.dart -d chrome
```

### Build for Production Web Hosting
```bash
# Build optimized web release bundle
flutter build web -t lib/main_admin.dart --release --output=build/web_admin
```

---

## 6. Security & Data Integrity

* **Role Isolation**: Admin shell operates independently without embedding user-specific bottom navigation or workout logging widgets.
* **Firestore Schema**:
  * `/members/{memberId}`: Member profile records.
  * `/fee_records/{feeId}`: Payment transaction ledger.
