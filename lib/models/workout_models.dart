
enum MuscleGroup {
  chest('Chest (Pectorals)', '💥'),
  back('Back (Lats, Traps, Rhomboids)', '🦅'),
  shoulders('Shoulders (Deltoids)', '🛡️'),
  biceps('Biceps', '💪'),
  triceps('Triceps', '🔱'),
  quads('Quadriceps', '🦵'),
  hamstrings('Hamstrings & Glutes', '🔥'),
  calves('Calves', '⚡'),
  core('Abs & Core', '🧱');

  final String label;
  final String icon;
  const MuscleGroup(this.label, this.icon);
}

class Exercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final String equipment;
  final String executionTip;
  final int defaultRestSeconds;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    required this.equipment,
    required this.executionTip,
    this.defaultRestSeconds = 90,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'primaryMuscle': primaryMuscle.name,
      'secondaryMuscles': secondaryMuscles.map((m) => m.name).toList(),
      'equipment': equipment,
      'executionTip': executionTip,
      'defaultRestSeconds': defaultRestSeconds,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      primaryMuscle: MuscleGroup.values.firstWhere(
        (m) => m.name == map['primaryMuscle'],
        orElse: () => MuscleGroup.chest,
      ),
      secondaryMuscles: (map['secondaryMuscles'] as List<dynamic>?)
              ?.map((m) => MuscleGroup.values.firstWhere(
                    (g) => g.name == m,
                    orElse: () => MuscleGroup.chest,
                  ))
              .toList() ??
          [],
      equipment: map['equipment'] ?? 'Barbell',
      executionTip: map['executionTip'] ?? '',
      defaultRestSeconds: (map['defaultRestSeconds'] as num?)?.toInt() ?? 90,
    );
  }
}

class ExercisePrescription {
  final String exerciseId;
  final int targetSets;
  final String targetReps; // e.g. "8-12" or "5"
  final int restSeconds;

  const ExercisePrescription({
    required this.exerciseId,
    this.targetSets = 3,
    this.targetReps = '8-12',
    this.restSeconds = 90,
  });

  Map<String, dynamic> toMap() => {
        'exerciseId': exerciseId,
        'targetSets': targetSets,
        'targetReps': targetReps,
        'restSeconds': restSeconds,
      };

  factory ExercisePrescription.fromMap(Map<String, dynamic> map) => ExercisePrescription(
        exerciseId: map['exerciseId'] ?? '',
        targetSets: (map['targetSets'] as num?)?.toInt() ?? 3,
        targetReps: map['targetReps'] ?? '8-12',
        restSeconds: (map['restSeconds'] as num?)?.toInt() ?? 90,
      );
}

class WorkoutSplitDay {
  final String id;
  final String name; // e.g. "Push Day (Chest, Shoulders, Triceps)"
  final List<MuscleGroup> muscleFocus;
  final List<ExercisePrescription> exercises;

  WorkoutSplitDay({
    required this.id,
    required this.name,
    required this.muscleFocus,
    required this.exercises,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'muscleFocus': muscleFocus.map((m) => m.name).toList(),
        'exercises': exercises.map((e) => e.toMap()).toList(),
      };

  factory WorkoutSplitDay.fromMap(Map<String, dynamic> map) => WorkoutSplitDay(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        muscleFocus: (map['muscleFocus'] as List<dynamic>?)
                ?.map((m) => MuscleGroup.values.firstWhere((g) => g.name == m))
                .toList() ??
            [],
        exercises: (map['exercises'] as List<dynamic>?)
                ?.map((e) => ExercisePrescription.fromMap(e))
                .toList() ??
            [],
      );
}

class WorkoutSplit {
  final String id;
  final String name;
  final String description;
  final int daysPerWeek;
  final String scienceAdvantage;
  final List<WorkoutSplitDay> days;

