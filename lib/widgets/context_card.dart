import 'package:flutter/material.dart';
import '../models/science_context.dart';
import '../theme/gym_theme.dart';

class SectionContextCard extends StatefulWidget {
  final ScienceGuideItem item;
  final bool initialExpanded;

  const SectionContextCard({
    super.key,
    required this.item,
    this.initialExpanded = false,
  });

  @override
  State<SectionContextCard> createState() => _SectionContextCardState();
}

class _SectionContextCardState extends State<SectionContextCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: GymColors.surfaceLight.withAlpha((0.6 * 255).round()),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _expanded ? GymColors.neonCyan.withAlpha((0.5 * 255).round()) : GymColors.surfaceBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: GymColors.neonCyan.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GymColors.neonCyan.withAlpha((0.3 * 255).round())),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.item.icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: GymColors.neonCyan.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.item.category.toUpperCase(),
                                style: const TextStyle(
                                  color: GymColors.neonCyan,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'SCIENCE & CONTEXT',
                              style: TextStyle(
                                color: GymColors.textMuted,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            color: GymColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: GymColors.neonCyan,
                  ),
                ],
              ),
            ),
          ),

          // Summary Brief
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            child: Text(
              widget.item.summary,
              style: const TextStyle(
                color: GymColors.textSecondary,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),

          // Expanded Scientific Deep Dive & Formulas
          if (_expanded) ...[
            const Divider(color: GymColors.surfaceBorder, height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Physiological Mechanism:',
                    style: TextStyle(
                      color: GymColors.neonCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.scientificExplanation,
                    style: const TextStyle(
                      color: GymColors.textPrimary,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  if (widget.item.formulaBreakdown.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Calculated Formula Breakdown:',
                      style: TextStyle(
                        color: GymColors.neonGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: GymColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: GymColors.surfaceBorder),
                      ),
                      child: Text(
                        widget.item.formulaBreakdown,
                        style: const TextStyle(
                          color: GymColors.neonGreen,
                          fontSize: 11,
                          fontFamily: 'monospace',
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text(
                    'Actionable Coaching Takeaways:',
                    style: TextStyle(
                      color: GymColors.neonAmber,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...widget.item.practicalActionTips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✓ ', style: TextStyle(color: GymColors.neonAmber, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(color: GymColors.textSecondary, fontSize: 11.5, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            const SizedBox(height: 10),
        ],
      ),
    );
  }
}
