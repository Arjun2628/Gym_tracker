enum GenderEntity { male, female }

enum ActivityLevelEntity {
  sedentary('Sedentary (Desk job, minimal exercise)', 1.2),
  light('Lightly Active (1-3 gym days/wk)', 1.375),
  moderate('Moderately Active (3-5 gym days/wk)', 1.55),
  heavy('Very Active (6-7 intense gym days/wk)', 1.725),
  athlete('Elite Athlete / Physical Labor (2x/day)', 1.9);

  final String label;
  final double multiplier;
  const ActivityLevelEntity(this.label, this.multiplier);
}

enum FitnessGoalEntity {
  fatLoss('Cutting (Fat Loss)', -500, 2.2, 'Preserve lean mass with high protein & calorie deficit'),
  maintenance('Maintenance / Recomp', 0, 1.8, 'Maintain weight while improving body composition'),
  leanBulk('Lean Hypertrophy (Muscle Gain)', 250, 2.0, 'Optimize muscle protein synthesis with minimal fat gain'),
  aggressiveBulk('Aggressive Bulk', 500, 1.8, 'Rapid weight and mass gain with high caloric surplus'),
  strength('Pure Strength & Power', 150, 2.2, 'Fuel central nervous system recovery & maximum output');

  final String label;
  final int calorieAdjustment;
  final double proteinMultiplier;
  final String description;
  const FitnessGoalEntity(this.label, this.calorieAdjustment, this.proteinMultiplier, this.description);
}

class UserProfileEntity {
  String name;
  double weightKg;
  double heightCm;
  int age;
  GenderEntity gender;
  ActivityLevelEntity activityLevel;
  FitnessGoalEntity goal;
  double targetWeightKg;
  int targetWeeks;
  double customProteinGPerKg;
  double? customDailyCalories;
  double? customDailyProteinG;
  double? customDailyCarbsG;
  double? customDailyFatG;

  UserProfileEntity({
    this.name = 'Athlete',
    this.weightKg = 75.0,
    this.heightCm = 178.0,
    this.age = 25,
    this.gender = GenderEntity.male,
    this.activityLevel = ActivityLevelEntity.moderate,
    this.goal = FitnessGoalEntity.leanBulk,
    this.targetWeightKg = 80.0,
    this.targetWeeks = 16,
    this.customProteinGPerKg = 0.0,
    this.customDailyCalories,
    this.customDailyProteinG,
    this.customDailyCarbsG,
    this.customDailyFatG,
  });

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

  double get bmr {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return gender == GenderEntity.male ? base + 5 : base - 161;
  }

  double get tdee => bmr * activityLevel.multiplier;

  double get targetCalories => customDailyCalories != null && customDailyCalories! > 0
      ? customDailyCalories!
      : (tdee + goal.calorieAdjustment).clamp(1200.0, 5000.0);

  double get effectiveProteinPerKg =>
      customProteinGPerKg > 0 ? customProteinGPerKg : goal.proteinMultiplier;

  double get dailyProteinTargetGrams => customDailyProteinG != null && customDailyProteinG! > 0
      ? customDailyProteinG!
      : weightKg * effectiveProteinPerKg;

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
}

class BodyMeasurementEntity {
  final String id;
  final DateTime date;
  final double weightKg;
  final double bodyFatPct;
  final double chestCm;
  final double armsCm;
  final double waistCm;
  final double thighsCm;
  final String notes;

  const BodyMeasurementEntity({
    required this.id,
    required this.date,
    required this.weightKg,
    required this.bodyFatPct,
    required this.chestCm,
    required this.armsCm,
    required this.waistCm,
    required this.thighsCm,
    this.notes = '',
  });
}