  WorkoutSplit({
    required this.id,
    required this.name,
    required this.description,
    required this.daysPerWeek,
    required this.scienceAdvantage,
    required this.days,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'daysPerWeek': daysPerWeek,
        'scienceAdvantage': scienceAdvantage,
        'days': days.map((d) => d.toMap()).toList(),
      };

  factory WorkoutSplit.fromMap(Map<String, dynamic> map) => WorkoutSplit(
        id: map['id'] ?? '',
        name: map['name'] ?? '',
        description: map['description'] ?? '',
        daysPerWeek: (map['daysPerWeek'] as num?)?.toInt() ?? 3,
        scienceAdvantage: map['scienceAdvantage'] ?? '',
        days: (map['days'] as List<dynamic>?)
                ?.map((d) => WorkoutSplitDay.fromMap(d))
                .toList() ??
            [],
      );
}

class WorkoutSet {
  int setNumber;
  double weightKg;
  int reps;
  double rpe; // 6.0 to 10.0
  bool isCompleted;
  bool isWarmup;

  WorkoutSet({
    required this.setNumber,
    this.weightKg = 0.0,
    this.reps = 0,
    this.rpe = 8.0,
    this.isCompleted = false,
    this.isWarmup = false,
  });

  /// Epley 1RM Formula: Weight * (1 + Reps / 30)
  double get estimatedOneRepMax {
    if (reps <= 0 || weightKg <= 0) return 0.0;
    if (reps == 1) return weightKg;
    return weightKg * (1.0 + (reps / 30.0));
  }

  /// Brzycki 1RM Formula: Weight * (36 / (37 - Reps))
  double get brzyckiOneRepMax {
    if (reps <= 0 || reps >= 37 || weightKg <= 0) return 0.0;
    return weightKg * (36.0 / (37.0 - reps));
  }

  double get setVolume => isCompleted && !isWarmup ? weightKg * reps : 0.0;

  Map<String, dynamic> toMap() => {
        'setNumber': setNumber,
        'weightKg': weightKg,
        'reps': reps,
        'rpe': rpe,
        'isCompleted': isCompleted,
        'isWarmup': isWarmup,
      };

  factory WorkoutSet.fromMap(Map<String, dynamic> map) => WorkoutSet(
        setNumber: (map['setNumber'] as num?)?.toInt() ?? 1,
        weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
        reps: (map['reps'] as num?)?.toInt() ?? 0,
        rpe: (map['rpe'] as num?)?.toDouble() ?? 8.0,
        isCompleted: map['isCompleted'] ?? false,
        isWarmup: map['isWarmup'] ?? false,
      );
}

class SessionExerciseLog {
  final Exercise exercise;
  final List<WorkoutSet> sets;
  String notes;

  SessionExerciseLog({
    required this.exercise,
    List<WorkoutSet>? sets,
    this.notes = '',
  }) : sets = sets ?? [];

  double get totalExerciseVolume => sets.fold(0.0, (sum, s) => sum + s.setVolume);
  int get completedSetsCount => sets.where((s) => s.isCompleted).length;

  double get maxEstimated1RM {
    double max = 0.0;
    for (final s in sets) {
      if (s.isCompleted && s.estimatedOneRepMax > max) {
        max = s.estimatedOneRepMax;
      }
    }
    return max;
  }
}

class CompletedWorkoutSession {
  final String id;
  final String splitName;
  final String dayName;
  final DateTime startTime;
  final DateTime endTime;
  final List<SessionExerciseLog> exercises;
  final double totalVolumeKg;
  final int durationMinutes;

  CompletedWorkoutSession({
    required this.id,
    required this.splitName,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.exercises,
    required this.totalVolumeKg,
    required this.durationMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'splitName': splitName,
      'dayName': dayName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalVolumeKg': totalVolumeKg,
      'durationMinutes': durationMinutes,
      'exercisesCount': exercises.length,
    };
  }

  factory CompletedWorkoutSession.fromMap(Map<String, dynamic> map) {
    return CompletedWorkoutSession(
      id: map['id'] ?? '',
      splitName: map['splitName'] ?? '',
      dayName: map['dayName'] ?? '',
      startTime: DateTime.tryParse(map['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime'] ?? '') ?? DateTime.now(),
      exercises: [],
      totalVolumeKg: (map['totalVolumeKg'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 45,
    );
  }
}

// Built-in Exercise Library
const List<Exercise> kGlobalExerciseLibrary = [
  // CHEST
  Exercise(
    id: 'barbell_bench_press',
    name: 'Barbell Flat Bench Press',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    equipment: 'Barbell & Flat Bench',
    executionTip: 'Retract scapulae, touch lower sternum with control, press with leg drive.',
    defaultRestSeconds: 150,
  ),
  Exercise(
    id: 'incline_dumbbell_press',
    name: 'Incline Dumbbell Press (30°)',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.triceps],
    equipment: 'Dumbbells & Incline Bench',
    executionTip: 'Keep bench at 30 degrees to target clavicular upper chest without shoulder impingement.',
    defaultRestSeconds: 120,
  ),
  Exercise(
    id: 'cable_chest_fly',
    name: 'Standing Cable Chest Fly',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscles: [MuscleGroup.shoulders],
    equipment: 'Dual Cable Machine',
    executionTip: 'Maintain slight elbow bend, squeeze at midline for peak contraction.',
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'chest_dips',
    name: 'Weighted Bodyweight Dips',
    primaryMuscle: MuscleGroup.chest,
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.shoulders],
    equipment: 'Dip Station / Belt',
    executionTip: 'Lean torso forward 30° to bias lower chest fibers over triceps.',
    defaultRestSeconds: 120,
  ),

