import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/gym_provider.dart';
import '../../models/member_model.dart';
import '../../theme/gym_theme.dart';
import 'add_member_dialog.dart';

class AdminOverviewView extends StatelessWidget {
  final Function(int tabIndex) onNavigateTab;

  const AdminOverviewView({super.key, required this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final summaries = gym.getMonthlyFeeSummaries();
    final currentSummary = summaries.isNotEmpty ? summaries.first : null;

    final totalMembers = gym.members.length;
    final activeMembers = gym.members.where((m) => m.status == 'Active').length;
    final pendingCount = gym.totalDefaultersCount;
    final totalCollected = currentSummary?.totalCollected ?? 0.0;
    final totalPending = currentSummary?.totalPending ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GYM OPERATIONS COMMAND CENTER',
                    style: TextStyle(
                      color: GymColors.neonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Admin Dashboard • ${DateFormat('MMMM yyyy').format(DateTime.now())}',
                    style: const TextStyle(
                      color: GymColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymColors.neonGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text(
                  'ADD NEW MEMBER',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const AddMemberDialog(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPI Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 800;
              final crossAxisCount = isNarrow ? 2 : 4;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isNarrow ? 1.6 : 2.1,
                children: [
                  _buildKpiCard(
                    title: 'TOTAL MEMBERS',
                    value: '$totalMembers',
                    subtitle: '$activeMembers actively training',
                    icon: Icons.people_alt_outlined,
                    color: GymColors.neonGreen,
                    onTap: () => onNavigateTab(1),
                  ),
                  _buildKpiCard(
                    title: 'MONTHLY REVENUE',
                    value: '\$${totalCollected.toStringAsFixed(0)}',
                    subtitle: currentSummary != null ? '${currentSummary.paidCount} payments received' : 'No records',
                    icon: Icons.account_balance_wallet_outlined,
                    color: GymColors.neonCyan,
                    onTap: () => onNavigateTab(2),
                  ),
                  _buildKpiCard(
                    title: 'PENDING DUES',
                    value: '\$${totalPending.toStringAsFixed(0)}',
                    subtitle: '$pendingCount members overdue',
                    icon: Icons.warning_amber_rounded,
                    color: GymColors.neonAmber,
                    onTap: () => onNavigateTab(2),
                  ),
                  _buildKpiCard(
                    title: 'COLLECTION RATE',
                    value: currentSummary != null
                        ? '${currentSummary.collectionPercentage.toStringAsFixed(0)}%'
                        : '0%',
                    subtitle: 'Current billing cycle',
                    icon: Icons.pie_chart_outline,
                    color: GymColors.neonPurple,
                    onTap: () => onNavigateTab(2),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Alert banner if there are overdue payments
          if (pendingCount > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GymColors.neonAmber.withAlpha((0.12 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GymColors.neonAmber.withAlpha((0.4 * 255).round())),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GymColors.neonAmber.withAlpha((0.2 * 255).round()),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.notifications_active, color: GymColors.neonAmber, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$pendingCount Members Have Pending / Overdue Fees',
                          style: const TextStyle(
                            color: GymColors.neonAmber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Review the monthly pending section to inspect dues by month and record cash/UPI/card settlements.',
                          style: TextStyle(color: GymColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: GymColors.neonAmber,
                      backgroundColor: GymColors.surface,
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('VIEW DUES', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => onNavigateTab(2),
                  ),
                ],
              ),
            ),

          // Two-Column Section: Recent Members + Month Fees Breakdown
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildRecentMembersSection(context, gym)),
                    const SizedBox(width: 20),
                    Expanded(flex: 4, child: _buildMonthlySummaryCard(context, gym)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildRecentMembersSection(context, gym),
                    const SizedBox(height: 20),
                    _buildMonthlySummaryCard(context, gym),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GymColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: GymColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GymColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMembersSection(BuildContext context, GymProvider gym) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GymColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GymColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.groups, color: GymColors.neonGreen, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'REGISTERED GYM MEMBERS',
                    style: TextStyle(
                      color: GymColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => onNavigateTab(1),
                child: const Text('VIEW ALL DIRECTORY', style: TextStyle(color: GymColors.neonGreen, fontSize: 12)),
              ),
            ],
          ),
          const Divider(color: GymColors.cardBorder, height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gym.members.take(5).length,
            separatorBuilder: (context, index) => const Divider(color: GymColors.cardBorder, height: 16),
            itemBuilder: (context, idx) {
              final m = gym.members[idx];
              return _buildMemberRow(context, m, gym);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMemberRow(BuildContext context, MemberModel m, GymProvider gym) {
    final statusColor = m.status == 'Active'
        ? GymColors.neonGreen
        : (m.status == 'Overdue' ? GymColors.neonRed : GymColors.neonAmber);

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: GymColors.surface,
          child: Text(
            m.name.isNotEmpty ? m.name.substring(0, 1).toUpperCase() : 'M',
            style: const TextStyle(color: GymColors.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m.name,
                style: const TextStyle(color: GymColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Text(
                '${m.planType} Plan • \$${m.monthlyFee.toStringAsFixed(0)}/mo • Due on ${m.dueDayOfMonth}th',
                style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: statusColor.withAlpha((0.15 * 255).round()),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: statusColor.withAlpha((0.4 * 255).round())),
          ),
          child: Text(
            m.status.toUpperCase(),
            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMonthlySummaryCard(BuildContext context, GymProvider gym) {
    final summaries = gym.getMonthlyFeeSummaries();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GymColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GymColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month, color: GymColors.neonCyan, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'MONTHLY REVENUE MATRIX',
                    style: TextStyle(
                      color: GymColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => onNavigateTab(2),
                child: const Text('ALL MONTHS', style: TextStyle(color: GymColors.neonCyan, fontSize: 12)),
              ),
            ],
          ),
          const Divider(color: GymColors.cardBorder, height: 20),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: summaries.take(3).length,
            separatorBuilder: (context, index) => const Divider(color: GymColors.cardBorder, height: 16),
            itemBuilder: (context, idx) {
              final s = summaries[idx];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.monthLabel,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '\$${s.totalCollected.toStringAsFixed(0)} / \$${s.totalExpected.toStringAsFixed(0)}',
                        style: const TextStyle(color: GymColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: s.totalExpected > 0 ? s.totalCollected / s.totalExpected : 0.0,
                      backgroundColor: GymColors.surface,
                      valueColor: const AlwaysStoppedAnimation<Color>(GymColors.neonGreen),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${s.paidCount} Paid • ${s.pendingCount} Pending',
                        style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
                      ),
                      Text(
                        'Pending: \$${s.totalPending.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: s.totalPending > 0 ? GymColors.neonAmber : GymColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
