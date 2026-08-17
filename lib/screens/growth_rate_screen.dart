import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/gym_provider.dart';
import '../models/growth_log.dart';
import '../models/science_context.dart';
import '../theme/gym_theme.dart';
import '../widgets/context_card.dart';
import '../widgets/growth_chart.dart';

class GrowthRateScreen extends StatelessWidget {
  const GrowthRateScreen({super.key});

  void _showAddMeasurementDialog(BuildContext context) {
    final gym = context.read<GymProvider>();
    final weightCtrl = TextEditingController(text: gym.profile.weightKg.toStringAsFixed(1));
    final bodyFatCtrl = TextEditingController();
    final chestCtrl = TextEditingController();
    final armsCtrl = TextEditingController();
    final waistCtrl = TextEditingController();
    final thighsCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: GymColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: GymColors.surfaceBorder),
          ),
          title: const Text(
            'Log Body Checkpoint',
            style: TextStyle(color: GymColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: weightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)*',
                          prefixIcon: Icon(Icons.monitor_weight, size: 16, color: GymColors.neonGreen),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: bodyFatCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Body Fat %',
                          prefixIcon: Icon(Icons.percent, size: 16, color: GymColors.neonCyan),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: chestCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(labelText: 'Chest (cm)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: armsCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(labelText: 'Arms (cm)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: waistCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(labelText: 'Waist (cm)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: thighsCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                        decoration: const InputDecoration(labelText: 'Thighs (cm)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Notes (e.g. morning fasted weight)',
                    prefixIcon: Icon(Icons.notes, size: 16, color: GymColors.textMuted),
                  ),
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
                final w = double.tryParse(weightCtrl.text);
                if (w != null && w > 0) {
                  final measurement = BodyMeasurement(
                    id: 'meas_${DateTime.now().millisecondsSinceEpoch}',
                    date: DateTime.now(),
                    weightKg: w,
                    bodyFatPct: double.tryParse(bodyFatCtrl.text),
                    chestCm: double.tryParse(chestCtrl.text),
                    armsCm: double.tryParse(armsCtrl.text),
                    waistCm: double.tryParse(waistCtrl.text),
                    thighsCm: double.tryParse(thighsCtrl.text),
                    notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
                  );
                  gym.logMeasurement(measurement);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Checkpoint'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final analysis = gym.growthAnalysis;
    final measurements = gym.measurements;
    final sortedMeasurements = List<BodyMeasurement>.from(measurements)
      ..sort((a, b) => b.date.compareTo(a.date));

    final latest = sortedMeasurements.isNotEmpty ? sortedMeasurements.first : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GymColors.background,
        elevation: 0,
        title: const Text(
          'GROWTH RATE & BODY METRICS',
          style: TextStyle(
            color: GymColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart, color: GymColors.neonCyan),
            tooltip: 'Log New Checkpoint',
            onPressed: () => _showAddMeasurementDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section Science Context Card
          const SectionContextCard(
            item: SectionScienceContext.growthRateContext,
            initialExpanded: true,
          ),

          // Growth Rate Velocity Hero Card
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
                      'GROWTH VELOCITY ANALYSIS',
                      style: TextStyle(
                        color: GymColors.neonCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: GymColors.neonGreen.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${analysis.totalDaysLogged} Days Logged',
                        style: const TextStyle(color: GymColors.neonGreen, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${analysis.weeklyVelocityKg >= 0 ? '+' : ''}${analysis.weeklyVelocityKg.toStringAsFixed(2)} kg/wk',
                            style: const TextStyle(
                              color: GymColors.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rate: ${analysis.weeklyVelocityPct >= 0 ? '+' : ''}${analysis.weeklyVelocityPct.toStringAsFixed(2)}% bodyweight/wk',
                            style: const TextStyle(color: GymColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total Delta: ${analysis.totalDeltaKg >= 0 ? '+' : ''}${analysis.totalDeltaKg.toStringAsFixed(1)} kg',
                            style: const TextStyle(color: GymColors.neonCyan, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Start: ${analysis.startingWeightKg.toStringAsFixed(1)}kg → Now: ${analysis.currentWeightKg.toStringAsFixed(1)}kg',
                            style: const TextStyle(color: GymColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: GymColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GymColors.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.psychology, color: GymColors.neonGreen, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              analysis.statusLabel,
                              style: const TextStyle(color: GymColors.textPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              analysis.coachingRecommendation,
                              style: const TextStyle(color: GymColors.textSecondary, fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Trend Chart
          const Text(
            'WEIGHT PROGRESSION & GOAL TRAJECTORY',
            style: TextStyle(
              color: GymColors.neonGreen,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          GrowthTrendChart(
            measurements: measurements,
            targetWeightKg: gym.profile.targetWeightKg,
          ),
          const SizedBox(height: 16),

          // Latest Body Composition & Circumferences Card
          if (latest != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
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
                        'LATEST BODY MEASUREMENTS',
                        style: TextStyle(color: GymColors.neonAmber, fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(latest.date),
                        style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildCircumferencePill('Chest', latest.chestCm, 'cm'),
                      _buildCircumferencePill('Arms', latest.armsCm, 'cm'),
                      _buildCircumferencePill('Waist', latest.waistCm, 'cm'),
                      _buildCircumferencePill('Thighs', latest.thighsCm, 'cm'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // History Checkpoint Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHECKPOINT LOGS (${sortedMeasurements.length})',
                style: const TextStyle(
                  color: GymColors.neonPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GymColors.neonCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                ),
                icon: const Icon(Icons.add, size: 14),
                label: const Text('Add Checkpoint', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () => _showAddMeasurementDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...sortedMeasurements.map((m) {
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GymColors.neonCyan.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calendar_today, color: GymColors.neonCyan, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${m.weightKg.toStringAsFixed(1)} kg',
                              style: const TextStyle(color: GymColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                            if (m.bodyFatPct != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: GymColors.neonGreen.withAlpha((0.2 * 255).round()),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('${m.bodyFatPct!.toStringAsFixed(1)}% BF', style: const TextStyle(color: GymColors.neonGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, MMM dd, yyyy').format(m.date),
                          style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
                        ),
                        if (m.notes != null) ...[
                          const SizedBox(height: 2),
                          Text(m.notes!, style: const TextStyle(color: GymColors.textSecondary, fontSize: 11, fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: GymColors.textMuted, size: 18),
                    onPressed: () => gym.deleteMeasurement(m.id),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCircumferencePill(String label, double? val, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: GymColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GymColors.surfaceBorder),
          ),
          child: Text(
            val != null ? '${val.toStringAsFixed(1)} $unit' : '--',
            style: const TextStyle(color: GymColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