  // BACK
  Exercise(
    id: 'barbell_deadlift',
    name: 'Conventional Barbell Deadlift',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.quads, MuscleGroup.core],
    equipment: 'Olympic Barbell & Plates',
    executionTip: 'Engage lats, brace intra-abdominal pressure, push floor away through heels.',
    defaultRestSeconds: 180,
  ),
  Exercise(
    id: 'barbell_bent_row',
    name: 'Barbell Bent-Over Row',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.shoulders],
    equipment: 'Barbell',
    executionTip: 'Hinge at hips at 45°, pull bar toward belly button leading with elbows.',
    defaultRestSeconds: 120,
  ),
  Exercise(
    id: 'lat_pulldown',
    name: 'Wide-Grip Lat Pulldown',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.biceps],
    equipment: 'Lat Pulldown Cable Machine',
    executionTip: 'Depress shoulders before pulling down to upper clavicle.',
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'seated_cable_row',
    name: 'Seated Close-Grip Cable Row',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.biceps],
    equipment: 'Cable Row Machine',
    executionTip: 'Keep spine neutral, drive elbows past torso, pause for 1 second at peak.',
    defaultRestSeconds: 90,
  ),
  Exercise(
    id: 'pull_ups',
    name: 'Weighted Pull-Ups',
    primaryMuscle: MuscleGroup.back,
    secondaryMuscles: [MuscleGroup.biceps, MuscleGroup.core],
    equipment: 'Pull-Up Bar',
    executionTip: 'Full dead-hang at bottom, pull chest to bar without kipping.',
    defaultRestSeconds: 120,
  ),

  // SHOULDERS
  Exercise(
    id: 'overhead_barbell_press',
    name: 'Standing Overhead Military Press',
    primaryMuscle: MuscleGroup.shoulders,
    secondaryMuscles: [MuscleGroup.triceps, MuscleGroup.core],
    equipment: 'Barbell',
    executionTip: 'Squeeze glutes and core tightly, press vertically clearing chin.',
    defaultRestSeconds: 150,
  ),
  Exercise(
    id: 'dumbbell_lateral_raise',
    name: 'Dumbbell Lateral Raise',
    primaryMuscle: MuscleGroup.shoulders,
    secondaryMuscles: [],
    equipment: 'Dumbbells',
    executionTip: 'Raise in the scapular plane (15° forward), lead with elbows, slow 3s eccentric.',
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'cable_face_pulls',
    name: 'Rope Cable Face Pulls',
    primaryMuscle: MuscleGroup.shoulders,
    secondaryMuscles: [MuscleGroup.back],
    equipment: 'Cable Machine & Rope',
    executionTip: 'Pull to eye level while externally rotating shoulders for rotator cuff health.',
    defaultRestSeconds: 60,
  ),

  // LEGS (QUADS, HAMSTRINGS, CALVES)
  Exercise(
    id: 'barbell_back_squat',
    name: 'Barbell Back Squat',
    primaryMuscle: MuscleGroup.quads,
    secondaryMuscles: [MuscleGroup.hamstrings, MuscleGroup.core],
    equipment: 'Squat Rack & Barbell',
    executionTip: 'Break at hips and knees simultaneously, achieve parallel depth or below.',
    defaultRestSeconds: 180,
  ),
  Exercise(
    id: 'romanian_deadlift',
    name: 'Barbell Romanian Deadlift (RDL)',
    primaryMuscle: MuscleGroup.hamstrings,
    secondaryMuscles: [MuscleGroup.back],
    equipment: 'Barbell or Dumbbells',
    executionTip: 'Push hips backward like shutting a car door, feeling deep stretch in hamstrings.',
    defaultRestSeconds: 120,
  ),
  Exercise(
    id: 'leg_press',
    name: '45° Incline Leg Press',
    primaryMuscle: MuscleGroup.quads,
    secondaryMuscles: [MuscleGroup.hamstrings],
    equipment: 'Leg Press Sled',
    executionTip: 'Keep lower back glued to pad, avoid locking knees at full extension.',
    defaultRestSeconds: 120,
  ),
  Exercise(
    id: 'leg_curl',
    name: 'Lying Hamstring Leg Curl',
    primaryMuscle: MuscleGroup.hamstrings,
    secondaryMuscles: [MuscleGroup.calves],
    equipment: 'Leg Curl Machine',
    executionTip: 'Control the descent without letting weights slam down.',
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'standing_calf_raise',
    name: 'Standing Calf Raise',
    primaryMuscle: MuscleGroup.calves,
    secondaryMuscles: [],
    equipment: 'Calf Machine or Smith Machine',
    executionTip: 'Hold 2 second stretch at bottom, explosive rise on balls of feet.',
    defaultRestSeconds: 60,
  ),

  // ARMS (BICEPS & TRICEPS)
  Exercise(
    id: 'barbell_bicep_curl',
    name: 'EZ-Bar Bicep Curl',
    primaryMuscle: MuscleGroup.biceps,
    secondaryMuscles: [],
    equipment: 'EZ-Curl Bar',
    executionTip: 'Pin elbows by your sides, avoid using hip momentum.',
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'incline_dumbbell_curl',
    name: 'Incline Dumbbell Bicep Curl',
    primaryMuscle: MuscleGroup.biceps,
    secondaryMuscles: [],
    equipment: 'Incline Bench & Dumbbells',
    executionTip: 'Maximizes stretch on long head of bicep due to shoulder hyperextension.',
    defaultRestSeconds: 75,
  ),
  Exercise(
    id: 'tricep_cable_pushdown',
    name: 'Tricep Rope Cable Pushdown',
    primaryMuscle: MuscleGroup.triceps,
    secondaryMuscles: [],
    equipment: 'Cable & Rope',
    executionTip: 'Flare rope outward at bottom for intense lateral head contraction.',
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'skull_crushers',
    name: 'EZ-Bar Lying Tricep Extension (Skull Crushers)',
    primaryMuscle: MuscleGroup.triceps,
    secondaryMuscles: [],
    equipment: 'EZ-Bar & Flat Bench',
    executionTip: 'Lower bar behind crown of head to keep tension continuous throughout.',
    defaultRestSeconds: 90,
  ),

  // CORE
  Exercise(
    id: 'hanging_leg_raise',
    name: 'Hanging Leg / Knee Raise',
    primaryMuscle: MuscleGroup.core,
    secondaryMuscles: [],
    equipment: 'Pull-Up Bar',
    executionTip: 'Curl pelvis upward toward ribcage rather than just swinging legs.',
    defaultRestSeconds: 60,
  ),
  Exercise(
    id: 'cable_woodchopper',
    name: 'Cable Woodchopper (Obliques)',
    primaryMuscle: MuscleGroup.core,
    secondaryMuscles: [],
    equipment: 'Cable Machine',
    executionTip: 'Rotate through thoracic spine and hips for rotational stability.',
    defaultRestSeconds: 60,
  ),
];

