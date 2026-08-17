import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/gym_provider.dart';
import '../../models/member_model.dart';
import '../../theme/gym_theme.dart';

class AdminMemberProgressView extends StatefulWidget {
  const AdminMemberProgressView({super.key});

  @override
  State<AdminMemberProgressView> createState() => _AdminMemberProgressViewState();
}

class _AdminMemberProgressViewState extends State<AdminMemberProgressView> {
  String? _selectedMemberId;

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();

    if (gym.members.isEmpty) {
      return const Center(
        child: Text('No gym members available.', style: TextStyle(color: GymColors.textMuted)),
      );
    }

    final selectedMember = gym.members.firstWhere(
      (m) => m.id == _selectedMemberId,
      orElse: () => gym.members.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Member Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ATHLETE PERFORMANCE & PROGRESS MONITOR',
                    style: TextStyle(
                      color: GymColors.neonGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Member Progress & Trajectory',
                    style: TextStyle(
                      color: GymColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Dropdown to pick member
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: GymColors.cardBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GymColors.cardBorder),
                ),
                child: DropdownButton<String>(
                  value: selectedMember.id,
                  dropdownColor: GymColors.surface,
                  underline: const SizedBox(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  items: gym.members.map((m) {
                    return DropdownMenuItem(
                      value: m.id,
                      child: Text('${m.name} (${m.planType})'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedMemberId = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Member Hero Card
          _buildMemberHeroCard(context, selectedMember, gym),

          const SizedBox(height: 24),

          // Progress Analytics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: _buildWeightTrendCard(context, selectedMember, gym)),
                    const SizedBox(width: 20),
                    Expanded(flex: 4, child: _buildProtocolsCard(context, selectedMember, gym)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildWeightTrendCard(context, selectedMember, gym),
                    const SizedBox(height: 20),
                    _buildProtocolsCard(context, selectedMember, gym),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // Workout Activity Logs
          _buildWorkoutActivityHistory(context, selectedMember, gym),
        ],
      ),
    );
  }

  Widget _buildMemberHeroCard(BuildContext context, MemberModel m, GymProvider gym) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GymColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GymColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: GymColors.neonGreen.withAlpha((0.2 * 255).round()),
            child: Text(
              m.name.isNotEmpty ? m.name.substring(0, 1) : 'M',
              style: const TextStyle(
                color: GymColors.neonGreen,
                fontWeight: FontWeight.bold,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  m.name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${m.gender}, ${m.age} years old • ${m.planType} Member • Joined ${m.joinDate.year}',
                  style: const TextStyle(color: GymColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          // Metric pills
          _buildHeroPill('CURRENT WEIGHT', '${m.currentWeight.toStringAsFixed(1)} kg', GymColors.neonCyan),
          const SizedBox(width: 12),
          _buildHeroPill('WORKOUTS LOGGED', '${m.totalWorkoutsCompleted}', GymColors.neonGreen),
          const SizedBox(width: 12),
          _buildHeroPill('STREAK', '${m.attendanceStreak} days', GymColors.neonAmber),
        ],
      ),
    );
  }

  Widget _buildHeroPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: GymColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GymColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTrendCard(BuildContext context, MemberModel m, GymProvider gym) {
    final measurements = gym.measurements;

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
          const Row(
            children: [
              Icon(Icons.show_chart, color: GymColors.neonCyan, size: 20),
              SizedBox(width: 10),
              Text(
                'BODYWEIGHT & ADAPTATION TREND',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(color: GymColors.cardBorder, strokeWidth: 1),
                ),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: measurements.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.weightKg);
                    }).toList(),
                    isCurved: true,
                    color: GymColors.neonCyan,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: GymColors.neonCyan.withAlpha((0.15 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolsCard(BuildContext context, MemberModel m, GymProvider gym) {
    final diet = gym.allDietPlans.firstWhere(
      (d) => d.id == m.assignedDietId,
      orElse: () => gym.allDietPlans.first,
    );

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
          const Row(
            children: [
              Icon(Icons.restaurant_menu, color: GymColors.neonGreen, size: 20),
              SizedBox(width: 10),
              Text(
                'ASSIGNED NUTRITION & SPLIT',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GymColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diet.title,
                  style: const TextStyle(color: GymColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  diet.description,
                  style: const TextStyle(color: GymColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Target: ${diet.targetCalories} kcal', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text('P: ${diet.proteinGrams}g • C: ${diet.carbsGrams}g • F: ${diet.fatGrams}g', style: const TextStyle(color: GymColors.neonAmber, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text('TRAINING SCHEDULE:', style: TextStyle(color: GymColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Assigned: ${gym.activeSplit.name} (${gym.activeSplit.days.length} Days / Week)',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutActivityHistory(BuildContext context, MemberModel m, GymProvider gym) {
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
          const Row(
            children: [
              Icon(Icons.fitness_center, color: GymColors.neonAmber, size: 20),
              SizedBox(width: 10),
              Text(
                'RECENT WORKOUT SESSIONS & LOGS',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const Divider(color: GymColors.cardBorder, height: 24),

          if (gym.completedSessions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No recorded workout sessions yet for this member.', style: TextStyle(color: GymColors.textMuted)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gym.completedSessions.length,
              separatorBuilder: (context, index) => const Divider(color: GymColors.cardBorder, height: 16),
              itemBuilder: (context, idx) {
                final s = gym.completedSessions[idx];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${s.splitName} - ${s.dayName}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '${s.exercises.length} Exercises • Duration: ${s.durationMinutes} mins',
                          style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: GymColors.neonGreen.withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Vol: ${s.totalVolumeKg.toStringAsFixed(0)} kg',
                        style: const TextStyle(color: GymColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
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
