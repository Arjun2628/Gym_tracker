import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gym_provider.dart';
import '../models/nutrition_log.dart';
import '../models/science_context.dart';
import '../theme/gym_theme.dart';
import '../widgets/context_card.dart';
import '../widgets/circular_progress_gauge.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  void _showDietSelectionSheet(BuildContext context, GymProvider gym) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GymColors.cardBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.restaurant_menu, color: GymColors.neonGreen),
                      SizedBox(width: 10),
                      Text(
                        'SELECT & CUSTOMIZE DIET PROTOCOL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: GymColors.textMuted),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(color: GymColors.cardBorder, height: 20),

              Expanded(
                child: ListView.separated(
                  itemCount: gym.allDietPlans.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final diet = gym.allDietPlans[idx];
                    final isSelected = gym.activeDiet.id == diet.id;

                    Color tagColor = GymColors.neonGreen;
                    if (diet.tag == 'Fat Loss') tagColor = GymColors.neonAmber;
                    if (diet.tag == 'Bulking') tagColor = GymColors.neonCyan;
                    if (diet.tag == 'Vegetarian') tagColor = GymColors.neonGreen;
                    if (diet.tag == 'Keto') tagColor = GymColors.neonPurple;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? GymColors.neonGreen.withAlpha((0.1 * 255).round())
                            : GymColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? GymColors.neonGreen : GymColors.cardBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    diet.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: tagColor.withAlpha((0.2 * 255).round()),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      diet.tag.toUpperCase(),
                                      style: TextStyle(
                                        color: tagColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected)
                                const Row(
                                  children: [
                                    Icon(Icons.check_circle, color: GymColors.neonGreen, size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        color: GymColors.neonGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            diet.description,
                            style: const TextStyle(color: GymColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 10),

                          // Macro Targets Summary
                          Row(
                            children: [
                              _buildMacroChip('Calories', '${diet.targetCalories} kcal', GymColors.neonAmber),
                              const SizedBox(width: 8),
                              _buildMacroChip('Protein', '${diet.proteinGrams}g', GymColors.neonGreen),
                              const SizedBox(width: 8),
                              _buildMacroChip('Carbs', '${diet.carbsGrams}g', GymColors.neonCyan),
                              const SizedBox(width: 8),
                              _buildMacroChip('Fats', '${diet.fatGrams}g', GymColors.neonPurple),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (!isSelected)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GymColors.neonGreen,
                                foregroundColor: Colors.black,
                                minimumSize: const Size.fromHeight(36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                gym.selectDietPlan(diet);
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Activated ${diet.title} diet protocol!'),
                                    backgroundColor: GymColors.neonGreen,
                                  ),
                                );
                              },
                              child: const Text('ACTIVATE THIS DIET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Custom Diet Macro Builder Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymColors.surface,
                  foregroundColor: GymColors.neonCyan,
                  side: const BorderSide(color: GymColors.neonCyan),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('CREATE CUSTOM MACRO PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showCustomMacroDialog(context, gym);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCustomMacroDialog(BuildContext context, GymProvider gym) {
    final titleCtrl = TextEditingController(text: 'My Custom Athlete Macro Split');
    final calCtrl = TextEditingController(text: '2600');
    final proteinCtrl = TextEditingController(text: '190');
    final carbsCtrl = TextEditingController(text: '270');
    final fatCtrl = TextEditingController(text: '65');

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: GymColors.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: GymColors.cardBorder),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Custom Macro Diet Setup',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tailor daily calories and macronutrient ratios to your exact metabolic goals.',
                  style: TextStyle(color: GymColors.textSecondary, fontSize: 12),
                ),
                const Divider(color: GymColors.cardBorder, height: 24),

                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Diet Plan Name',
                    filled: true,
                    fillColor: GymColors.surface,
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: calCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Calories (kcal)',
                          filled: true,
                          fillColor: GymColors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: proteinCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Protein (g)',
                          filled: true,
                          fillColor: GymColors.surface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: carbsCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Carbs (g)',
                          filled: true,
                          fillColor: GymColors.surface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: fatCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Fats (g)',
                          filled: true,
                          fillColor: GymColors.surface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('CANCEL', style: TextStyle(color: GymColors.textMuted)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GymColors.neonGreen,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        final cal = int.tryParse(calCtrl.text) ?? 2400;
                        final p = int.tryParse(proteinCtrl.text) ?? 180;
                        final c = int.tryParse(carbsCtrl.text) ?? 240;
                        final f = int.tryParse(fatCtrl.text) ?? 65;

                        gym.saveCustomDiet(
                          title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : 'Custom Macro Plan',
                          tag: 'Custom',
                          description: 'User-customized macro split for individualized performance.',
                          calories: cal,
                          protein: p,
                          carbs: c,
                          fat: f,
                          suggestions: [
                            'Tailor high-leucine protein sources every 3-4 hours.',
                            'Hydrate with at least 3-4 liters of water daily.',
                          ],
                          benefits: [
                            'Targeted energy balance for specific body recomposition.',
                          ],
                        );

                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Custom Macro Plan applied & active!'),
                            backgroundColor: GymColors.neonGreen,
                          ),
                        );
                      },
                      child: const Text('APPLY & SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddCustomMealDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();
    final calCtrl = TextEditingController();
    MealCategory category = MealCategory.lunch;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: GymColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: GymColors.surfaceBorder),
              ),
              title: const Text('Add Custom Meal / Food', style: TextStyle(color: GymColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                      decoration: const InputDecoration(labelText: 'Food / Meal Name', prefixIcon: Icon(Icons.restaurant, size: 16, color: GymColors.neonGreen)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: proteinCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                            decoration: const InputDecoration(labelText: 'Protein (g)', prefixIcon: Icon(Icons.fitness_center, size: 16, color: GymColors.neonGreen)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: calCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                            decoration: const InputDecoration(labelText: 'Calories (kcal)', prefixIcon: Icon(Icons.local_fire_department, size: 16, color: GymColors.neonAmber)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: carbsCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                            decoration: const InputDecoration(labelText: 'Carbs (g)', prefixIcon: Icon(Icons.grain, size: 16, color: GymColors.neonCyan)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: fatCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                            decoration: const InputDecoration(labelText: 'Fats (g)', prefixIcon: Icon(Icons.egg, size: 16, color: GymColors.neonPurple)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<MealCategory>(
                      initialValue: category,
                      dropdownColor: GymColors.surfaceLight,
                      decoration: const InputDecoration(labelText: 'Meal Timing Category'),
                      items: MealCategory.values.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text('${c.icon} ${c.label}', style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: GymColors.textMuted)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: GymColors.neonGreen, foregroundColor: Colors.black),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final p = double.tryParse(proteinCtrl.text) ?? 0.0;
                    final c = double.tryParse(carbsCtrl.text) ?? 0.0;
                    final f = double.tryParse(fatCtrl.text) ?? 0.0;
                    var cal = double.tryParse(calCtrl.text) ?? 0.0;
                    if (cal <= 0 && (p > 0 || c > 0 || f > 0)) {
                      cal = (p * 4) + (c * 4) + (f * 9);
                    }

                    if (name.isNotEmpty && (p > 0 || cal > 0)) {
                      final item = FoodItem(
                        id: 'food_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        proteinG: p,
                        carbsG: c,
                        fatG: f,
                        calories: cal,
                        category: category,
                        timestamp: DateTime.now(),
                      );
                      context.read<GymProvider>().addFoodItem(item);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add Meal'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final activeDiet = gym.activeDiet;
    final nutrition = gym.todayNutrition;

    final targetProtein = activeDiet.proteinGrams.toDouble();
    final currentProtein = nutrition.totalProteinG;
    final targetCal = activeDiet.targetCalories.toDouble();
    final currentCal = nutrition.totalCalories;

    final targetCarb = activeDiet.carbsGrams.toDouble();
    final currentCarb = nutrition.totalCarbsG;
    final targetFat = activeDiet.fatGrams.toDouble();
    final currentFat = nutrition.totalFatG;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GymColors.background,
        elevation: 0,
        title: const Text(
          'DIET & NUTRITION ENGINE',
          style: TextStyle(
            color: GymColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: GymColors.neonGreen),
            tooltip: 'Add Custom Meal',
            onPressed: () => _showAddCustomMealDialog(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1050),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
          // Gourmet Nutrition Hero Banner
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.asset(
                  'assets/images/nutrition_banner.jpg',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha((0.85 * 255).round()),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 14,
                  right: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: GymColors.neonGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'MACRO FUEL',
                              style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Optimized Athletic Nutrition',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: GymColors.neonCyan,
                          side: const BorderSide(color: GymColors.neonCyan),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.tune, size: 14),
                        label: const Text('CUSTOM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _showCustomMacroDialog(context, gym),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 1. ACTIVE DIET PROTOCOL CARD (User Selected)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GymColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GymColors.neonGreen.withAlpha((0.4 * 255).round())),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: GymColors.neonGreen.withAlpha((0.15 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.restaurant, color: GymColors.neonGreen, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ACTIVE DIET PROTOCOL',
                              style: TextStyle(color: GymColors.neonGreen, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
                            ),
                            Text(
                              activeDiet.title,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GymColors.neonGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () => _showDietSelectionSheet(context, gym),
                      child: const Text('CHANGE DIET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  activeDiet.description,
                  style: const TextStyle(color: GymColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),

                // Macro breakdown pill row
                Row(
                  children: [
                    _buildMacroChip('Target Cal', '${activeDiet.targetCalories} kcal', GymColors.neonAmber),
                    const SizedBox(width: 8),
                    _buildMacroChip('Protein', '${activeDiet.proteinGrams}g', GymColors.neonGreen),
                    const SizedBox(width: 8),
                    _buildMacroChip('Carbs', '${activeDiet.carbsGrams}g', GymColors.neonCyan),
                    const SizedBox(width: 8),
                    _buildMacroChip('Fats', '${activeDiet.fatGrams}g', GymColors.neonPurple),
                  ],
                ),

                if (activeDiet.mealSuggestions.isNotEmpty) ...[
                  const Divider(color: GymColors.cardBorder, height: 20),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    dense: true,
                    title: const Text(
                      'Suggested Meal Plan & Timing',
                      style: TextStyle(color: GymColors.neonCyan, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    children: activeDiet.mealSuggestions.map((m) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: GymColors.neonGreen)),
                            Expanded(
                              child: Text(m, style: const TextStyle(color: GymColors.textSecondary, fontSize: 11.5)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section Science Context Card
          const SectionContextCard(
            item: SectionScienceContext.proteinContext,
            initialExpanded: false,
          ),
          const SizedBox(height: 12),

          // Daily Target Progress Rings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GymColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GymColors.surfaceBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularProgressGauge(
                      current: currentProtein,
                      target: targetProtein,
                      label: 'Protein',
                      unit: 'g',
                      activeColor: GymColors.neonGreen,
                      size: 115,
                      strokeWidth: 9,
                    ),
                    CircularProgressGauge(
                      current: currentCal,
                      target: targetCal,
                      label: 'Calories',
                      unit: 'kcal',
                      activeColor: GymColors.neonAmber,
                      size: 115,
                      strokeWidth: 9,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: GymColors.surfaceBorder),
                const SizedBox(height: 10),

                // Linear Macro Split Bars
                _buildMacroBar('Protein Target', currentProtein, targetProtein, GymColors.neonGreen, 'g'),
                const SizedBox(height: 8),
                _buildMacroBar('Carbohydrates', currentCarb, targetCarb, GymColors.neonCyan, 'g'),
                const SizedBox(height: 8),
                _buildMacroBar('Dietary Fats', currentFat, targetFat, GymColors.neonPurple, 'g'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Water Hydration Tracker Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GymColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GymColors.surfaceBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: GymColors.neonCyan.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.water_drop, color: GymColors.neonCyan, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HYDRATION LEVEL',
                        style: TextStyle(color: GymColors.neonCyan, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${(nutrition.waterMl / 1000).toStringAsFixed(2)} L / 3.50 L',
                        style: const TextStyle(color: GymColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove, color: GymColors.textMuted, size: 18),
                  onPressed: () => gym.updateWater(-250),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GymColors.neonCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => gym.updateWater(250),
                  child: const Text('+250ml', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GymColors.neonCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  onPressed: () => gym.updateWater(500),
                  child: const Text('+500ml', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Add Presets
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUICK HIGH-PROTEIN PRESETS',
                style: TextStyle(
                  color: GymColors.neonGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Tap to log',
                style: TextStyle(color: GymColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kQuickNutritionPresets.map((preset) {
              return InkWell(
                onTap: () async {
                  await gym.addQuickPreset(preset);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✓ Logged ${preset.name} (+${preset.proteinG.toInt()}g Protein)'),
                        backgroundColor: GymColors.neonGreen,
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: GymColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GymColors.surfaceBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(preset.icon, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        preset.name.split('(').first.trim(),
                        style: const TextStyle(color: GymColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: GymColors.neonGreen.withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${preset.proteinG.toInt()}g P',
                          style: const TextStyle(color: GymColors.neonGreen, fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Today's Meals List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TODAY'S MEAL LOG (${nutrition.meals.length})",
                style: const TextStyle(
                  color: GymColors.neonAmber,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16, color: GymColors.neonCyan),
                label: const Text('Add Item', style: TextStyle(color: GymColors.neonCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () => _showAddCustomMealDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (nutrition.meals.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: GymColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'No meals logged yet today. Tap a quick preset above or add a custom meal.',
                style: TextStyle(color: GymColors.textMuted, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...nutrition.meals.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GymColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GymColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Text(item.category.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(color: GymColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${DateFormat('hh:mm a').format(item.timestamp)} • ${item.category.label}',
                            style: const TextStyle(color: GymColors.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${item.proteinG.toStringAsFixed(0)}g Protein',
                          style: const TextStyle(color: GymColors.neonGreen, fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${item.calories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(color: GymColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: GymColors.neonRed, size: 18),
                      onPressed: () => gym.removeFoodItem(item.id),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 24),
        ],
      ),
    ),
  ),
);
}

  static Widget _buildMacroChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: GymColors.cardBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: GymColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: GymColors.textMuted, fontSize: 9)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(String label, double current, double target, Color color, String unit) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: GymColors.textSecondary, fontSize: 11.5, fontWeight: FontWeight.w600)),
            Text(
              '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit (${(progress * 100).toInt()}%)',
              style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: GymColors.surfaceBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
