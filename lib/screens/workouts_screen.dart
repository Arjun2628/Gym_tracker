import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gym_provider.dart';
import '../models/workout_models.dart';
import '../models/science_context.dart';
import '../theme/gym_theme.dart';
import '../widgets/context_card.dart';

class WorkoutsScreen extends StatefulWidget {
  final VoidCallback onOpenActiveWorkout;

  const WorkoutsScreen({
    super.key,
    required this.onOpenActiveWorkout,
  });

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  MuscleGroup? _selectedExerciseFilter;

  void _showExerciseDetailsModal(BuildContext context, Exercise exercise) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GymColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GymColors.neonCyan.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(exercise.primaryMuscle.icon, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(color: GymColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          '${exercise.primaryMuscle.label} • ${exercise.equipment}',
                          style: const TextStyle(color: GymColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Biomechanical Execution Tip:', style: TextStyle(color: GymColors.neonGreen, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GymColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GymColors.surfaceBorder),
                ),
                child: Text(
                  exercise.executionTip,
                  style: const TextStyle(color: GymColors.textPrimary, fontSize: 12.5, height: 1.4),
                ),
              ),
              const SizedBox(height: 12),
              if (exercise.secondaryMuscles.isNotEmpty) ...[
                const Text('Synergistic Secondary Muscles:', style: TextStyle(color: GymColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: exercise.secondaryMuscles.map((m) {
                    return Chip(
                      backgroundColor: GymColors.surfaceLight,
                      label: Text('${m.icon} ${m.name.toUpperCase()}', style: const TextStyle(fontSize: 10, color: GymColors.textSecondary)),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gym = context.watch<GymProvider>();
    final activeSplit = gym.activeSplit;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: GymColors.background,
          elevation: 0,
          title: const Text(
            'WORKOUT SEPARATION & SPLITS',
            style: TextStyle(
              color: GymColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: GymColors.neonGreen,
            labelColor: GymColors.neonGreen,
            unselectedLabelColor: GymColors.textMuted,
            tabs: [
              Tab(icon: Icon(Icons.splitscreen, size: 18), text: 'Training Splits'),
              Tab(icon: Icon(Icons.menu_book, size: 18), text: 'Exercise Library'),
            ],
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: TabBarView(
              children: [
                // TAB 1: TRAINING SPLITS
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                // Hero Workout Image Banner
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/workout_hero.jpg',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha((0.85 * 255).round()),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: GymColors.neonGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PRO SPLITS',
                                style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Hypertrophy & Strength Protocols',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Section Science Context Card
                const SectionContextCard(
                  item: SectionScienceContext.workoutSplitContext,
                  initialExpanded: false,
                ),

                // Split Selector Carousel / Chips
                const Text(
                  'SELECT TRAINING SPLIT TEMPLATE',
                  style: TextStyle(
                    color: GymColors.neonCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: gym.splits.map((s) {
                      final isSelected = s.id == activeSplit.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s.name),
                          selected: isSelected,
                          selectedColor: GymColors.neonGreen,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : GymColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 12,
                          ),
                          backgroundColor: GymColors.surfaceLight,
                          onSelected: (_) => gym.setActiveSplit(s),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Active Split Details Header Card
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
                          Expanded(
                            child: Text(
                              activeSplit.name,
                              style: const TextStyle(color: GymColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: GymColors.neonCyan.withAlpha((0.2 * 255).round()),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${activeSplit.daysPerWeek} Days/Week',
                              style: const TextStyle(color: GymColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        activeSplit.description,
                        style: const TextStyle(color: GymColors.textSecondary, fontSize: 12, height: 1.3),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: GymColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GymColors.surfaceBorder),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🔬 ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                activeSplit.scienceAdvantage,
                                style: const TextStyle(color: GymColors.neonGreen, fontSize: 11.5, height: 1.3, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Split Days List
                const Text(
                  'ROUTINE BREAKDOWN & EXERCISES',
                  style: TextStyle(
                    color: GymColors.neonGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),

                ...activeSplit.days.map((day) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    day.name,
                                    style: const TextStyle(color: GymColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Wrap(
                                    spacing: 4,
                                    children: day.muscleFocus.map((m) {
                                      return Text('${m.icon} ${m.name.toUpperCase()} ', style: const TextStyle(color: GymColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold));
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GymColors.neonGreen,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                              icon: const Icon(Icons.play_arrow, size: 16),
                              label: const Text('Start Day', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                              onPressed: () {
                                gym.startWorkoutSession(
                                  splitName: activeSplit.name,
                                  day: day,
                                );
                                widget.onOpenActiveWorkout();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: GymColors.surfaceBorder),
                        const SizedBox(height: 6),

                        ...day.exercises.map((p) {
                          final ex = kGlobalExerciseLibrary.firstWhere(
                            (e) => e.id == p.exerciseId,
                            orElse: () => Exercise(
                              id: p.exerciseId,
                              name: p.exerciseId,
                              primaryMuscle: MuscleGroup.chest,
                              equipment: 'Gym',
                              executionTip: '',
                            ),
                          );

                          return InkWell(
                            onTap: () => _showExerciseDetailsModal(context, ex),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              child: Row(
                                children: [
                                  Text(ex.primaryMuscle.icon, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ex.name, style: const TextStyle(color: GymColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                                        Text(ex.equipment, style: const TextStyle(color: GymColors.textMuted, fontSize: 10.5)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: GymColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: GymColors.surfaceBorder),
                                    ),
                                    child: Text(
                                      '${p.targetSets} sets × ${p.targetReps}',
                                      style: const TextStyle(color: GymColors.neonCyan, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),

            // TAB 2: EXERCISE LIBRARY
            Column(
              children: [
                // Muscle Filter Chips
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  color: GymColors.surface,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('All Muscles'),
                          selected: _selectedExerciseFilter == null,
                          selectedColor: GymColors.neonCyan,
                          labelStyle: TextStyle(
                            color: _selectedExerciseFilter == null ? Colors.black : GymColors.textPrimary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: GymColors.surfaceLight,
                          onSelected: (_) => setState(() => _selectedExerciseFilter = null),
                        ),
                        const SizedBox(width: 6),
                        ...MuscleGroup.values.map((mg) {
                          final isSel = _selectedExerciseFilter == mg;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text('${mg.icon} ${mg.name.toUpperCase()}'),
                              selected: isSel,
                              selectedColor: GymColors.neonCyan,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.black : GymColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              backgroundColor: GymColors.surfaceLight,
                              onSelected: (_) => setState(() => _selectedExerciseFilter = mg),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Exercise List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: kGlobalExerciseLibrary.where((ex) {
                      if (_selectedExerciseFilter == null) return true;
                      return ex.primaryMuscle == _selectedExerciseFilter;
                    }).map((exercise) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: GymColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: GymColors.surfaceBorder),
                        ),
                        child: ListTile(
                          leading: Text(exercise.primaryMuscle.icon, style: const TextStyle(fontSize: 22)),
                          title: Text(
                            exercise.name,
                            style: const TextStyle(color: GymColors.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${exercise.primaryMuscle.label} • ${exercise.equipment}',
                            style: const TextStyle(color: GymColors.textMuted, fontSize: 11),
                          ),
                          trailing: const Icon(Icons.info_outline, color: GymColors.neonCyan, size: 18),
                          onTap: () => _showExerciseDetailsModal(context, exercise),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
);
}
}
