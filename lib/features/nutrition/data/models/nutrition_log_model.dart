import '../../domain/entities/food_item_entity.dart';

class FoodItemModel extends FoodItemEntity {
  const FoodItemModel({
    required super.id,
    required super.name,
    required super.proteinG,
    required super.carbsG,
    required super.fatG,
    required super.calories,
    required super.category,
    required super.timestamp,
  });

  factory FoodItemModel.fromEntity(FoodItemEntity entity) {
    return FoodItemModel(
      id: entity.id,
      name: entity.name,
      proteinG: entity.proteinG,
      carbsG: entity.carbsG,
      fatG: entity.fatG,
      calories: entity.calories,
      category: entity.category,
      timestamp: entity.timestamp,
    );
  }

  factory FoodItemModel.fromMap(Map<String, dynamic> map) {
    return FoodItemModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      proteinG: (map['proteinG'] as num?)?.toDouble() ?? 0.0,
      carbsG: (map['carbsG'] as num?)?.toDouble() ?? 0.0,
      fatG: (map['fatG'] as num?)?.toDouble() ?? 0.0,
      calories: (map['calories'] as num?)?.toDouble() ?? 0.0,
      category: MealCategoryEntity.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => MealCategoryEntity.snack,
      ),
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

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
}

class DailyNutritionLogModel extends DailyNutritionEntity {
  const DailyNutritionLogModel({
    required super.dateKey,
    required super.meals,
    super.waterMl = 0,
  });

  factory DailyNutritionLogModel.fromEntity(DailyNutritionEntity entity) {
    return DailyNutritionLogModel(
      dateKey: entity.dateKey,
      meals: entity.meals,
      waterMl: entity.waterMl,
    );
  }

  factory DailyNutritionLogModel.fromMap(Map<String, dynamic> map) {
    final rawMeals = map['meals'] as List? ?? [];
    return DailyNutritionLogModel(
      dateKey: map['dateKey'] ?? '',
      meals: rawMeals
          .map((m) => FoodItemModel.fromMap(Map<String, dynamic>.from(m)))
          .toList(),
      waterMl: map['waterMl'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dateKey': dateKey,
      'meals': meals.map((m) => FoodItemModel.fromEntity(m).toMap()).toList(),
      'waterMl': waterMl,
    };
  }
}
