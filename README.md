# ⚡ ApexGym — Multi-Role Gym Management & Workout Engine

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-4CAF50)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![Storage](https://img.shields.io/badge/Local%20Storage-Hive-F57C00)](https://pub.dev/packages/hive)
[![Cloud](https://img.shields.io/badge/Cloud-Firebase%20Firestore-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Desktop-lightgrey)]()

An enterprise-grade, multi-role gym management platform and athletic training engine built with **Flutter**, **Clean Architecture**, **Hive offline-first storage**, and **Firebase Firestore cloud sync**.

---

## 🌟 Ecosystem Overview

```
                                  +---------------------------------------+
                                  |     ApexGym Shared Core Engine        |
                                  |   (Hive Service + Firebase Sync)      |
                                  +---------------------------------------+
                                                     |
                         +---------------------------+---------------------------+
                         |                                                       |
                         v                                                       v
        +---------------------------------+                     +---------------------------------+
        |     ADMIN WEB APPLICATION       |                     |     USER / MEMBER MOBILE APP    |
        |        (lib/main_admin.dart)    |                     |        (lib/main_user.dart)     |
        +---------------------------------+                     +---------------------------------+
        | • URL Route: /admin             |                     | • URL Route: / or /user         |
        | • Standalone Admin Web Portal   |                     | • Standalone Member Athlete App |
        | • Member Directory & Onboarding |                     | • Diet & Nutrition Selection    |
        | • Fees & Monthly Pending Matrix |                     | • Live Workouts & Rest Timers   |
        | • Member Progress Inspector     |                     | • Personal Dues & Biomarkers    |
        +---------------------------------+                     +---------------------------------+
```

---

## 📚 Dedicated Platform Documentation

| Platform | Target Audience | Documentation File |
| :--- | :--- | :--- |
| 🏢 **Admin Web Portal** | Gym Owners, Front-Desk & Managers | [ADMIN_WEB.md](ADMIN_WEB.md) |
| 💻 **User Web Portal** | Members on Desktop / Laptops | [USER_WEB.md](USER_WEB.md) |
| 📱 **User Mobile App** | Members on iOS & Android Phones | [USER_APP.md](USER_APP.md) |

---

## 🏛️ Clean Architecture Structure

```
lib/
├── core/
│   ├── di/
│   │   └── service_locator.dart             # Dependency Injection container (sl)
│   └── theme/
│       └── gym_theme.dart                   # High-contrast OLED dark theme & tokens
│
├── features/
│   ├── admin/
│   │   ├── domain/                          # Core Business Logic (Pure Dart)
│   │   │   ├── entities/                    # MemberEntity, FeeRecordEntity, MonthlyFeeSummaryEntity
│   │   │   ├── repositories/                # MemberRepository, FeeRepository (Contracts)
│   │   │   └── usecases/                    # AddMemberUseCase, RecordFeePaymentUseCase, GetMonthlyFeeSummariesUseCase
│   │   ├── data/                            # Data Access & Storage Layer
│   │   │   ├── models/                      # MemberModel, FeeRecordModel (DTOs with serialization)
│   │   │   ├── datasources/                 # AdminLocalDataSource (Hive), AdminRemoteDataSource (Firestore)
│   │   │   └── repositories/                # MemberRepositoryImpl, FeeRepositoryImpl
│   │   └── presentation/                    # Admin UI
│   │       └── screens/admin/               # AdminShell, AdminOverviewView, AdminMembersView, AdminFeesView
│   │
│   ├── nutrition/
│   │   ├── domain/                          # Diet Entities & Interactors
│   │   ├── data/                            # Local Hive & Firestore sync
│   │   └── presentation/                    # NutritionScreen & Custom Macro Dialog
│   │
│   ├── workout/
│   │   ├── domain/                          # Exercise & Session Entities
│   │   ├── data/                            # Workout data sources & repositories
│   │   └── presentation/                    # WorkoutsScreen & ActiveWorkoutScreen
│   │
│   └── profile_growth/
│       ├── domain/                          # User Profile & Biomarker Entities
│       ├── data/                            # Measurement data sources & repositories
│       └── presentation/                    # GrowthRateScreen & ProfileBiomarkersScreen
│
├── screens/                                 # User Presentation Screens
├── main.dart                                # Multi-site URL router (/admin vs /user)
├── main_admin.dart                          # Standalone Admin Web Application Entry Point
└── main_user.dart                           # Standalone User Mobile Application Entry Point
```

---

## 🚀 Quick Start & CLI Commands

### 1. Run Standalone Admin Web Portal
```bash
flutter run -t lib/main_admin.dart -d chrome
```

### 2. Run Standalone User Mobile App
```bash
flutter run -t lib/main_user.dart
```

### 3. Run Unified Web Routing (/admin & /user)
```bash
flutter run -d chrome --web-port=8080
```

### 4. Build Production Releases
```bash
# Build Admin Web Release
flutter build web -t lib/main_admin.dart --release --output=build/web_admin

# Build User Web Release
flutter build web -t lib/main.dart --release --output=build/web_user

# Build Android APK Release
flutter build apk -t lib/main_user.dart --release
```

---

## 🌿 Git Branching Strategy

* `main` — Production-ready release branch.
* `develop` — Active development and feature integration branch.
* `feature/admin-portal` — Ongoing Admin Web Portal feature enhancements.
* `feature/user-app` — Ongoing Member Mobile & Web app features.

---

## 📄 License
Licensed under the [MIT License](LICENSE).
