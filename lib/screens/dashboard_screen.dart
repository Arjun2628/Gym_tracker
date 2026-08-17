import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gym_provider.dart';
import '../models/science_context.dart';
import '../theme/gym_theme.dart';
import '../widgets/context_card.dart';
import '../widgets/circular_progress_gauge.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  final VoidCallback onOpenActiveWorkout;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
    required this.onOpenActiveWorkout,
  });

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final profile = gym.profile;
    final nutrition = gym.todayNutrition;
    final growth = gym.growthAnalysis;

    final proteinTarget = profile.dailyProteinTargetGrams;
    final proteinCurrent = nutrition.totalProteinG;
    final calorieTarget = profile.targetCalories;
    final calorieCurrent = nutrition.totalCalories;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GymColors.background,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: GymColors.neonGreen.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.fitness_center, color: GymColors.neonGreen, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'APEX GYM TRACKER',
                  style: TextStyle(
                    color: GymColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '${profile.name} • ${profile.goal.label}',
                  style: const TextStyle(
                    color: GymColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, color: GymColors.neonCyan),
            tooltip: 'Biomarkers & Profile',
            onPressed: () => onNavigateTab(1),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Science & Context Guide Banner
          const SectionContextCard(
            item: SectionScienceContext.biomarkersContext,
            initialExpanded: false,
          ),

          // Daily Nutrition & Protein Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GymColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GymColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'DAILY FUEL & PROTEIN',
                      style: TextStyle(
                        color: GymColors.neonGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    InkWell(
                      onTap: () => onNavigateTab(2),
                      child: const Row(
                        children: [
                          Text('Log Meals ', style: TextStyle(color: GymColors.neonCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_forward_ios, size: 10, color: GymColors.neonCyan),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircularProgressGauge(
                      current: proteinCurrent,
                      target: proteinTarget,
                      label: 'Protein',
                      unit: 'g',
                      activeColor: GymColors.neonGreen,
                      size: 110,
                      strokeWidth: 9,
                    ),
                    CircularProgressGauge(
                      current: calorieCurrent,
                      target: calorieTarget,
                      label: 'Calories',
                      unit: 'kcal',
                      activeColor: GymColors.neonAmber,
                      size: 110,
                      strokeWidth: 9,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMiniStat('Water', '${(nutrition.waterMl / 1000).toStringAsFixed(1)}L / 3.5L', GymColors.neonCyan, Icons.water_drop),
                        const SizedBox(height: 8),
                        _buildMiniStat('Carbs', '${nutrition.totalCarbsG.toStringAsFixed(0)}g', GymColors.textPrimary, Icons.grain),
                        const SizedBox(height: 8),
                        _buildMiniStat('Fats', '${nutrition.totalFatG.toStringAsFixed(0)}g', GymColors.textPrimary, Icons.egg),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Growth Velocity Badge Card
          InkWell(
            onTap: () => onNavigateTab(3),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GymColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GymColors.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.trending_up, color: GymColors.neonCyan, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'GROWTH RATE VELOCITY',
                            style: TextStyle(
                              color: GymColors.neonCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: GymColors.neonGreen.withAlpha((0.15 * 255).round()),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: GymColors.neonGreen.withAlpha((0.3 * 255).round())),
                        ),
                        child: Text(
                          '${growth.weeklyVelocityKg >= 0 ? '+' : ''}${growth.weeklyVelocityKg.toStringAsFixed(2)} kg/wk',
                          style: const TextStyle(
                            color: GymColors.neonGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              growth.statusLabel,
                              style: const TextStyle(
                                color: GymColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              growth.coachingRecommendation,
                              style: const TextStyle(
                                color: GymColors.textSecondary,
                                fontSize: 11.5,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: GymColors.textMuted),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Workout Split & Next Session Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GymColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GymColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'WORKOUT SEPARATION & SPLIT',
                      style: TextStyle(
                        color: GymColors.neonRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    InkWell(
                      onTap: () => onNavigateTab(4),
                      child: const Row(
                        children: [
                          Text('View Splits ', style: TextStyle(color: GymColors.neonCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                          Icon(Icons.arrow_forward_ios, size: 10, color: GymColors.neonCyan),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  gym.activeSplit.name,
                  style: const TextStyle(
                    color: GymColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gym.activeSplit.description,
                  style: const TextStyle(color: GymColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 14),
                if (gym.isWorkoutActive)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GymColors.neonAmber,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text('RESUME ACTIVE SESSION (${gym.activeSessionDayName})'),
                    onPressed: onOpenActiveWorkout,
                  )
                else if (gym.activeSplit.days.isNotEmpty)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GymColors.neonGreen,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    icon: const Icon(Icons.fitness_center, size: 18),
                    label: Text('START TODAY: ${gym.activeSplit.days.first.name}'),
                    onPressed: () {
                      gym.startWorkoutSession(
                        splitName: gym.activeSplit.name,
                        day: gym.activeSplit.days.first,
                      );
                      onOpenActiveWorkout();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick Action Grid
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  icon: Icons.monitor_weight,
                  title: 'Log Weight',
                  subtitle: '${profile.weightKg.toStringAsFixed(1)} kg',
                  color: GymColors.neonCyan,
                  onTap: () => onNavigateTab(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  icon: Icons.restaurant,
                  title: 'Quick Protein',
                  subtitle: '+25g Whey',
                  color: GymColors.neonGreen,
                  onTap: () => onNavigateTab(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: GymColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GymColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: GymColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
