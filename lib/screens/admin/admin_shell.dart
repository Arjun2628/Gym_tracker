import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_provider.dart';
import '../../theme/gym_theme.dart';
import 'admin_overview_view.dart';
import 'admin_members_view.dart';
import 'admin_fees_view.dart';
import 'admin_member_progress_view.dart';
import 'add_member_dialog.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _selectedTabIndex = 0;

  void _navigateToTab(int index) {
    setState(() => _selectedTabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();

    final views = [
      AdminOverviewView(onNavigateTab: _navigateToTab),
      AdminMembersView(onNavigateTab: _navigateToTab),
      const AdminFeesView(),
      const AdminMemberProgressView(),
    ];

    return Scaffold(
      backgroundColor: GymColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktopWeb = constraints.maxWidth >= 850;

          if (isDesktopWeb) {
            return Row(
              children: [
                // Desktop Sidebar Navigation
                _buildSidebar(context, gym),
                // Main Content Viewport
                Expanded(
                  child: Column(
                    children: [
                      _buildTopHeader(context, gym),
                      Expanded(child: views[_selectedTabIndex]),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Mobile / Narrow Admin Layout
            return Column(
              children: [
                _buildTopHeader(context, gym),
                Expanded(child: views[_selectedTabIndex]),
                _buildBottomNav(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, GymProvider gym) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: GymColors.surface,
        border: Border(bottom: BorderSide(color: GymColors.cardBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GymColors.neonGreen.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: GymColors.neonGreen.withAlpha((0.3 * 255).round())),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: GymColors.neonGreen, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'ADMIN PORTAL (WEB)',
                      style: TextStyle(
                        color: GymColors.neonGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: GymColors.cardBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done, color: GymColors.neonCyan, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Hive Local & Firestore Sync',
                      style: TextStyle(color: GymColors.neonCyan, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Right Controls: Quick Add Member + Switch to Member App
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymColors.cardBg,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: GymColors.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.person_add, size: 16, color: GymColors.neonGreen),
                label: const Text('NEW MEMBER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddMemberDialog(),
                  );
                },
              ),
              const SizedBox(width: 12),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymColors.neonCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.phone_android, size: 16),
                label: const Text('SWITCH TO USER APP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                onPressed: () {
                  gym.setRole(AppRole.user);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, GymProvider gym) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        color: GymColors.surface,
        border: Border(right: BorderSide(color: GymColors.cardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gym Brand Logo
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GymColors.neonGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.fitness_center, color: Colors.black, size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'APEXGYM',
                      style: TextStyle(
                        color: GymColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'Management Hub',
                      style: TextStyle(color: GymColors.neonGreen, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: GymColors.cardBorder, height: 1),
          const SizedBox(height: 16),

          // Sidebar Navigation Items
          _buildSidebarItem(
            index: 0,
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard,
            label: 'Command Center',
          ),
          _buildSidebarItem(
            index: 1,
            icon: Icons.people_outline,
            selectedIcon: Icons.people,
            label: 'Member Directory',
            badge: '${gym.members.length}',
          ),
          _buildSidebarItem(
            index: 2,
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet,
            label: 'Fees & Monthly Dues',
            badge: gym.totalDefaultersCount > 0 ? '${gym.totalDefaultersCount} pending' : null,
            badgeColor: GymColors.neonAmber,
          ),
          _buildSidebarItem(
            index: 3,
            icon: Icons.trending_up_outlined,
            selectedIcon: Icons.trending_up,
            label: 'Member Progress',
          ),

          const Spacer(),

          // System Mode Info in footer
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: GymColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GymColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACTIVE ADMIN SESSION',
                  style: TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Web Manager v2.4',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '${gym.members.length} members loaded from Hive storage.',
                  style: const TextStyle(color: GymColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    String? badge,
    Color? badgeColor,
  }) {
    final isSelected = _selectedTabIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => _navigateToTab(index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? GymColors.neonGreen.withAlpha((0.15 * 255).round()) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? GymColors.neonGreen.withAlpha((0.4 * 255).round()) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected ? GymColors.neonGreen : GymColors.textMuted,
                size: 20,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : GymColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? GymColors.neonGreen).withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor ?? GymColors.neonGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedTabIndex,
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
          icon: Icon(Icons.people_outline, color: GymColors.textMuted),
          selectedIcon: Icon(Icons.people, color: GymColors.neonGreen),
          label: 'Members',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet_outlined, color: GymColors.textMuted),
          selectedIcon: Icon(Icons.account_balance_wallet, color: GymColors.neonAmber),
          label: 'Fees',
        ),
        NavigationDestination(
          icon: Icon(Icons.trending_up_outlined, color: GymColors.textMuted),
          selectedIcon: Icon(Icons.trending_up, color: GymColors.neonCyan),
          label: 'Progress',
        ),
      ],
    );
  }
}
