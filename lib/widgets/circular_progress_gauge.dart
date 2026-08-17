import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

class CircularProgressGauge extends StatelessWidget {
  final double current;
  final double target;
  final String label;
  final String unit;
  final Color activeColor;
  final double size;
  final double strokeWidth;

  const CircularProgressGauge({
    super.key,
    required this.current,
    required this.target,
    required this.label,
    required this.unit,
    this.activeColor = GymColors.neonGreen,
    this.size = 140,
    this.strokeWidth = 10,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final pct = (progress * 100).toInt();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _GlowingArcPainter(
              progress: progress,
              activeColor: activeColor,
              trackColor: GymColors.surfaceBorder,
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                current.toStringAsFixed(0),
                style: const TextStyle(
                  color: GymColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '/${target.toStringAsFixed(0)} $unit',
                style: const TextStyle(
                  color: GymColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: activeColor.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    color: activeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlowingArcPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;
  final double strokeWidth;

  _GlowingArcPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Track Paint
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active Arc Paint with Glow
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GlowingArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.activeColor != activeColor;
  }
}
