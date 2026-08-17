
class BodyMeasurement {
  final String id;
  final DateTime date;
  final double weightKg;
  final double? bodyFatPct;
  final double? chestCm;
  final double? waistCm;
  final double? armsCm;
  final double? thighsCm;
  final String? notes;

  BodyMeasurement({
    required this.id,
    required this.date,
    required this.weightKg,
    this.bodyFatPct,
    this.chestCm,
    this.waistCm,
    this.armsCm,
    this.thighsCm,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'bodyFatPct': bodyFatPct,
      'chestCm': chestCm,
      'waistCm': waistCm,
      'armsCm': armsCm,
      'thighsCm': thighsCm,
      'notes': notes,
    };
  }

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      id: map['id'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 70.0,
      bodyFatPct: (map['bodyFatPct'] as num?)?.toDouble(),
      chestCm: (map['chestCm'] as num?)?.toDouble(),
      waistCm: (map['waistCm'] as num?)?.toDouble(),
      armsCm: (map['armsCm'] as num?)?.toDouble(),
      thighsCm: (map['thighsCm'] as num?)?.toDouble(),
      notes: map['notes'],
    );
  }
}

class GrowthRateAnalysis {
  final double currentWeightKg;
  final double startingWeightKg;
  final double totalDeltaKg;
  final double weeklyVelocityKg; // kg per week
  final double weeklyVelocityPct; // % of bodyweight per week
  final int totalDaysLogged;
  final String statusLabel;
  final String coachingRecommendation;
  final String velocityColorHex; // e.g. green for optimal, orange for slow/fast

  GrowthRateAnalysis({
    required this.currentWeightKg,
    required this.startingWeightKg,
    required this.totalDeltaKg,
    required this.weeklyVelocityKg,
    required this.weeklyVelocityPct,
    required this.totalDaysLogged,
    required this.statusLabel,
    required this.coachingRecommendation,
    required this.velocityColorHex,
  });

  factory GrowthRateAnalysis.fromLogs(List<BodyMeasurement> logs, String goalType) {
    if (logs.isEmpty) {
      return GrowthRateAnalysis(
        currentWeightKg: 0,
        startingWeightKg: 0,
        totalDeltaKg: 0,
        weeklyVelocityKg: 0,
        weeklyVelocityPct: 0,
        totalDaysLogged: 0,
        statusLabel: 'No Logs Yet',
        coachingRecommendation: 'Log your weight at least 2-3 times a week under identical morning conditions.',
        velocityColorHex: '#9E9E9E',
      );
    }

    final sorted = List<BodyMeasurement>.from(logs)..sort((a, b) => a.date.compareTo(b.date));
    final first = sorted.first;
    final last = sorted.last;
    final days = last.date.difference(first.date).inDays.clamp(1, 9999);
    final totalDelta = last.weightKg - first.weightKg;
    final weeklyVelocity = (totalDelta / days) * 7.0;
    final weeklyVelocityPct = last.weightKg > 0 ? (weeklyVelocity / last.weightKg) * 100 : 0.0;

    String label;
    String advice;
    String color;

    final isBulking = goalType.toLowerCase().contains('bulk') || goalType.toLowerCase().contains('hypertrophy');
    final isCutting = goalType.toLowerCase().contains('fat') || goalType.toLowerCase().contains('cut');

    if (days < 7) {
      label = 'Initial Tracking Phase';
      advice = 'Continue recording weekly weight. Rate stabilization occurs after 14-21 days.';
      color = '#00E5FF';
    } else if (isBulking) {
      if (weeklyVelocity >= 0.15 && weeklyVelocity <= 0.45) {
        label = 'Optimal Lean Hypertrophy Pace';
        advice = 'Growth rate is in the golden 0.25-0.5% bodyweight/week sweet spot. Muscle synthesis is maximized with minimal fat spillover.';
        color = '#00E676';
      } else if (weeklyVelocity > 0.45) {
        label = 'Rapid Gaining Pace (Watch Fat Spillover)';
        advice = 'Gaining >0.5kg/week often adds adipose tissue. Consider reducing daily surplus by 150-200 kcal.';
        color = '#FFB300';
      } else {
        label = 'Plateaued / Slow Mass Gain';
        advice = 'Weight gain is stalled (<0.15kg/wk). Increase daily caloric intake by +200-300 kcal (approx 50g extra carbs or healthy fats).';
        color = '#FF9100';
      }
    } else if (isCutting) {
      if (weeklyVelocity <= -0.3 && weeklyVelocity >= -0.8) {
        label = 'Optimal Fat Loss Pace';
        advice = 'Losing 0.5-1.0% bodyweight/week. Lean muscle mass and metabolic rate are well-preserved.';
        color = '#00E676';
      } else if (weeklyVelocity < -0.8) {
        label = 'Aggressive Deficit (Muscle Loss Risk)';
        advice = 'Losing >1.0kg/week can trigger muscle catabolism and strength loss. Increase protein and add 150-200 kcal.';
        color = '#FF5252';
      } else {
        label = 'Fat Loss Plateau';
        advice = 'Weight delta is flat (<0.2kg loss/wk). Step up daily NEAT activity (e.g. +2,000 steps) or adjust calories down by 150 kcal.';
        color = '#FFB300';
      }
    } else {
      // Maintenance
      if (weeklyVelocity.abs() < 0.2) {
        label = 'Perfect Weight Equilibrium';
        advice = 'Bodyweight is highly stable within ±0.2kg/week. Body recomposition is on track.';
        color = '#00E676';
      } else {
        label = 'Weight Fluctuating';
        advice = 'Tracking standard deviations over 14 days will filter out glycogen and sodium water retention.';
        color = '#00E5FF';
      }
    }

    return GrowthRateAnalysis(
      currentWeightKg: last.weightKg,
      startingWeightKg: first.weightKg,
      totalDeltaKg: totalDelta,
      weeklyVelocityKg: weeklyVelocity,
      weeklyVelocityPct: weeklyVelocityPct,
      totalDaysLogged: days,
      statusLabel: label,
      coachingRecommendation: advice,
      velocityColorHex: color,
    );
  }
}
