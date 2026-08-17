/// Domain Entity for Diet Plan
class DietPlanEntity {
  final String id;
  final String title;
  final String tag; // 'Hypertrophy', 'Fat Loss', 'Bulking', 'Vegetarian', 'Keto', 'Custom'
  final String description;
  final int targetCalories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;
  final List<String> mealSuggestions;
  final List<String> scientificBenefits;
  final bool isCustom;

  const DietPlanEntity({
    required this.id,
    required this.title,
    required this.tag,
    required this.description,
    required this.targetCalories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.mealSuggestions,
    required this.scientificBenefits,
    this.isCustom = false,
  });

  int get proteinCalories => proteinGrams * 4;
  int get carbsCalories => carbsGrams * 4;
  int get fatCalories => fatGrams * 9;

  double get proteinPercentage =>
      targetCalories > 0 ? (proteinCalories / targetCalories) * 100 : 0;
  double get carbsPercentage =>
      targetCalories > 0 ? (carbsCalories / targetCalories) * 100 : 0;
  double get fatPercentage =>
      targetCalories > 0 ? (fatCalories / targetCalories) * 100 : 0;
}
