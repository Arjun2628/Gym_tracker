
enum MealCategory {
  breakfast('Breakfast', '🍳'),
  lunch('Lunch', '🥗'),
  dinner('Dinner', '🥩'),
  snack('Snack', '🍎'),
  preWorkout('Pre-Workout', '⚡'),
  postWorkout('Post-Workout Shake', '🥤');

  final String label;
  final String icon;
  const MealCategory(this.label, this.icon);
}

class FoodItem {
  final String id;
  final String name;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double calories;
  final MealCategory category;
  final DateTime timestamp;

  FoodItem({
    required this.id,
    required this.name,
    required this.proteinG,
    this.carbsG = 0.0,
    this.fatG = 0.0,
    required this.calories,
    required this.category,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'proteinG': proteinG,
      'carbsG': carbsG,
      'fatG': fatG,
      'calories': calories,
      'category': category.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      proteinG: (map['proteinG'] as num?)?.toDouble() ?? 0.0,
      carbsG: (map['carbsG'] as num?)?.toDouble() ?? 0.0,
      fatG: (map['fatG'] as num?)?.toDouble() ?? 0.0,
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      category: MealCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => MealCategory.snack,
      ),
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class NutritionPreset {
  final String name;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double calories;
  final MealCategory defaultCategory;
  final String icon;

  const NutritionPreset({
    required this.name,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.calories,
    required this.defaultCategory,
    required this.icon,
  });
}

const List<NutritionPreset> kQuickNutritionPresets = [
  NutritionPreset(
    name: 'Whey Protein Shake (1 Scoop)',
    proteinG: 25.0,
    carbsG: 3.0,
    fatG: 1.5,
    calories: 130.0,
    defaultCategory: MealCategory.postWorkout,
    icon: '🥤',
  ),
  NutritionPreset(
    name: 'Grilled Chicken Breast (200g)',
    proteinG: 62.0,
    carbsG: 0.0,
    fatG: 7.0,
    calories: 330.0,
    defaultCategory: MealCategory.lunch,
    icon: '🍗',
  ),
  NutritionPreset(
    name: '4 Whole Eggs (Scrambled/Boiled)',
    proteinG: 24.0,
    carbsG: 2.0,
    fatG: 20.0,
    calories: 284.0,
    defaultCategory: MealCategory.breakfast,
    icon: '🍳',
  ),
  NutritionPreset(
    name: 'Greek Yogurt (200g Plain 0%)',
    proteinG: 20.0,
    carbsG: 7.0,
    fatG: 0.5,
    calories: 118.0,
    defaultCategory: MealCategory.snack,
    icon: '🥣',
  ),
  NutritionPreset(
    name: 'Canned Tuna in Water (1 Can - 160g)',
    proteinG: 32.0,
    carbsG: 0.0,
    fatG: 1.0,
    calories: 145.0,
    defaultCategory: MealCategory.lunch,
    icon: '🐟',
  ),
  NutritionPreset(
    name: 'Sirloin Beef Steak (200g)',
    proteinG: 52.0,
    carbsG: 0.0,
    fatG: 16.0,
    calories: 380.0,
    defaultCategory: MealCategory.dinner,
    icon: '🥩',
  ),
  NutritionPreset(
    name: 'Protein Bar (Standard 60g)',
    proteinG: 20.0,
    carbsG: 22.0,
    fatG: 8.0,
    calories: 220.0,
    defaultCategory: MealCategory.snack,
    icon: '🍫',
  ),
  NutritionPreset(
    name: 'Extra Firm Tofu (200g)',
    proteinG: 24.0,
    carbsG: 4.0,
    fatG: 11.0,
    calories: 200.0,
    defaultCategory: MealCategory.dinner,
    icon: '🧈',
  ),
];

class DailyNutritionLog {
  final String dateKey; // YYYY-MM-DD
  final List<FoodItem> meals;
  int waterMl;

  DailyNutritionLog({
    required this.dateKey,
    List<FoodItem>? meals,
    this.waterMl = 0,
  }) : meals = meals ?? [];

  double get totalProteinG => meals.fold(0.0, (sum, item) => sum + item.proteinG);
  double get totalCarbsG => meals.fold(0.0, (sum, item) => sum + item.carbsG);
  double get totalFatG => meals.fold(0.0, (sum, item) => sum + item.fatG);
  double get totalCalories => meals.fold(0.0, (sum, item) => sum + item.calories);

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'meals': meals.map((m) => m.toMap()).toList(),
      'waterMl': waterMl,
    };
  }

  factory DailyNutritionLog.fromMap(Map<String, dynamic> map) {
    return DailyNutritionLog(
      dateKey: map['dateKey'] ?? '',
      meals: (map['meals'] as List<dynamic>?)
              ?.map((m) => FoodItem.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      waterMl: (map['waterMl'] as num?)?.toInt() ?? 0,
    );
  }
}
