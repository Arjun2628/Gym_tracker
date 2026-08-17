import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_app/models/user_profile.dart';
import 'package:gym_tracker_app/models/growth_log.dart';
import 'package:gym_tracker_app/models/workout_models.dart';
import 'package:gym_tracker_app/models/nutrition_log.dart';

void main() {
  group('Biomarker & Energy Balance Formulas', () {
    test('Calculates BMI accurately', () {
      final profile = UserProfile(weightKg: 80.0, heightCm: 180.0);
      // BMI = 80 / (1.8 * 1.8) = 24.69
      expect(profile.bmi, closeTo(24.69, 0.05));
      expect(profile.bmiCategory, equals('Normal Weight'));
    });

    test('Mifflin-St Jeor BMR for Male', () {
      // Men: 10 * weight(80) + 6.25 * height(180) - 5 * age(25) + 5
      // 800 + 1125 - 125 + 5 = 1805
      final profile = UserProfile(
        weightKg: 80.0,
        heightCm: 180.0,
        age: 25,
        gender: Gender.male,
      );
      expect(profile.bmr, equals(1805.0));
    });

    test('Mifflin-St Jeor BMR for Female', () {
      // Women: 10 * weight(60) + 6.25 * height(165) - 5 * age(30) - 161
      // 600 + 1031.25 - 150 - 161 = 1320.25
      final profile = UserProfile(
        weightKg: 60.0,
        heightCm: 165.0,
        age: 30,
        gender: Gender.female,
      );
      expect(profile.bmr, closeTo(1320.25, 0.05));
    });

    test('TDEE with Moderate Activity multiplier (1.55)', () {
      final profile = UserProfile(
        weightKg: 80.0,
        heightCm: 180.0,
        age: 25,
        gender: Gender.male,
        activityLevel: ActivityLevel.moderate,
      );
      // 1805 * 1.55 = 2797.75
      expect(profile.tdee, closeTo(2797.75, 0.1));
    });

    test('Daily Protein requirement calculation', () {
      final bulkProfile = UserProfile(
        weightKg: 75.0,
        goal: FitnessGoal.leanBulk, // 2.0g/kg
      );
      expect(bulkProfile.dailyProteinTargetGrams, equals(150.0));

      final cutProfile = UserProfile(
        weightKg: 75.0,
        goal: FitnessGoal.fatLoss, // 2.2g/kg
      );
      expect(cutProfile.dailyProteinTargetGrams, equals(165.0));
    });
  });

  group('Growth Rate Velocity Calculations', () {
    test('Computes weekly velocity kg and status', () {
      final now = DateTime.now();
      final logs = [
        BodyMeasurement(
          id: '1',
          date: now.subtract(const Duration(days: 14)),
          weightKg: 74.0,
        ),
        BodyMeasurement(
          id: '2',
          date: now,
          weightKg: 74.6,
        ),
      ];

      // Gained 0.6kg in 14 days -> 0.30 kg/week
      final analysis = GrowthRateAnalysis.fromLogs(logs, FitnessGoal.leanBulk.name);
      expect(analysis.totalDeltaKg, closeTo(0.6, 0.05));
      expect(analysis.weeklyVelocityKg, closeTo(0.30, 0.05));
      expect(analysis.statusLabel, contains('Optimal Lean Hypertrophy Pace'));
    });
  });

  group('Strength & 1RM Calculations', () {
    test('Epley 1RM Formula', () {
      final set = WorkoutSet(setNumber: 1, weightKg: 100.0, reps: 5);
      // 100 * (1 + 5/30) = 116.666
      expect(set.estimatedOneRepMax, closeTo(116.67, 0.1));
    });

    test('Set volume computation', () {
      final set = WorkoutSet(setNumber: 1, weightKg: 80.0, reps: 10, isCompleted: true);
      expect(set.setVolume, equals(800.0));
    });
  });

  group('Nutrition Logging Calculations', () {
    test('Computes total macros and calories accurately', () {
      final log = DailyNutritionLog(dateKey: '2026-08-18', meals: [
        FoodItem(
          id: 'm1',
          name: 'Chicken Breast',
          proteinG: 60.0,
          carbsG: 0.0,
          fatG: 5.0,
          calories: 300.0,
          category: MealCategory.lunch,
          timestamp: DateTime.now(),
        ),
        FoodItem(
          id: 'm2',
          name: 'Rice',
          proteinG: 5.0,
          carbsG: 60.0,
          fatG: 1.0,
          calories: 280.0,
          category: MealCategory.lunch,
          timestamp: DateTime.now(),
        ),
      ]);

      expect(log.totalProteinG, equals(65.0));
      expect(log.totalCarbsG, equals(60.0));
      expect(log.totalFatG, equals(6.0));
      expect(log.totalCalories, equals(580.0));
    });
  });
}