// Preset Workout Splits
final List<WorkoutSplit> kPresetWorkoutSplits = [
  // 1. Push / Pull / Legs (PPL)
  WorkoutSplit(
    id: 'ppl_split',
    name: 'Push / Pull / Legs (PPL)',
    description: 'The premier hypertrophy split. Trains synergistic muscle groups together with high frequency.',
    daysPerWeek: 6,
    scienceAdvantage:
        'Stimulates each muscle group twice every 7 days, aligning with the 48-72h muscle protein synthesis curve.',
    days: [
      WorkoutSplitDay(
        id: 'ppl_push',
        name: 'Push (Chest, Delts, Triceps)',
        muscleFocus: [MuscleGroup.chest, MuscleGroup.shoulders, MuscleGroup.triceps],
        exercises: [
          const ExercisePrescription(exerciseId: 'barbell_bench_press', targetSets: 4, targetReps: '6-8', restSeconds: 150),
          const ExercisePrescription(exerciseId: 'incline_dumbbell_press', targetSets: 3, targetReps: '8-12', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'overhead_barbell_press', targetSets: 3, targetReps: '8-10', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'dumbbell_lateral_raise', targetSets: 4, targetReps: '12-15', restSeconds: 60),
          const ExercisePrescription(exerciseId: 'tricep_cable_pushdown', targetSets: 3, targetReps: '10-12', restSeconds: 60),
        ],
      ),
      WorkoutSplitDay(
        id: 'ppl_pull',
        name: 'Pull (Back, Rear Delts, Biceps)',
        muscleFocus: [MuscleGroup.back, MuscleGroup.biceps],
        exercises: [
          const ExercisePrescription(exerciseId: 'barbell_bent_row', targetSets: 4, targetReps: '6-8', restSeconds: 150),
          const ExercisePrescription(exerciseId: 'lat_pulldown', targetSets: 3, targetReps: '8-12', restSeconds: 90),
          const ExercisePrescription(exerciseId: 'seated_cable_row', targetSets: 3, targetReps: '10-12', restSeconds: 90),
          const ExercisePrescription(exerciseId: 'cable_face_pulls', targetSets: 3, targetReps: '12-15', restSeconds: 60),
          const ExercisePrescription(exerciseId: 'barbell_bicep_curl', targetSets: 3, targetReps: '8-10', restSeconds: 75),
        ],
      ),
      WorkoutSplitDay(
        id: 'ppl_legs',
        name: 'Legs & Core (Quads, Hamstrings, Abs)',
        muscleFocus: [MuscleGroup.quads, MuscleGroup.hamstrings, MuscleGroup.calves, MuscleGroup.core],
        exercises: [
          const ExercisePrescription(exerciseId: 'barbell_back_squat', targetSets: 4, targetReps: '6-8', restSeconds: 180),
          const ExercisePrescription(exerciseId: 'romanian_deadlift', targetSets: 3, targetReps: '8-10', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'leg_press', targetSets: 3, targetReps: '10-12', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'standing_calf_raise', targetSets: 4, targetReps: '12-15', restSeconds: 60),
          const ExercisePrescription(exerciseId: 'hanging_leg_raise', targetSets: 3, targetReps: '12-15', restSeconds: 60),
        ],
      ),
    ],
  ),

  // 2. Upper / Lower Split (4 Day)
  WorkoutSplit(
    id: 'upper_lower_split',
    name: 'Upper / Lower (4-Day Balance)',
    description: 'Perfect balance of recovery and intensity. Ideal for strength and athletic conditioning.',
    daysPerWeek: 4,
    scienceAdvantage:
        'Allows 48-72h recovery between upper and lower body sessions, preventing systemic fatigue in heavy lifters.',
    days: [
      WorkoutSplitDay(
        id: 'upper_a',
        name: 'Upper Body Heavy',
        muscleFocus: [MuscleGroup.chest, MuscleGroup.back, MuscleGroup.shoulders, MuscleGroup.biceps, MuscleGroup.triceps],
        exercises: [
          const ExercisePrescription(exerciseId: 'barbell_bench_press', targetSets: 4, targetReps: '5', restSeconds: 180),
          const ExercisePrescription(exerciseId: 'barbell_bent_row', targetSets: 4, targetReps: '5', restSeconds: 180),
          const ExercisePrescription(exerciseId: 'overhead_barbell_press', targetSets: 3, targetReps: '6-8', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'pull_ups', targetSets: 3, targetReps: '6-8', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'skull_crushers', targetSets: 3, targetReps: '8-10', restSeconds: 90),
        ],
      ),
      WorkoutSplitDay(
        id: 'lower_a',
        name: 'Lower Body Strength',
        muscleFocus: [MuscleGroup.quads, MuscleGroup.hamstrings, MuscleGroup.calves],
        exercises: [
          const ExercisePrescription(exerciseId: 'barbell_back_squat', targetSets: 4, targetReps: '5', restSeconds: 180),
          const ExercisePrescription(exerciseId: 'romanian_deadlift', targetSets: 3, targetReps: '6-8', restSeconds: 150),
          const ExercisePrescription(exerciseId: 'leg_press', targetSets: 3, targetReps: '8-10', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'standing_calf_raise', targetSets: 4, targetReps: '10-12', restSeconds: 60),
        ],
      ),
    ],
  ),

  // 3. Classic Bro Split (5 Day)
  WorkoutSplit(
    id: 'bro_split',
    name: 'Classic Bodybuilder Split (5-Day)',
    description: 'High volume per individual muscle group with maximum pump and metabolic stress.',
    daysPerWeek: 5,
    scienceAdvantage:
        'Delivers massive targeted volume per session, creating high localized muscle damage and metabolic accumulation.',
    days: [
      WorkoutSplitDay(
        id: 'bro_chest',
        name: 'Chest Destroyer',
        muscleFocus: [MuscleGroup.chest],
        exercises: [
          const ExercisePrescription(exerciseId: 'barbell_bench_press', targetSets: 4, targetReps: '8-10', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'incline_dumbbell_press', targetSets: 4, targetReps: '10-12', restSeconds: 90),
          const ExercisePrescription(exerciseId: 'cable_chest_fly', targetSets: 4, targetReps: '12-15', restSeconds: 60),
          const ExercisePrescription(exerciseId: 'chest_dips', targetSets: 3, targetReps: 'Bodyweight', restSeconds: 90),
        ],
      ),
      WorkoutSplitDay(
        id: 'bro_back',
        name: 'Back & Wings',
        muscleFocus: [MuscleGroup.back],
        exercises: [
          const ExercisePrescription(exerciseId: 'barbell_deadlift', targetSets: 4, targetReps: '5', restSeconds: 180),
          const ExercisePrescription(exerciseId: 'pull_ups', targetSets: 3, targetReps: '8-10', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'barbell_bent_row', targetSets: 3, targetReps: '8-10', restSeconds: 90),
          const ExercisePrescription(exerciseId: 'seated_cable_row', targetSets: 3, targetReps: '10-12', restSeconds: 90),
        ],
      ),
      WorkoutSplitDay(
        id: 'bro_shoulders',
        name: 'Boulder Shoulders & Traps',
        muscleFocus: [MuscleGroup.shoulders],
        exercises: [
          const ExercisePrescription(exerciseId: 'overhead_barbell_press', targetSets: 4, targetReps: '6-8', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'dumbbell_lateral_raise', targetSets: 5, targetReps: '12-15', restSeconds: 60),
          const ExercisePrescription(exerciseId: 'cable_face_pulls', targetSets: 4, targetReps: '15', restSeconds: 60),
        ],
      ),
      WorkoutSplitDay(
        id: 'bro_arms',
        name: 'Armageddon (Biceps & Triceps)',
        muscleFocus: [MuscleGroup.biceps, MuscleGroup.triceps],
        exercises: [
          const ExercisePrescription(exerciseId: 'barbell_bicep_curl', targetSets: 4, targetReps: '8-10', restSeconds: 75),
          const ExercisePrescription(exerciseId: 'incline_dumbbell_curl', targetSets: 3, targetReps: '10-12', restSeconds: 60),
          const ExercisePrescription(exerciseId: 'skull_crushers', targetSets: 4, targetReps: '8-10', restSeconds: 75),
          const ExercisePrescription(exerciseId: 'tricep_cable_pushdown', targetSets: 4, targetReps: '12-15', restSeconds: 60),
        ],
      ),
      WorkoutSplitDay(
        id: 'bro_legs',
        name: 'Leg Annihilation',
        muscleFocus: [MuscleGroup.quads, MuscleGroup.hamstrings, MuscleGroup.calves],
        exercises: [
          const ExercisePrescription(exerciseId: 'barbell_back_squat', targetSets: 4, targetReps: '8-10', restSeconds: 180),
          const ExercisePrescription(exerciseId: 'leg_press', targetSets: 4, targetReps: '10-12', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'romanian_deadlift', targetSets: 3, targetReps: '8-10', restSeconds: 120),
          const ExercisePrescription(exerciseId: 'leg_curl', targetSets: 4, targetReps: '12', restSeconds: 60),
          const ExercisePrescription(exerciseId: 'standing_calf_raise', targetSets: 4, targetReps: '15', restSeconds: 60),
        ],
      ),
    ],
  ),
];
