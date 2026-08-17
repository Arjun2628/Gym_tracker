# 💻 ApexGym User Web Application (Member Portal)

> **Official Specification & Architectural Documentation for Gym Members on Desktop & Laptop Web Browsers**

---

## 1. Executive Summary & Purpose

**ApexGym User Web** provides gym athletes and members with a desktop-optimized portal to manage their fitness journey. Designed for use at home or work on laptops and wide screens, it enables in-depth nutrition planning, macro calculation, interactive progress visualization, and membership receipt viewing.

---

## 2. Target Audience & Primary Use Cases

* **Gym Members at Home / Work**: Reviewing long-term bodyweight changes, configuring complex diet splits, and printing fee receipts on desktop browsers.
* **Athletes Planning Weekly Nutrition**: Browsing comprehensive meal suggestions, macro ratios, and scientific benefits on large displays.

---

## 3. Core Functional Modules

### A. Diet & Nutrition Customization Hub
* **Active Diet Overview**:
  * Displays active protocol name, description, and target daily energy targets (Calories, Protein, Carbs, Fats).
* **Scientific Diet Protocol Selector**:
  * **High-Protein Hypertrophy** (40% Protein, 40% Carbs, 20% Fats - 2750 kcal).
  * **Lean Shred & Fat Loss** (45% Protein, 25% Carbs, 30% Fats - 2050 kcal).
  * **Clean Heavy Bulking** (30% Protein, 50% Carbs, 20% Fats - 3200 kcal).
  * **Vegetarian Muscle Fuel** (30% Protein, 45% Carbs, 25% Fats - 2450 kcal).
  * **Keto Anabolic Protocol** (30% Protein, 5% Carbs, 65% Fats - 2200 kcal).
* **Custom Macro Profile Builder**:
  * Custom inputs for exact daily Calories (kcal), Protein (g), Carbohydrates (g), and Dietary Fats (g).
* **Meal Plan & Timing Accordion**:
  * Suggested breakdown for Breakfast, Mid-Morning Snack, Lunch, Pre-Workout, Post-Workout, and Dinner.

### B. Daily Intake & Hydration Tracker
* **Macro Gauges & Progress Bars**:
  * Real-time circular gauges tracking consumed vs target Calories and Protein.
  * Linear progress bars for Carbohydrates and Dietary Fats.
* **Meal Log Ledger**:
  * Logged meals grouped with timestamp, timing category, and macro contributions.
* **Hydration Level Tracker**:
  * Visual water level indicator with quick logging buttons (`+250ml`, `+500ml`).

### C. Growth Rate & Biomarker Adaptation
* **Bodyweight Trend Chart**:
  * Interactive multi-point line graph charting bodyweight progression against baseline targets.
* **Body Part Circumference History**:
  * Measurements for Chest, Arms, Waist, and Thighs with weekly growth delta analysis.

### D. Personal Membership & Fee Ledger
* **Membership Plan Badge**:
  * Displays tier (*Monthly, Quarterly, Annual*), monthly rate, and renewal due date.
* **Payment Receipt History**:
  * Transaction history with receipt IDs, payment methods (*UPI, Cash, Card*), and status badges.

---

## 4. Clean Architecture Structure & Layer Mapping

```
lib/
├── core/
│   ├── di/
│   │   └── service_locator.dart             # Dependency Injection Container (sl)
│   └── theme/
│       └── gym_theme.dart                   # Theme Tokens & Colors
│
├── features/
│   ├── nutrition/
│   │   ├── domain/
│   │   │   ├── entities/                    # DietPlanEntity, FoodItemEntity, DailyNutritionEntity
│   │   │   ├── repositories/                # NutritionRepository (Contract)
│   │   │   └── usecases/                    # SelectDietPlanUseCase, SaveCustomDietUseCase, AddFoodItemUseCase, etc.
│   │   └── data/
│   │       ├── models/                      # DietPlanModel, FoodItemModel, DailyNutritionLogModel
│   │       ├── datasources/                 # NutritionLocalDataSource (Hive)
│   │       └── repositories/                # NutritionRepositoryImpl
├── core/                                        # Shared Clean Architecture Core
├── features/                                    # Domain Entities, Repositories & Use Cases
├── models/                                      # Data Models & Adapters
│
├── screens/
│   ├── member_home_shell.dart               # Responsive 2-Screen Sliding Member Shell
│   ├── dashboard_screen.dart                # Daily Overview & Quick Metrics
│   ├── nutrition_screen.dart                # Diet Protocol & Custom Macro Hub
│   ├── growth_rate_screen.dart              # Interactive Progression Charts
│   ├── workouts_screen.dart                 # Splits Directory & Live Session
│   └── user_fees_screen.dart                # Personal Membership & Fee Ledger
│
└── main_user.dart                               # Standalone User Web & Mobile Entry Point
```

---

## 5. Development & Deployment Commands

### Run Standalone User Web in Chrome (Single Athlete System)
```bash
# Run User Web portal directly on Chrome
flutter run -t lib/main_user.dart -d chrome
```

### Run on a Dedicated Port
```bash
# Run User Web on http://localhost:8080
flutter run -t lib/main_user.dart -d chrome --web-port=8090
```

### Run Admin Web (Separate System)
```bash
# Run Admin Web on http://localhost:8081
flutter run -t lib/main_admin.dart -d chrome --web-port=8091
```

### Build for Production Web Hosting
```bash
# Build standalone User Web production release
flutter build web -t lib/main_user.dart --release --output=build/web_user
```
*(Deploy to your web hosting bucket or CDN as the standalone Member Portal)*
