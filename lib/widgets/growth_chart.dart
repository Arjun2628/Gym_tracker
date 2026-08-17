import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/growth_log.dart';
import '../theme/gym_theme.dart';

class GrowthTrendChart extends StatelessWidget {
  final List<BodyMeasurement> measurements;
  final double targetWeightKg;

  const GrowthTrendChart({
    super.key,
    required this.measurements,
    required this.targetWeightKg,
  });

  @override
  Widget build(BuildContext context) {
    if (measurements.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text('No measurement history yet', style: TextStyle(color: GymColors.textMuted)),
      );
    }

    final sorted = List<BodyMeasurement>.from(measurements)
      ..sort((a, b) => a.date.compareTo(b.date));

    final spots = <FlSpot>[];
    double minY = targetWeightKg;
    double maxY = targetWeightKg;

    for (int i = 0; i < sorted.length; i++) {
      final w = sorted[i].weightKg;
      spots.add(FlSpot(i.toDouble(), w));
      if (w < minY) minY = w;
      if (w > maxY) maxY = w;
    }

    minY = (minY - 2.0).floorToDouble();
    maxY = (maxY + 2.0).ceilToDouble();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: GymColors.surfaceLight.withAlpha((0.5 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GymColors.surfaceBorder),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: GymColors.surfaceBorder.withAlpha((0.5 * 255).round()),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: 2,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}kg',
                    style: const TextStyle(
                      color: GymColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sorted.length) {
                    return Text(
                      DateFormat('MM/dd').format(sorted[index].date),
                      style: const TextStyle(
                        color: GymColors.textMuted,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: targetWeightKg,
                color: GymColors.neonAmber.withAlpha((0.8 * 255).round()),
                strokeWidth: 1.5,
                dashArray: [5, 5],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(right: 8, bottom: 2),
                  style: const TextStyle(
                    color: GymColors.neonAmber,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                  labelResolver: (line) => 'Goal: ${targetWeightKg.toStringAsFixed(1)}kg',
                ),
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: GymColors.neonGreen,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: GymColors.neonGreen,
                    strokeWidth: 2,
                    strokeColor: GymColors.background,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    GymColors.neonGreen.withAlpha((0.25 * 255).round()),
                    GymColors.neonGreen.withAlpha(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
