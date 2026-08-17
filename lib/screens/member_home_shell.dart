import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gym_provider.dart';
import '../theme/gym_theme.dart';
import 'dashboard_screen.dart';
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
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _openActiveWorkout() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final activeMember = gym.activeMember;

    final screens = [
      DashboardScreen(
        onNavigateTab: _navigateToTab,
        onOpenActiveWorkout: _openActiveWorkout,
      ),
      const ProfileBiomarkersScreen(),
      const NutritionScreen(),
      const GrowthRateScreen(),
      WorkoutsScreen(onOpenActiveWorkout: _openActiveWorkout),
      const UserFeesScreen(),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: GymColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Member Profile Identity
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
                          '${activeMember?.planType ?? 'Member'} • Monthly Fee: \$${activeMember?.monthlyFee.toStringAsFixed(0) ?? '50'}',
                          style: const TextStyle(color: GymColors.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),

                // Personal Membership Status Badge
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
          ),
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Persistent Active Workout Mini-Bar if Running
          if (gym.isWorkoutActive)
            InkWell(
              onTap: _openActiveWorkout,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: GymColors.neonGreen.withAlpha((0.15 * 255).round()),
                  border: const Border(
                    top: BorderSide(color: GymColors.neonGreen, width: 1.5),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                      onPressed: _openActiveWorkout,
                      child: const Text('RESUME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            ),

          // Member Navigation Bar
          NavigationBar(
            selectedIndex: _currentIndex,
            backgroundColor: GymColors.surface,
            indicatorColor: GymColors.neonGreen.withAlpha((0.2 * 255).round()),
            onDestinationSelected: _navigateToTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined, color: GymColors.textMuted),
                selectedIcon: Icon(Icons.dashboard, color: GymColors.neonGreen),
                label: 'Overview',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined, color: GymColors.textMuted),
                selectedIcon: Icon(Icons.tune, color: GymColors.neonCyan),
                label: 'Biomarkers',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_outlined, color: GymColors.textMuted),
                selectedIcon: Icon(Icons.restaurant, color: GymColors.neonGreen),
                label: 'Nutrition',
              ),
              NavigationDestination(
                icon: Icon(Icons.trending_up_outlined, color: GymColors.textMuted),
                selectedIcon: Icon(Icons.trending_up, color: GymColors.neonAmber),
                label: 'Growth',
              ),
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined, color: GymColors.textMuted),
                selectedIcon: Icon(Icons.fitness_center, color: GymColors.neonRed),
                label: 'Splits',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined, color: GymColors.textMuted),
                selectedIcon: Icon(Icons.receipt_long, color: GymColors.neonCyan),
                label: 'My Fees',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
