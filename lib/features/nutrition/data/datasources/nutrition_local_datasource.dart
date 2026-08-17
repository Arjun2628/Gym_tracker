import 'package:hive_flutter/hive_flutter.dart';
import '../models/diet_plan_model.dart';
import '../models/nutrition_log_model.dart';

abstract class NutritionLocalDataSource {
  Future<DietPlanModel?> getActiveDiet();
  Future<void> saveActiveDiet(DietPlanModel diet);
  Future<List<DietPlanModel>> getCustomDiets();
  Future<void> saveCustomDiet(DietPlanModel diet);
  Future<DailyNutritionLogModel?> getDailyNutrition(String dateKey);
  Future<void> saveDailyNutrition(DailyNutritionLogModel log);
}

class NutritionLocalDataSourceImpl implements NutritionLocalDataSource {
  static const String dietsBoxName = 'apex_diets_box';
  static const String nutritionBoxName = 'apex_nutrition_box';

  Box get _dietsBox => Hive.box(dietsBoxName);
  Box get _nutritionBox => Hive.box(nutritionBoxName);

  @override
  Future<DietPlanModel?> getActiveDiet() async {
    final raw = _dietsBox.get('active_diet');
    if (raw != null) {
      return DietPlanModel.fromMap(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  @override
  Future<void> saveActiveDiet(DietPlanModel diet) async {
    await _dietsBox.put('active_diet', diet.toMap());
  }

  @override
  Future<List<DietPlanModel>> getCustomDiets() async {
    final raw = _dietsBox.get('custom_diets_list');
    if (raw != null && raw is List) {
      return raw
          .map((item) => DietPlanModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    }
    return [];
  }

  @override
  Future<void> saveCustomDiet(DietPlanModel diet) async {
    final current = await getCustomDiets();
    final updated = List<DietPlanModel>.from(current)..add(diet);
    await _dietsBox.put('custom_diets_list', updated.map((d) => d.toMap()).toList());
  }

  @override
  Future<DailyNutritionLogModel?> getDailyNutrition(String dateKey) async {
    final raw = _nutritionBox.get('log_$dateKey');
    if (raw != null) {
      return DailyNutritionLogModel.fromMap(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  @override
  Future<void> saveDailyNutrition(DailyNutritionLogModel log) async {
    await _nutritionBox.put('log_${log.dateKey}', log.toMap());
  }
}
