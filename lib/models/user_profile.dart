import 'dart:convert';

enum Gender { male, female }

enum ActivityLevel {
  sedentary('Sedentary (Desk job, minimal exercise)', 1.2),
  light('Lightly Active (1-3 gym days/wk)', 1.375),
  moderate('Moderately Active (3-5 gym days/wk)', 1.55),
  heavy('Very Active (6-7 intense gym days/wk)', 1.725),
  athlete('Elite Athlete / Physical Labor (2x/day)', 1.9);

  final String label;
  final double multiplier;
  const ActivityLevel(this.label, this.multiplier);
}

enum FitnessGoal {
  fatLoss('Cutting (Fat Loss)', -500, 2.2, 'Preserve lean mass with high protein & calorie deficit'),
  maintenance('Maintenance / Recomp', 0, 1.8, 'Maintain weight while improving body composition'),
  leanBulk('Lean Hypertrophy (Muscle Gain)', 250, 2.0, 'Optimize muscle protein synthesis with minimal fat gain'),
  aggressiveBulk('Aggressive Bulk', 500, 1.8, 'Rapid weight and mass gain with high caloric surplus'),
  strength('Pure Strength & Power', 150, 2.2, 'Fuel central nervous system recovery & maximum output');

  final String label;
  final int calorieAdjustment;
  final double proteinMultiplier; // grams per kg bodyweight
  final String description;
  const FitnessGoal(this.label, this.calorieAdjustment, this.proteinMultiplier, this.description);
}

class UserProfile {
  String name;
  double weightKg;
  double heightCm;
  int age;
  Gender gender;
  ActivityLevel activityLevel;
  FitnessGoal goal;
  double targetWeightKg;
  int targetWeeks;
  double customProteinGPerKg; // 0 if using default goal multiplier
  double? customDailyCalories;
  double? customDailyProteinG;
  double? customDailyCarbsG;
  double? customDailyFatG;

  UserProfile({
    this.name = 'Athlete',
    this.weightKg = 75.0,
    this.heightCm = 178.0,
    this.age = 25,
    this.gender = Gender.male,
    this.activityLevel = ActivityLevel.moderate,
    this.goal = FitnessGoal.leanBulk,
    this.targetWeightKg = 80.0,
    this.targetWeeks = 16,
    this.customProteinGPerKg = 0.0,
    this.customDailyCalories,
    this.customDailyProteinG,
    this.customDailyCarbsG,
    this.customDailyFatG,
  });

  /// BMI = weight (kg) / (height (m))^2
  double get bmi {
    if (heightCm <= 0) return 0;
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  String get bmiCategory {
    final b = bmi;
    if (b < 18.5) return 'Underweight';
    if (b < 25.0) return 'Normal Weight';
    if (b < 30.0) return 'Overweight (Athletic)';
    return 'Obese Class I+';
  }

  /// Mifflin-St Jeor BMR Equation
  /// Men: 10 * weight(kg) + 6.25 * height(cm) - 5 * age(y) + 5
  /// Women: 10 * weight(kg) + 6.25 * height(cm) - 5 * age(y) - 161
  double get bmr {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return gender == Gender.male ? base + 5 : base - 161;
  }

  /// Total Daily Energy Expenditure
  double get tdee => bmr * activityLevel.multiplier;

  /// Target Daily Calories based on Goal or Custom Diet
  double get targetCalories => customDailyCalories != null && customDailyCalories! > 0
      ? customDailyCalories!
      : (tdee + goal.calorieAdjustment).clamp(1200.0, 5000.0);

  /// Effective protein ratio (g/kg)
  double get effectiveProteinPerKg =>
      customProteinGPerKg > 0 ? customProteinGPerKg : goal.proteinMultiplier;

  /// Required Daily Protein in grams
  double get dailyProteinTargetGrams => customDailyProteinG != null && customDailyProteinG! > 0
      ? customDailyProteinG!
      : weightKg * effectiveProteinPerKg;

  /// Macro breakdown in grams and calories
  Map<String, double> get macroBreakdown {
    final proteinG = dailyProteinTargetGrams;
    final proteinKcal = proteinG * 4.0;

    final fatG = customDailyFatG != null && customDailyFatG! > 0
        ? customDailyFatG!
        : (weightKg * 0.9).clamp(40.0, 120.0);
    final fatKcal = fatG * 9.0;

    final carbG = customDailyCarbsG != null && customDailyCarbsG! > 0
        ? customDailyCarbsG!
        : ((targetCalories - (proteinKcal + fatKcal)).clamp(0.0, targetCalories) / 4.0);
    final carbKcal = carbG * 4.0;

    return {
      'proteinG': proteinG,
      'proteinKcal': proteinKcal,
      'fatG': fatG,
      'fatKcal': fatKcal,
      'carbG': carbG,
      'carbKcal': carbKcal,
      'totalKcal': targetCalories,
    };
  }

  /// Ideal normal BMI weight range in kg
  (double, double) get idealWeightRange {
    final heightM = heightCm / 100.0;
    final minW = 18.5 * (heightM * heightM);
    final maxW = 24.9 * (heightM * heightM);
    return (minW, maxW);
  }

  /// Target weekly growth / loss rate in kg/week
  double get plannedWeeklyGrowthRateKg {
    if (targetWeeks <= 0) return 0;
    final totalDelta = targetWeightKg - weightKg;
    return totalDelta / targetWeeks;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'age': age,
      'gender': gender.name,
      'activityLevel': activityLevel.name,
      'goal': goal.name,
      'targetWeightKg': targetWeightKg,
      'targetWeeks': targetWeeks,
      'customProteinGPerKg': customProteinGPerKg,
      'customDailyCalories': customDailyCalories,
      'customDailyProteinG': customDailyProteinG,
      'customDailyCarbsG': customDailyCarbsG,
      'customDailyFatG': customDailyFatG,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? 'Athlete',
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 75.0,
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 178.0,
      age: (map['age'] as num?)?.toInt() ?? 25,
      gender: Gender.values.firstWhere(
        (e) => e.name == map['gender'],
        orElse: () => Gender.male,
      ),
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == map['activityLevel'],
        orElse: () => ActivityLevel.moderate,
      ),
      goal: FitnessGoal.values.firstWhere(
        (e) => e.name == map['goal'],
        orElse: () => FitnessGoal.leanBulk,
      ),
      targetWeightKg: (map['targetWeightKg'] as num?)?.toDouble() ?? 80.0,
      targetWeeks: (map['targetWeeks'] as num?)?.toInt() ?? 16,
      customProteinGPerKg: (map['customProteinGPerKg'] as num?)?.toDouble() ?? 0.0,
      customDailyCalories: (map['customDailyCalories'] as num?)?.toDouble(),
      customDailyProteinG: (map['customDailyProteinG'] as num?)?.toDouble(),
      customDailyCarbsG: (map['customDailyCarbsG'] as num?)?.toDouble(),
      customDailyFatG: (map['customDailyFatG'] as num?)?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
