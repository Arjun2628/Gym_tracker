import 'dart:convert';

class DietPlan {
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

  DietPlan({
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

  double get proteinPercentage => targetCalories > 0 ? (proteinCalories / targetCalories) * 100 : 0;
  double get carbsPercentage => targetCalories > 0 ? (carbsCalories / targetCalories) * 100 : 0;
  double get fatPercentage => targetCalories > 0 ? (fatCalories / targetCalories) * 100 : 0;

  DietPlan copyWith({
    String? id,
    String? title,
    String? tag,
    String? description,
    int? targetCalories,
    int? proteinGrams,
    int? carbsGrams,
    int? fatGrams,
    List<String>? mealSuggestions,
    List<String>? scientificBenefits,
    bool? isCustom,
  }) {
    return DietPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      tag: tag ?? this.tag,
      description: description ?? this.description,
      targetCalories: targetCalories ?? this.targetCalories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      mealSuggestions: mealSuggestions ?? this.mealSuggestions,
      scientificBenefits: scientificBenefits ?? this.scientificBenefits,
      isCustom: isCustom ?? this.isCustom,
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

  factory DietPlan.fromMap(Map<String, dynamic> map) {
    return DietPlan(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      tag: map['tag'] ?? 'Custom',
      description: map['description'] ?? '',
      targetCalories: (map['targetCalories'] as num?)?.toInt() ?? 2400,
      proteinGrams: (map['proteinGrams'] as num?)?.toInt() ?? 180,
      carbsGrams: (map['carbsGrams'] as num?)?.toInt() ?? 240,
      fatGrams: (map['fatGrams'] as num?)?.toInt() ?? 65,
      mealSuggestions: List<String>.from(map['mealSuggestions'] ?? []),
      scientificBenefits: List<String>.from(map['scientificBenefits'] ?? []),
      isCustom: map['isCustom'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory DietPlan.fromJson(String source) => DietPlan.fromMap(json.decode(source));
}

final List<DietPlan> kPresetDietPlans = [
  DietPlan(
    id: 'diet_hypertrophy_mass',
    title: 'High-Protein Hypertrophy',
    tag: 'Hypertrophy',
    description: 'Scientifically designed for maximum muscle protein synthesis (MPS) with balanced complex carbohydrates and clean healthy fats.',
    targetCalories: 2750,
    proteinGrams: 200,
    carbsGrams: 290,
    fatGrams: 65,
    scientificBenefits: [
      'Delivers ~2.2g protein per kg bodyweight for optimal leucine threshold triggering.',
      'Sustained glycogen replenishment to power intense progressive overload lifts.',
      'Controlled surplus (~300 kcal) minimizes adipose accumulation while maximizing myofibrillar growth.',
    ],
    mealSuggestions: [
      'Breakfast: 4 whole eggs + 100g oatmeal with banana & whey protein scoop.',
      'Mid-Morning: Greek yogurt (200g) with mixed berries & 20g crushed almonds.',
      'Lunch: 200g grilled chicken breast with 1.5 cups brown rice & steamed broccoli.',
      'Pre-Workout: 1 whole grain toast with peanut butter & black coffee.',
      'Post-Workout: 1 scoop whey isolate + rice cakes with honey.',
      'Dinner: 200g lean salmon fillet with sweet potato wedges & asparagus.',
    ],
  ),
  DietPlan(
    id: 'diet_lean_shred',
    title: 'Lean Shred & Fat Loss',
    tag: 'Fat Loss',
    description: 'High-protein, moderate-deficit protocol engineered to incinerate fat while preventing catabolic muscle tissue breakdown.',
    targetCalories: 2050,
    proteinGrams: 215,
    carbsGrams: 140,
    fatGrams: 55,
    scientificBenefits: [
      'Higher protein density (42% of total kcal) spares nitrogen balance in caloric deficit.',
      'Thermic effect of food (TEF) elevated, burning ~15% more resting calories during digestion.',
      'Targeted carb timing around training preserves workout strength and pump volume.',
    ],
    mealSuggestions: [
      'Breakfast: 5 egg whites + 1 whole egg omelette with spinach & 1 slice rye toast.',
      'Lunch: 220g extra lean turkey mince with quinoa salad & bell peppers.',
      'Afternoon: Protein shake with unsweetened almond milk & 1 green apple.',
      'Post-Workout: 30g whey isolate with 5g creatine monohydrate.',
      'Dinner: 220g white fish (cod/tilapia) with cauliflower rice & avocado (30g).',
    ],
  ),
  DietPlan(
    id: 'diet_clean_bulk',
    title: 'Clean Heavy Bulking',
    tag: 'Bulking',
    description: 'High-calorie energy density for hardgainers and high-volume powerlifters needing serious fuel for strength breakthroughs.',
    targetCalories: 3200,
    proteinGrams: 190,
    carbsGrams: 420,
    fatGrams: 75,
    scientificBenefits: [
      'Full glycogen saturation keeps intramuscular hydration and leverage peak during heavy singles.',
      'Promotes elevated anabolic hormones (IGF-1 & free testosterone support).',
      'Minimizes CNS exhaustion and accelerating post-session recovery kinetics.',
    ],
    mealSuggestions: [
      'Breakfast: 4 whole eggs, 2 bagels with cream cheese & 1 glass whole milk.',
      'Snack: Mass smoothie (whey, oats, peanut butter, banana, milk).',
      'Lunch: 250g lean beef mince with 2 cups jasmine rice & olive oil drizzle.',
      'Pre-Workout: 2 bananas + energy bar.',
      'Dinner: 250g grilled chicken thighs with mashed potatoes & sauteed green beans.',
      'Bedtime: 150g cottage cheese with honey & walnuts.',
    ],
  ),
  DietPlan(
    id: 'diet_veg_muscle',
    title: 'Vegetarian Muscle Fuel',
    tag: 'Vegetarian',
    description: 'Complete amino-acid profiling combining paneer, tofu, lentils, seeds, and plant proteins for peak vegetarian performance.',
    targetCalories: 2450,
    proteinGrams: 175,
    carbsGrams: 260,
    fatGrams: 68,
    scientificBenefits: [
      'Combines diverse plant protein sources to deliver a full PDCAAS score of 1.0.',
      'Rich in natural phytonutrients and dietary nitrates for nitric-oxide vascularity.',
      'High fiber ensures steady glycemic control and sustained insulin response.',
    ],
    mealSuggestions: [
      'Breakfast: 150g tofu scramble with turmeric, mushrooms & 2 whole wheat rotis/toasts.',
      'Mid-Day: Sprouts & chickpea salad with lemon and hemp seeds (20g).',
      'Lunch: 150g low-fat paneer curry with 1 cup brown rice & yellow dal.',
      'Post-Workout: Plant protein (pea + rice blend) with oats & soy milk.',
      'Dinner: Soya chunks stir-fry (75g dry) with mixed vegetables and quinoa.',
    ],
  ),
  DietPlan(
    id: 'diet_keto_anabolic',
    title: 'Keto Anabolic Protocol',
    tag: 'Keto',
    description: 'Ultra-low carb, ketogenic metabolic state utilizing fatty acids and ketone bodies for clean, non-inflammatory cellular energy.',
    targetCalories: 2200,
    proteinGrams: 165,
    carbsGrams: 25,
    fatGrams: 155,
    scientificBenefits: [
      'Eliminates insulin spikes and carb-induced lethargy while increasing fat oxidation rates.',
      'Stabilizes blood ketones (>1.0 mmol/L) for clean mental focus and endurance.',
      'Preserves muscular density through ketone-mediated anti-catabolism.',
    ],
    mealSuggestions: [
      'Breakfast: 3 scrambled eggs in butter with 2 slices bacon and sliced avocado.',
      'Lunch: Grilled chicken caesar salad (no croutons) with parmesan & extra virgin olive oil.',
      'Snack: Macadamia nuts (30g) and string cheese.',
      'Dinner: 250g ribeye steak with garlic butter sautéed zucchini.',
    ],
  ),
];
