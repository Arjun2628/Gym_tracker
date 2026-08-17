import '../entities/diet_plan_entity.dart';
import '../entities/food_item_entity.dart';

abstract class NutritionRepository {
  Future<DietPlanEntity?> getActiveDiet();
  Future<void> saveActiveDiet(DietPlanEntity diet);
  Future<List<DietPlanEntity>> getCustomDiets();
  Future<void> saveCustomDiet(DietPlanEntity diet);
  Future<DailyNutritionEntity> getTodayNutrition(String dateKey);
  Future<void> saveTodayNutrition(DailyNutritionEntity nutrition);
}
