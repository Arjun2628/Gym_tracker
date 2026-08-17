import '../../domain/entities/diet_plan_entity.dart';
import '../../domain/entities/food_item_entity.dart';
import '../../domain/repositories/nutrition_repository.dart';
import '../datasources/nutrition_local_datasource.dart';
import '../models/diet_plan_model.dart';
import '../models/nutrition_log_model.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final NutritionLocalDataSource localDataSource;

  NutritionRepositoryImpl({required this.localDataSource});

  @override
  Future<DietPlanEntity?> getActiveDiet() async {
    return localDataSource.getActiveDiet();
  }

  @override
  Future<void> saveActiveDiet(DietPlanEntity diet) async {
    final model = DietPlanModel.fromEntity(diet);
    await localDataSource.saveActiveDiet(model);
  }

  @override
  Future<List<DietPlanEntity>> getCustomDiets() async {
    return localDataSource.getCustomDiets();
  }

  @override
  Future<void> saveCustomDiet(DietPlanEntity diet) async {
    final model = DietPlanModel.fromEntity(diet);
    await localDataSource.saveCustomDiet(model);
  }

  @override
  Future<DailyNutritionEntity> getTodayNutrition(String dateKey) async {
    final log = await localDataSource.getDailyNutrition(dateKey);
    if (log != null) return log;
    return DailyNutritionEntity(dateKey: dateKey, meals: [], waterMl: 0);
  }

  @override
  Future<void> saveTodayNutrition(DailyNutritionEntity nutrition) async {
    final model = DailyNutritionLogModel.fromEntity(nutrition);
    await localDataSource.saveDailyNutrition(model);
  }
}
