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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktopWeb = constraints.maxWidth >= 960;

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(isDesktopWeb ? 68 : 104),
            child: Container(
              color: GymColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1280),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Top Identity Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: GymColors.neonGreen.withAlpha((0.2 * 255).round()),
                                  child: Text(
                                    activeMember != null && activeMember.name.isNotEmpty
                                        ? activeMember.name.substring(0, 1).toUpperCase()
                                        : 'A',
                                    style: const TextStyle(
                                      color: GymColors.neonGreen,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          activeMember?.name ?? 'Gym Athlete',
                                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: GymColors.neonGreen.withAlpha((0.15 * 255).round()),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'ATHLETE PORTAL',
                                            style: TextStyle(color: GymColors.neonGreen, fontSize: 9, fontWeight: FontWeight.w900),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${activeMember?.planType ?? 'Member'} • Monthly Fee: \$${activeMember?.monthlyFee.toStringAsFixed(0) ?? '50'}/mo',
                                      style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Membership Status Badge & Quick Navigation (on Desktop)
                            Row(
                              children: [
                                if (isDesktopWeb) ...[
                                  TextButton.icon(
                                    icon: const Icon(Icons.fitness_center, size: 16, color: GymColors.neonGreen),
                                    label: const Text('Workouts', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    onPressed: () => _navigateToScreen(WorkoutsScreen(onOpenActiveWorkout: _openActiveWorkout)),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.restaurant, size: 16, color: GymColors.neonCyan),
                                    label: const Text('Nutrition', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    onPressed: () => _navigateToScreen(const NutritionScreen()),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.trending_up, size: 16, color: GymColors.neonAmber),
                                    label: const Text('Growth', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    onPressed: () => _navigateToScreen(const GrowthRateScreen()),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.receipt_long, size: 16, color: GymColors.neonPurple),
                                    label: const Text('Fees', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    onPressed: () => _navigateToScreen(const UserFeesScreen()),
                                  ),
                                  const SizedBox(width: 12),
                                ],

                                // Status Badge
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
                          ],
                        ),

                        // Mobile 2-Screen Switcher (Only on Mobile screens)
                        if (!isDesktopWeb) ...[
                          const SizedBox(height: 8),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: isDesktopWeb
              ? _buildDesktopWebLayout(context, gym)
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _activePageIndex = index);
                      },
                      children: [
                        _buildHomeSectionsView(context, gym),
                        _buildOverviewAnalyticsView(context, gym),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: gym.isWorkoutActive
              ? InkWell(
                  onTap: _openActiveWorkout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: GymColors.neonGreen.withAlpha((0.18 * 255).round()),
                      border: const Border(
                        top: BorderSide(color: GymColors.neonGreen, width: 2),
                      ),
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1280),
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
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ACTIVE WORKOUT: ${gym.activeSessionDayName}',
                                    style: const TextStyle(color: GymColors.neonGreen, fontSize: 13, fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    '${gym.activeWorkoutTotalSetsCompleted} sets completed • Volume: ${gym.activeWorkoutTotalVolume.toStringAsFixed(0)} kg',
                                    style: const TextStyle(color: GymColors.textSecondary, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GymColors.neonGreen,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                minimumSize: Size.zero,
                              ),
                              onPressed: _openActiveWorkout,
                              child: const Text('RESUME WORKOUT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  /// Responsive Desktop/Laptop Web Dual-Column Layout
  Widget _buildDesktopWebLayout(BuildContext context, GymProvider gym) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left / Main Column: Workout Hero + Feature Grid
              Expanded(
                flex: 6,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHeroWorkoutCard(gym),
                    const SizedBox(height: 20),
                    const Text(
                      'FITNESS MODULES & WORKSPACES',
                      style: TextStyle(color: GymColors.neonGreen, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                    const SizedBox(height: 12),
                    _buildDesktopSectionGrid(gym),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              // Right / Sidebar Column: Daily Intake & Metabolic Blueprint
              Expanded(
                flex: 4,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildHydrationWidget(gym),
                    const SizedBox(height: 16),
                    _buildMacroAnalyticsWidget(gym),
                    const SizedBox(height: 16),
                    _buildMetabolicBlueprintWidget(gym),
                    const SizedBox(height: 16),
                    _buildWorkoutHistoryWidget(gym),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Screen 1: Mobile Home Sections
  Widget _buildHomeSectionsView(BuildContext context, GymProvider gym) {
    final activeSplit = gym.activeSplit;
    final activeDiet = gym.activeDiet;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroWorkoutCard(gym),
        const SizedBox(height: 16),
        _buildHydrationWidget(gym),
        const SizedBox(height: 16),

        const Text(
          'EXPLORE SECTIONS',
          style: TextStyle(color: GymColors.neonGreen, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const SizedBox(height: 10),

        _buildSectionCard(
          title: 'Workouts & Training Splits',
          subtitle: '${activeSplit.name} (${activeSplit.daysPerWeek} days/wk)',
          tag: 'ACTIVE SPLIT',
          icon: Icons.fitness_center,
          accentColor: GymColors.neonGreen,
          onTap: () => _navigateToScreen(WorkoutsScreen(onOpenActiveWorkout: _openActiveWorkout)),
        ),
        const SizedBox(height: 10),

        _buildSectionCard(
          title: 'Diet & Nutrition Engine',
          subtitle: '${activeDiet.title} • ${activeDiet.targetCalories} kcal (${activeDiet.proteinGrams}g Protein)',
          tag: 'DIET PROTOCOL',
          icon: Icons.restaurant,
          accentColor: GymColors.neonCyan,
          onTap: () => _navigateToScreen(const NutritionScreen()),
        ),
        const SizedBox(height: 10),

        _buildSectionCard(
          title: 'Growth Rate & Bodyweight',
          subtitle: 'Track physical adaptation, milestones & weekly growth velocity',
          tag: 'PROGRESSION',
          icon: Icons.trending_up,
          accentColor: GymColors.neonAmber,
          onTap: () => _navigateToScreen(const GrowthRateScreen()),
        ),
        const SizedBox(height: 10),

        _buildSectionCard(
          title: 'Biomarkers & Body Composition',
          subtitle: 'BMI, BMR, TDEE calorie formulas & circumferences',
          tag: 'BIOMARKERS',
          icon: Icons.tune,
          accentColor: GymColors.neonPurple,
          onTap: () => _navigateToScreen(const ProfileBiomarkersScreen()),
        ),
        const SizedBox(height: 10),

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

  /// Screen 2: Mobile Overview & Analytics
  Widget _buildOverviewAnalyticsView(BuildContext context, GymProvider gym) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionContextCard(
          item: SectionScienceContext.biomarkersContext,
          initialExpanded: false,
        ),
        _buildMacroAnalyticsWidget(gym),
        const SizedBox(height: 14),
        _buildMetabolicBlueprintWidget(gym),
        const SizedBox(height: 14),
        _buildWorkoutHistoryWidget(gym),
      ],
    );
  }

  /// Desktop 2-Column Section Grid
  Widget _buildDesktopSectionGrid(GymProvider gym) {
    final activeSplit = gym.activeSplit;
    final activeDiet = gym.activeDiet;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSectionCard(
                title: 'Workouts & Splits',
                subtitle: '${activeSplit.name} (${activeSplit.daysPerWeek}d/wk)',
                tag: 'WORKOUTS',
                icon: Icons.fitness_center,
                accentColor: GymColors.neonGreen,
                onTap: () => _navigateToScreen(WorkoutsScreen(onOpenActiveWorkout: _openActiveWorkout)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildSectionCard(
                title: 'Diet & Nutrition',
                subtitle: '${activeDiet.title} (${activeDiet.targetCalories} kcal)',
                tag: 'NUTRITION',
                icon: Icons.restaurant,
                accentColor: GymColors.neonCyan,
                onTap: () => _navigateToScreen(const NutritionScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildSectionCard(
                title: 'Growth & Bodyweight',
                subtitle: 'Progression analytics & milestones',
                tag: 'GROWTH',
                icon: Icons.trending_up,
                accentColor: GymColors.neonAmber,
                onTap: () => _navigateToScreen(const GrowthRateScreen()),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildSectionCard(
                title: 'Biomarkers & Stats',
                subtitle: 'BMI, BMR, TDEE metrics',
                tag: 'BIOMARKERS',
                icon: Icons.tune,
                accentColor: GymColors.neonPurple,
                onTap: () => _navigateToScreen(const ProfileBiomarkersScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: 'My Membership & Receipts',
          subtitle: 'Monthly dues, billing history & payment status ledger',
          tag: 'MEMBERSHIP',
          icon: Icons.receipt_long,
          accentColor: GymColors.neonCyan,
          onTap: () => _navigateToScreen(const UserFeesScreen()),
        ),
      ],
    );
  }

  Widget _buildHeroWorkoutCard(GymProvider gym) {
    final activeSplit = gym.activeSplit;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.asset(
            'assets/images/workout_hero.jpg',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 160,
              color: GymColors.surfaceLight,
              child: const Center(child: Icon(Icons.fitness_center, size: 40, color: GymColors.neonGreen)),
            ),
          ),
          Container(
            height: 160,
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
            bottom: 14,
            left: 16,
            right: 16,
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
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GymColors.neonGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('START WORKOUT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
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
    );
  }

  Widget _buildHydrationWidget(GymProvider gym) {
    final nutrition = gym.todayNutrition;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GymColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GymColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop, color: GymColors.neonCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                '${nutrition.waterMl} ml / 3500 ml',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymColors.surfaceLight,
                  foregroundColor: GymColors.neonCyan,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                ),
                onPressed: () => gym.updateWater(250),
                child: const Text('+250ml', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymColors.surfaceLight,
                  foregroundColor: GymColors.neonCyan,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                ),
                onPressed: () => gym.updateWater(500),
                child: const Text('+500ml', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroAnalyticsWidget(GymProvider gym) {
    final activeDiet = gym.activeDiet;
    final nutrition = gym.todayNutrition;

    final proteinTarget = activeDiet.proteinGrams.toDouble();
    final proteinCurrent = nutrition.totalProteinG;
    final calorieTarget = activeDiet.targetCalories.toDouble();
    final calorieCurrent = nutrition.totalCalories;

    return Container(
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
                    style: TextStyle(color: GymColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w900),
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
    );
  }

  Widget _buildMetabolicBlueprintWidget(GymProvider gym) {
    final profile = gym.profile;

    return Container(
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
    );
  }

  Widget _buildWorkoutHistoryWidget(GymProvider gym) {
    return Container(
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
