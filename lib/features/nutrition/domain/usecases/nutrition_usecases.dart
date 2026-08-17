import '../entities/diet_plan_entity.dart';
import '../entities/food_item_entity.dart';
import '../repositories/nutrition_repository.dart';

class GetActiveDietUseCase {
  final NutritionRepository repository;
  GetActiveDietUseCase(this.repository);

  Future<DietPlanEntity?> call() => repository.getActiveDiet();
}

class SelectDietPlanUseCase {
  final NutritionRepository repository;
  SelectDietPlanUseCase(this.repository);

  Future<void> call(DietPlanEntity diet) => repository.saveActiveDiet(diet);
}

class SaveCustomDietUseCase {
  final NutritionRepository repository;
  SaveCustomDietUseCase(this.repository);

  Future<void> call(DietPlanEntity customDiet) async {
    await repository.saveCustomDiet(customDiet);
    await repository.saveActiveDiet(customDiet);
  }
}

class AddFoodItemUseCase {
  final NutritionRepository repository;
  AddFoodItemUseCase(this.repository);

  Future<DailyNutritionEntity> call(DailyNutritionEntity current, FoodItemEntity item) async {
    final updatedMeals = List<FoodItemEntity>.from(current.meals)..add(item);
    final updated = DailyNutritionEntity(
      dateKey: current.dateKey,
      meals: updatedMeals,
      waterMl: current.waterMl,
    );
    await repository.saveTodayNutrition(updated);
    return updated;
  }
}

class RemoveFoodItemUseCase {
  final NutritionRepository repository;
  RemoveFoodItemUseCase(this.repository);

  Future<DailyNutritionEntity> call(DailyNutritionEntity current, String itemId) async {
    final updatedMeals = List<FoodItemEntity>.from(current.meals)..removeWhere((m) => m.id == itemId);
    final updated = DailyNutritionEntity(
      dateKey: current.dateKey,
      meals: updatedMeals,
      waterMl: current.waterMl,
    );
    await repository.saveTodayNutrition(updated);
    return updated;
  }
}

class UpdateWaterUseCase {
  final NutritionRepository repository;
  UpdateWaterUseCase(this.repository);

  Future<DailyNutritionEntity> call(DailyNutritionEntity current, int deltaMl) async {
    final updated = DailyNutritionEntity(
      dateKey: current.dateKey,
      meals: current.meals,
      waterMl: (current.waterMl + deltaMl).clamp(0, 10000),
    );
    await repository.saveTodayNutrition(updated);
    return updated;
  }
}
