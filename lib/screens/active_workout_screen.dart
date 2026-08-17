import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gym_provider.dart';
import '../models/workout_models.dart';
import '../models/science_context.dart';
import '../theme/gym_theme.dart';
import '../widgets/context_card.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    final gym = context.read<GymProvider>();
    if (gym.activeSessionStartTime != null) {
      _elapsed = DateTime.now().difference(gym.activeSessionStartTime!);
    }
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && gym.isWorkoutActive && gym.activeSessionStartTime != null) {
        setState(() {
          _elapsed = DateTime.now().difference(gym.activeSessionStartTime!);
        });
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    super.dispose();
  }

  void _show1RMCalculatorDialog(BuildContext context) {
    final weightCtrl = TextEditingController(text: '80');
    final repsCtrl = TextEditingController(text: '6');
    double epley1RM = 0;
    double brzycki1RM = 0;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void recalculate() {
              final w = double.tryParse(weightCtrl.text) ?? 0;
              final r = int.tryParse(repsCtrl.text) ?? 0;
              if (w > 0 && r > 0) {
                epley1RM = r == 1 ? w : w * (1 + (r / 30.0));
                brzycki1RM = r < 37 ? w * (36.0 / (37.0 - r)) : 0;
              } else {
                epley1RM = 0;
                brzycki1RM = 0;
              }
            }

            recalculate();

            return AlertDialog(
              backgroundColor: GymColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: GymColors.surfaceBorder),
              ),
              title: const Row(
                children: [
                  Icon(Icons.calculate, color: GymColors.neonGreen),
                  SizedBox(width: 8),
                  Text('1-Rep Max (1RM) Calculator', style: TextStyle(color: GymColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
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
                            decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.fitness_center, size: 16, color: GymColors.neonCyan)),
                            onChanged: (_) => setDialogState(recalculate),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: repsCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: GymColors.textPrimary, fontSize: 13),
                            decoration: const InputDecoration(labelText: 'Reps Completed', prefixIcon: Icon(Icons.repeat, size: 16, color: GymColors.neonGreen)),
                            onChanged: (_) => setDialogState(recalculate),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: GymColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: GymColors.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Epley Estimated 1RM:', style: TextStyle(color: GymColors.textSecondary, fontSize: 12)),
                              Text(
                                '${epley1RM.toStringAsFixed(1)} kg',
                                style: const TextStyle(color: GymColors.neonGreen, fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Brzycki Formula 1RM:', style: TextStyle(color: GymColors.textSecondary, fontSize: 12)),
                              Text(
                                '${brzycki1RM.toStringAsFixed(1)} kg',
                                style: const TextStyle(color: GymColors.neonCyan, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (epley1RM > 0) ...[
                      const Text('Training Load Percentages:', style: TextStyle(color: GymColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildPctBadge('90% (3RM)', (epley1RM * 0.90).toStringAsFixed(1)),
                          _buildPctBadge('80% (8RM)', (epley1RM * 0.80).toStringAsFixed(1)),
                          _buildPctBadge('70% (12RM)', (epley1RM * 0.70).toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: GymColors.neonGreen, foregroundColor: Colors.black),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildPctBadge(String label, String kg) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: GymColors.textMuted, fontSize: 9.5)),
        const SizedBox(height: 2),
        Text('$kg kg', style: const TextStyle(color: GymColors.neonAmber, fontSize: 11.5, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _showAddExerciseModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GymColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Exercise to Active Session', style: TextStyle(color: GymColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: kGlobalExerciseLibrary.length,
                  itemBuilder: (context, index) {
                    final ex = kGlobalExerciseLibrary[index];
                    return ListTile(
                      leading: Text(ex.primaryMuscle.icon, style: const TextStyle(fontSize: 20)),
                      title: Text(ex.name, style: const TextStyle(color: GymColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text('${ex.primaryMuscle.label} • ${ex.equipment}', style: const TextStyle(color: GymColors.textMuted, fontSize: 11)),
                      trailing: const Icon(Icons.add_circle, color: GymColors.neonGreen, size: 20),
                      onTap: () {
                        context.read<GymProvider>().addExerciseToActiveWorkout(ex);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFinishDialog(BuildContext context) {
    final gym = context.read<GymProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: GymColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: GymColors.surfaceBorder),
          ),
          title: const Row(
            children: [
              Icon(Icons.emoji_events, color: GymColors.neonAmber),
              SizedBox(width: 8),
              Text('Complete Workout?', style: TextStyle(color: GymColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Great effort! You completed ${gym.activeWorkoutTotalSetsCompleted} sets with a total volume of ${gym.activeWorkoutTotalVolume.toStringAsFixed(0)} kg.',
                style: const TextStyle(color: GymColors.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 10),
              const Text(
                'Session will be logged into your history and volume progression.',
                style: TextStyle(color: GymColors.neonGreen, fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Training', style: TextStyle(color: GymColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: GymColors.neonGreen, foregroundColor: Colors.black),
              onPressed: () {
                Navigator.pop(ctx);
                final session = gym.finishWorkoutSession();
                if (session != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🏆 Workout Finished! Volume: ${session.totalVolumeKg.toStringAsFixed(0)} kg lifted!'),
                      backgroundColor: GymColors.neonGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text('Finish & Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();

    if (!gym.isWorkoutActive) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: GymColors.background,
          elevation: 0,
          title: const Text('ACTIVE WORKOUT', style: TextStyle(color: GymColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: GymColors.surfaceLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fitness_center, size: 48, color: GymColors.neonCyan),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No Workout Session Active',
                  style: TextStyle(color: GymColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select a split day from the Workouts tab to begin your live session.',
                  style: TextStyle(color: GymColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final formattedElapsed = '${_elapsed.inHours.toString().padLeft(2, '0')}:${(_elapsed.inMinutes % 60).toString().padLeft(2, '0')}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: GymColors.surface,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gym.activeSessionDayName,
              style: const TextStyle(color: GymColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w900),
            ),
            Text(
              '${gym.activeSessionSplitName} • $formattedElapsed',
              style: const TextStyle(color: GymColors.neonGreen, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined, color: GymColors.neonCyan),
            tooltip: '1RM Calculator',
            onPressed: () => _show1RMCalculatorDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: GymColors.neonRed),
            tooltip: 'Cancel Session',
            onPressed: () {
              gym.cancelActiveWorkout();
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // Sticky Live Rest Timer Header if Running
              if (gym.isRestTimerRunning)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: GymColors.neonCyan.withAlpha((0.2 * 255).round()),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: GymColors.neonCyan, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'REST TIMER: ${gym.restTimerSecondsRemaining}s',
                    style: const TextStyle(color: GymColors.neonCyan, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => gym.addRestTime(30),
                    child: const Text('+30s', style: TextStyle(color: GymColors.neonCyan, fontWeight: FontWeight.bold)),
                  ),
                  TextButton(
                    onPressed: () => gym.stopRestTimer(),
                    child: const Text('Skip', style: TextStyle(color: GymColors.neonAmber, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          // Main Session Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Science Context Card for Active Lifting & RPE
                const SectionContextCard(
                  item: SectionScienceContext.activeSessionContext,
                  initialExpanded: false,
                ),

                // Session Summary Bar
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GymColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GymColors.surfaceBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniLiveStat('Total Volume', '${gym.activeWorkoutTotalVolume.toStringAsFixed(0)} kg', GymColors.neonGreen),
                      _buildMiniLiveStat('Sets Done', '${gym.activeWorkoutTotalSetsCompleted}', GymColors.neonCyan),
                      _buildMiniLiveStat('Exercises', '${gym.activeExercises.length}', GymColors.neonPurple),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Exercises & Sets
                ...gym.activeExercises.asMap().entries.map((entry) {
                  final exIdx = entry.key;
                  final exLog = entry.value;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                          children: [
                            Text(exLog.exercise.primaryMuscle.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exLog.exercise.name,
                                    style: const TextStyle(color: GymColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    '${exLog.exercise.equipment} • Est. 1RM: ${exLog.maxEstimated1RM > 0 ? '${exLog.maxEstimated1RM.toStringAsFixed(1)}kg' : '--'}',
                                    style: const TextStyle(color: GymColors.neonCyan, fontSize: 10.5, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Sets Header
                        const Row(
                          children: [
                            SizedBox(width: 32, child: Text('SET', style: TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold))),
                            Expanded(flex: 3, child: Text('KG', style: TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold))),
                            SizedBox(width: 8),
                            Expanded(flex: 3, child: Text('REPS', style: TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold))),
                            SizedBox(width: 8),
                            Expanded(flex: 2, child: Text('RPE', style: TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold))),
                            SizedBox(width: 44, child: Text('DONE', textAlign: TextAlign.center, style: TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const Divider(color: GymColors.surfaceBorder, height: 12),

                        // Set Rows
                        ...exLog.sets.asMap().entries.map((sEntry) {
                          final sIdx = sEntry.key;
                          final s = sEntry.value;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: Text('${s.setNumber}', style: const TextStyle(color: GymColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: 36,
                                    child: TextFormField(
                                      initialValue: s.weightKg > 0 ? s.weightKg.toStringAsFixed(0) : '',
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      style: const TextStyle(color: GymColors.textPrimary, fontSize: 12),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        hintText: '0',
                                      ),
                                      onChanged: (val) {
                                        gym.updateSetData(exIdx, sIdx, weightKg: double.tryParse(val) ?? 0);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: 36,
                                    child: TextFormField(
                                      initialValue: s.reps > 0 ? s.reps.toString() : '',
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: GymColors.textPrimary, fontSize: 12),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        hintText: '0',
                                      ),
                                      onChanged: (val) {
                                        gym.updateSetData(exIdx, sIdx, reps: int.tryParse(val) ?? 0);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 36,
                                    child: TextFormField(
                                      initialValue: s.rpe.toStringAsFixed(0),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      style: const TextStyle(color: GymColors.textPrimary, fontSize: 12),
                                      decoration: const InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                        hintText: '8',
                                      ),
                                      onChanged: (val) {
                                        gym.updateSetData(exIdx, sIdx, rpe: double.tryParse(val) ?? 8.0);
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                      s.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                                      color: s.isCompleted ? GymColors.neonGreen : GymColors.surfaceBorder,
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      gym.toggleSetCompleted(
                                        exIdx,
                                        sIdx,
                                        restSeconds: exLog.exercise.defaultRestSeconds,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.add, size: 14, color: GymColors.neonCyan),
                              label: const Text('Add Set', style: TextStyle(color: GymColors.neonCyan, fontSize: 11.5)),
                              onPressed: () => gym.addSetToExercise(exIdx),
                            ),
                            if (exLog.sets.length > 1)
                              TextButton.icon(
                                icon: const Icon(Icons.remove, size: 14, color: GymColors.neonRed),
                                label: const Text('Remove Set', style: TextStyle(color: GymColors.neonRed, fontSize: 11.5)),
                                onPressed: () => gym.removeSetFromExercise(exIdx, exLog.sets.length - 1),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                // Add Exercise Button
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GymColors.neonCyan,
                    side: const BorderSide(color: GymColors.neonCyan),
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Exercise to Routine'),
                  onPressed: () => _showAddExerciseModal(context),
                ),
                const SizedBox(height: 20),

                // Finish Workout Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GymColors.neonGreen,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text('COMPLETE & SAVE WORKOUT'),
                  onPressed: () => _showFinishDialog(context),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
}

  Widget _buildMiniLiveStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
      ],
    );
  }
}
