# 📱 ApexGym User Mobile Application (Athlete App)

> **Official Specification & Architectural Documentation for Gym Members on iOS & Android Smartphones**

---

## 1. Executive Summary & Purpose

**ApexGym User Mobile App** is a fast, offline-first mobile application built for athletes actively training inside the gym. Engineered for seamless one-handed operation, it provides live workout set logging, automated countdown rest timers, quick-tap nutrition presets, and personal fee status monitoring.

---

## 2. Target Audience & Mobile Training Context

* **Everyday Gym Members & Powerlifters**: Logging sets, reps, and RPE ratings between working sets on mobile phones.
* **Athletes in Training**: Relying on accurate rest timers, hydration logging, and tracking training volume on the gym floor.

---

## 3. Core Functional Modules

### A. Live Active Workout Runner
* **Session Execution Engine**:
  * Step-by-step workout logger based on active split (e.g. *Push Day: Bench Press, Incline Dumbbell Press, Overhead Press, Lateral Raises, Tricep Pushdowns*).
  * Check off completed sets to automatically record volume.
  * Real-time calculation of total weight volume lifted ($kg$) and total completed sets.
* **Automated Rest Timer**:
  * Triggered automatically upon set completion.
  * 90-second default countdown with `+30s` quick extension and cancel actions.
* **Persistent Active Workout Mini-Bar**:
  * Pinned floating bar at the bottom of the screen allowing the athlete to navigate nutrition, biomarkers, or fees without losing active session state.
* **Session Summary**:
  * Saves workout duration, exercise list, and total volume to personal history.

### B. User-Selected Diet & Quick Meal Logger
* **Diet Protocol Selection**:
  * Choose between preset scientific plans (*Hypertrophy, Lean Shred, Bulking, Vegetarian, Keto*) or build a **Custom Macro Goal**.
* **Quick High-Protein Presets**:
  * One-tap buttons to log standard protein sources (*Whey Protein Shake, Eggs & Oats, Chicken Breast & Rice, Tuna Salad, Greek Yogurt*).
* **Hydration Counter**:
  * Fast `+250ml` and `+500ml` buttons to log water intake during training.

### C. Body Metrics & Growth Tracker
* **Biomarkers & Body Scans**:
  * Log weight checkpoints, body fat %, and circumference measurements.
* **Adaptive Recommendations**:
  * Scientific feedback explaining progressive overload principles, leucine triggers, and rest interval science.

### D. My Membership & Fees Overview
* **Status Badge**:
  * Clear `ACTIVE`, `PENDING`, or `OVERDUE` badge on the user header.
* **Billing Overview**:
  * View monthly fee amount, due day of the month, and transaction receipts.

---

## 4. Clean Architecture Structure & Layer Mapping

```
lib/
├── core/
│   ├── di/
│   │   └── service_locator.dart             # Dependency Injection Container (sl)
│   └── theme/
│       └── gym_theme.dart                   # High-contrast OLED dark theme
│
├── features/
│   ├── workout/
│   │   ├── domain/
│   │   │   ├── entities/                    # ExerciseEntity, WorkoutSetEntity, WorkoutSplitEntity, CompletedWorkoutSessionEntity
│   │   │   ├── repositories/                # WorkoutRepository (Contract)
│   │   │   └── usecases/                    # GetWorkoutSplitsUseCase, SaveCustomSplitUseCase, SaveCompletedSessionUseCase
│   │   └── data/
│   │       ├── models/                      # ExerciseModel, WorkoutSetModel
│   │       ├── datasources/                 # WorkoutLocalDataSource (Hive)
│   │       └── repositories/                # WorkoutRepositoryImpl
│   │
│   ├── nutrition/
│   │   ├── domain/
│   │   │   ├── entities/                    # DietPlanEntity, FoodItemEntity, DailyNutritionEntity
│   │   │   ├── repositories/                # NutritionRepository
│   │   │   └── usecases/                    # SelectDietPlanUseCase, AddFoodItemUseCase, UpdateWaterUseCase
│   │   └── data/
│   │       ├── models/                      # DietPlanModel, FoodItemModel, DailyNutritionLogModel
│   │       ├── datasources/                 # NutritionLocalDataSource (Hive)
│   │       └── repositories/                # NutritionRepositoryImpl
│   │
│   └── profile_growth/
│       ├── domain/
│       │   ├── entities/                    # UserProfileEntity, BodyMeasurementEntity
│       │   ├── repositories/                # ProfileRepository
│       │   └── usecases/                    # GetUserProfileUseCase, LogMeasurementUseCase
│       └── data/
│           ├── datasources/                 # ProfileLocalDataSource (Hive)
│           └── repositories/                # ProfileRepositoryImpl
│
├── screens/
│   ├── member_home_shell.dart               # Mobile Nav & Persistent Active Session Mini-Bar
│   ├── active_workout_screen.dart           # Live Workout Runner with Auto Rest Timer
│   ├── workouts_screen.dart                 # Splits Catalog
│   ├── nutrition_screen.dart                # Diet Protocol & Quick Meal Logger
│   ├── profile_biomarkers_screen.dart       # Body Measurements
│   ├── growth_rate_screen.dart              # Growth Trajectory Analytics
│   └── user_fees_screen.dart                # Member Fee & Receipt Screen
│
└── main_user.dart                           # Standalone User Mobile Application Entry Point
```

---

## 5. Mobile Development & Build Commands

### Run on Mobile Simulator / Connected Device
```bash
# Run standalone User Mobile App on Android/iOS
flutter run -t lib/main_user.dart
```

### Build Android Release APK
```bash
# Build standalone Android APK
flutter build apk -t lib/main_user.dart --release
```

### Build Android App Bundle for Google Play
```bash
# Build Android App Bundle (.aab)
flutter build appbundle -t lib/main_user.dart --release
```

### Build iOS Release App
```bash
# Build iOS bundle for App Store
flutter build ipa -t lib/main_user.dart --release
```

---

## 6. Mobile UX & Performance Highlights

* **Offline-First Resilience**: Full workout tracking and meal logging works 100% offline via Hive caching.
* **Dark Mode Aesthetics**: Battery-saving OLED dark theme with high-contrast neon accents for gym environments.
* **Zero-Lag State**: Instant state updates across Provider listeners for real-time timer countdowns.
