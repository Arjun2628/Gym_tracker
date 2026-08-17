import '../../domain/entities/diet_plan_entity.dart';

class DietPlanModel extends DietPlanEntity {
  const DietPlanModel({
    required super.id,
    required super.title,
    required super.tag,
    required super.description,
    required super.targetCalories,
    required super.proteinGrams,
    required super.carbsGrams,
    required super.fatGrams,
    required super.mealSuggestions,
    required super.scientificBenefits,
    super.isCustom = false,
  });

  factory DietPlanModel.fromEntity(DietPlanEntity entity) {
    return DietPlanModel(
      id: entity.id,
      title: entity.title,
      tag: entity.tag,
      description: entity.description,
      targetCalories: entity.targetCalories,
      proteinGrams: entity.proteinGrams,
      carbsGrams: entity.carbsGrams,
      fatGrams: entity.fatGrams,
      mealSuggestions: entity.mealSuggestions,
      scientificBenefits: entity.scientificBenefits,
      isCustom: entity.isCustom,
    );
  }

  factory DietPlanModel.fromMap(Map<String, dynamic> map) {
    return DietPlanModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      tag: map['tag'] ?? 'Custom',
      description: map['description'] ?? '',
      targetCalories: map['targetCalories'] ?? 2000,
      proteinGrams: map['proteinGrams'] ?? 150,
      carbsGrams: map['carbsGrams'] ?? 200,
      fatGrams: map['fatGrams'] ?? 60,
      mealSuggestions: List<String>.from(map['mealSuggestions'] ?? []),
      scientificBenefits: List<String>.from(map['scientificBenefits'] ?? []),
      isCustom: map['isCustom'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'tag': tag,
      'description': description,
      'targetCalories': targetCalories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'mealSuggestions': mealSuggestions,
      'scientificBenefits': scientificBenefits,
      'isCustom': isCustom,
    };
  }
}
