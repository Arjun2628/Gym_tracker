enum MealCategoryEntity {
  breakfast('Breakfast', '🍳'),
  midMorning('Mid-Morning', '🥜'),
  lunch('Lunch', '🍗'),
  preWorkout('Pre-Workout', '🍌'),
  postWorkout('Post-Workout', '🥤'),
  dinner('Dinner', '🥩'),
  snack('Snack', '🍎');

  final String label;
  final String icon;
  const MealCategoryEntity(this.label, this.icon);
}

class FoodItemEntity {
  final String id;
  final String name;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double calories;
  final MealCategoryEntity category;
  final DateTime timestamp;

  const FoodItemEntity({
    required this.id,
    required this.name,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.calories,
    required this.category,
    required this.timestamp,
  });
}

class DailyNutritionEntity {
  final String dateKey;
  final List<FoodItemEntity> meals;
  final int waterMl;

  const DailyNutritionEntity({
    required this.dateKey,
    required this.meals,
    this.waterMl = 0,
  });

  double get totalProteinG => meals.fold(0.0, (sum, item) => sum + item.proteinG);
  double get totalCarbsG => meals.fold(0.0, (sum, item) => sum + item.carbsG);
  double get totalFatG => meals.fold(0.0, (sum, item) => sum + item.fatG);
  double get totalCalories => meals.fold(0.0, (sum, item) => sum + item.calories);
}
