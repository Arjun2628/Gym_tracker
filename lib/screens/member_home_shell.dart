import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gym_provider.dart';
import '../theme/gym_theme.dart';
import '../models/science_context.dart';
import '../widgets/context_card.dart';
import '../widgets/circular_progress_gauge.dart';
import 'profile_biomarkers_screen.dart';
import 'nutrition_screen.dart';
import 'growth_rate_screen.dart';
import 'workouts_screen.dart';
import 'active_workout_screen.dart';
import 'user_fees_screen.dart';

class MemberHomeShell extends StatefulWidget {
  const MemberHomeShell({super.key});

  @override
  State<MemberHomeShell> createState() => _MemberHomeShellState();
}

class _MemberHomeShellState extends State<MemberHomeShell> {
  final PageController _pageController = PageController(initialPage: 0);
  int _activePageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openActiveWorkout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final activeMember = gym.activeMember;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(104),
        child: Container(
          color: GymColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Identity Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: GymColors.neonGreen.withAlpha((0.2 * 255).round()),
                          child: Text(
                            activeMember != null && activeMember.name.isNotEmpty
                                ? activeMember.name.substring(0, 1).toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              color: GymColors.neonGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              activeMember?.name ?? 'Gym Athlete',
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${activeMember?.planType ?? 'Member'} • Fee: \$${activeMember?.monthlyFee.toStringAsFixed(0) ?? '50'}/mo',
                              style: const TextStyle(color: GymColors.textMuted, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Membership Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (activeMember?.status == 'Active'
                                ? GymColors.neonGreen
                                : (activeMember?.status == 'Overdue'
                                    ? GymColors.neonRed
                                    : GymColors.neonAmber))
                            .withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (activeMember?.status == 'Active'
                                  ? GymColors.neonGreen
                                  : (activeMember?.status == 'Overdue'
                                      ? GymColors.neonRed
                                      : GymColors.neonAmber))
                              .withAlpha((0.4 * 255).round()),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: activeMember?.status == 'Active'
                                  ? GymColors.neonGreen
                                  : (activeMember?.status == 'Overdue'
                                      ? GymColors.neonRed
                                      : GymColors.neonAmber),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            (activeMember?.status ?? 'ACTIVE').toUpperCase(),
                            style: TextStyle(
                              color: activeMember?.status == 'Active'
                                  ? GymColors.neonGreen
                                  : (activeMember?.status == 'Overdue'
                                      ? GymColors.neonRed
                                      : GymColors.neonAmber),
                              fontWeight: FontWeight.w900,
                              fontSize: 10,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Sliding Two-Screen Tab Selector
                Container(
                  height: 36,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: GymColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GymColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _activePageIndex == 0
                                  ? GymColors.neonGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  size: 14,
                                  color: _activePageIndex == 0 ? Colors.black : GymColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'HOME SECTIONS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: _activePageIndex == 0 ? Colors.black : GymColors.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _activePageIndex == 1
                                  ? GymColors.neonCyan
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 14,
                                  color: _activePageIndex == 1 ? Colors.black : GymColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'OVERVIEW & STATS ➔',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: _activePageIndex == 1 ? Colors.black : GymColors.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _activePageIndex = index);
        },
        children: [
          // SCREEN 1: Home Sections & Directing Navigation Cards
          _buildHomeSectionsView(context, gym),

          // SCREEN 2: Right-Side Sliding In-Depth Overview & Analytics Screen
          _buildOverviewAnalyticsView(context, gym),
        ],
      ),
      bottomNavigationBar: gym.isWorkoutActive
          ? InkWell(
              onTap: _openActiveWorkout,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: GymColors.neonGreen.withAlpha((0.18 * 255).round()),
                  border: const Border(
                    top: BorderSide(color: GymColors.neonGreen, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: GymColors.neonGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ACTIVE WORKOUT: ${gym.activeSessionDayName}',
                            style: const TextStyle(color: GymColors.neonGreen, fontSize: 12, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${gym.activeWorkoutTotalSetsCompleted} sets completed • Vol: ${gym.activeWorkoutTotalVolume.toStringAsFixed(0)}kg',
                            style: const TextStyle(color: GymColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GymColors.neonGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      onPressed: _openActiveWorkout,
                      child: const Text('RESUME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  /// Screen 1: Home Navigation Hub directing to all core sections
  Widget _buildHomeSectionsView(BuildContext context, GymProvider gym) {
    final activeSplit = gym.activeSplit;
    final activeDiet = gym.activeDiet;
    final nutrition = gym.todayNutrition;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Workout Hero Banner
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Image.asset(
                'assets/images/workout_hero.jpg',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: GymColors.surfaceLight,
                  child: const Center(child: Icon(Icons.fitness_center, size: 40, color: GymColors.neonGreen)),
                ),
              ),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha((0.9 * 255).round()),
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
                        Text(
                          activeSplit.name.toUpperCase(),
                          style: const TextStyle(color: GymColors.neonGreen, fontSize: 11, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Ready for Today\'s Session?',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GymColors.neonGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('START', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                      onPressed: () {
                        if (activeSplit.days.isNotEmpty) {
                          gym.startWorkoutSession(
                            splitName: activeSplit.name,
                            day: activeSplit.days.first,
                          );
                          _openActiveWorkout();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick Daily Hydration & Streak Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GymColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GymColors.surfaceBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.water_drop, color: GymColors.neonCyan, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${nutrition.waterMl} ml / 3500 ml',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GymColors.surfaceLight,
                      foregroundColor: GymColors.neonCyan,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () => gym.updateWater(250),
                    child: const Text('+250ml', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GymColors.surfaceLight,
                      foregroundColor: GymColors.neonCyan,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () => gym.updateWater(500),
                    child: const Text('+500ml', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'EXPLORE SECTIONS',
          style: TextStyle(color: GymColors.neonGreen, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const SizedBox(height: 10),

        // SECTION 1: WORKOUTS & SPLITS
        _buildSectionCard(
          title: 'Workouts & Training Splits',
          subtitle: '${activeSplit.name} (${activeSplit.daysPerWeek} days/wk)',
          tag: 'ACTIVE SPLIT',
          icon: Icons.fitness_center,
          accentColor: GymColors.neonGreen,
          onTap: () => _navigateToScreen(WorkoutsScreen(onOpenActiveWorkout: _openActiveWorkout)),
        ),
        const SizedBox(height: 10),

        // SECTION 2: DIET & NUTRITION
        _buildSectionCard(
          title: 'Diet & Nutrition Engine',
          subtitle: '${activeDiet.title} • ${activeDiet.targetCalories} kcal (${activeDiet.proteinGrams}g Protein)',
          tag: 'DIET PROTOCOL',
          icon: Icons.restaurant,
          accentColor: GymColors.neonCyan,
          onTap: () => _navigateToScreen(const NutritionScreen()),
        ),
        const SizedBox(height: 10),

        // SECTION 3: GROWTH RATE & PROGRESSION
        _buildSectionCard(
          title: 'Growth Rate & Bodyweight',
          subtitle: 'Track physical adaptation, milestones & weekly growth velocity',
          tag: 'PROGRESSION',
          icon: Icons.trending_up,
          accentColor: GymColors.neonAmber,
          onTap: () => _navigateToScreen(const GrowthRateScreen()),
        ),
        const SizedBox(height: 10),

        // SECTION 4: BIOMARKERS & PROFILE
        _buildSectionCard(
          title: 'Biomarkers & Body Composition',
          subtitle: 'BMI, BMR, TDEE calorie formulas & circumferences',
          tag: 'BIOMARKERS',
          icon: Icons.tune,
          accentColor: GymColors.neonPurple,
          onTap: () => _navigateToScreen(const ProfileBiomarkersScreen()),
        ),
        const SizedBox(height: 10),

        // SECTION 5: MY MEMBERSHIP & FEES
        _buildSectionCard(
          title: 'My Membership & Fees',
          subtitle: 'Billing cycle, monthly dues, receipts & payment history',
          tag: 'FEES LEDGER',
          icon: Icons.receipt_long,
          accentColor: GymColors.neonCyan,
          onTap: () => _navigateToScreen(const UserFeesScreen()),
        ),
      ],
    );
  }

  /// Screen 2: Right-Side Sliding In-Depth Overview Screen
  Widget _buildOverviewAnalyticsView(BuildContext context, GymProvider gym) {
    final profile = gym.profile;
    final nutrition = gym.todayNutrition;
    final activeDiet = gym.activeDiet;

    final proteinTarget = activeDiet.proteinGrams.toDouble();
    final proteinCurrent = nutrition.totalProteinG;
    final calorieTarget = activeDiet.targetCalories.toDouble();
    final calorieCurrent = nutrition.totalCalories;

    return ListView(
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
                  const Row(
                    children: [
                      Icon(Icons.local_fire_department, color: GymColors.neonAmber, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'TODAY\'S MACRO CONSUMPTION',
                        style: TextStyle(
                          color: GymColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${(calorieTarget - calorieCurrent).clamp(0, 9999).toInt()} kcal left',
                    style: const TextStyle(color: GymColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircularProgressGauge(
                    current: calorieCurrent,
                    target: calorieTarget,
                    unit: 'kcal',
                    label: 'CALORIES',
                    activeColor: GymColors.neonAmber,
                  ),
                  CircularProgressGauge(
                    current: proteinCurrent,
                    target: proteinTarget,
                    unit: 'g',
                    label: 'PROTEIN',
                    activeColor: GymColors.neonGreen,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Linear Bars for Carbs & Fats
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Carbs', style: TextStyle(color: GymColors.textSecondary, fontSize: 11)),
                            Text('${nutrition.totalCarbsG.toInt()}g / ${activeDiet.carbsGrams}g', style: const TextStyle(color: GymColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (activeDiet.carbsGrams > 0 ? nutrition.totalCarbsG / activeDiet.carbsGrams : 0.0).clamp(0.0, 1.0),
                          backgroundColor: GymColors.surfaceLight,
                          valueColor: const AlwaysStoppedAnimation(GymColors.neonCyan),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Fats', style: TextStyle(color: GymColors.textSecondary, fontSize: 11)),
                            Text('${nutrition.totalFatG.toInt()}g / ${activeDiet.fatGrams}g', style: const TextStyle(color: GymColors.neonPurple, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (activeDiet.fatGrams > 0 ? nutrition.totalFatG / activeDiet.fatGrams : 0.0).clamp(0.0, 1.0),
                          backgroundColor: GymColors.surfaceLight,
                          valueColor: const AlwaysStoppedAnimation(GymColors.neonPurple),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Body Composition & Metabolic Blueprint
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
              const Row(
                children: [
                  Icon(Icons.bolt, color: GymColors.neonGreen, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'METABOLIC BLUEPRINT',
                    style: TextStyle(color: GymColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildMetricTile('Weight', '${profile.weightKg} kg', GymColors.textPrimary),
                  _buildMetricTile('BMI', profile.bmi.toStringAsFixed(1), GymColors.neonCyan),
                  _buildMetricTile('BMR', '${profile.bmr.toInt()} kcal', GymColors.neonAmber),
                  _buildMetricTile('TDEE', '${profile.tdee.toInt()} kcal', GymColors.neonGreen),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Completed Workout History Count Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: GymColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GymColors.surfaceBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GymColors.neonRed.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.history, color: GymColors.neonRed, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Sessions Logged', style: TextStyle(color: GymColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${gym.completedSessions.length} completed workouts', style: const TextStyle(color: GymColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymColors.surfaceLight,
                  foregroundColor: GymColors.neonGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                ),
                onPressed: () => _navigateToScreen(WorkoutsScreen(onOpenActiveWorkout: _openActiveWorkout)),
                child: const Text('VIEW ALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required String tag,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GymColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: GymColors.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withAlpha((0.3 * 255).round())),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: GymColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: GymColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(color: GymColors.textMuted, fontSize: 10)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
