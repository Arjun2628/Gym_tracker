enum MuscleGroupEntity {
  chest('Chest (Pectorals)', 'Push'),
  back('Back (Lats & Traps)', 'Pull'),
  shoulders('Deltoids', 'Push'),
  quadriceps('Quadriceps', 'Legs'),
  hamstrings('Hamstrings', 'Legs'),
  glutes('Glutes', 'Legs'),
  biceps('Biceps', 'Pull'),
  triceps('Triceps', 'Push'),
  core('Abdominals & Core', 'Core'),
  calves('Calves', 'Legs');

  final String label;
  final String category;
  const MuscleGroupEntity(this.label, this.category);
}

class ExerciseEntity {
  final String id;
  final String name;
  final MuscleGroupEntity primaryMuscle;
  final String equipment;
  final String executionTip;

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.equipment,
    required this.executionTip,
  });
}

class WorkoutSetEntity {
  int setNumber;
  double weightKg;
  int reps;
  double rpe;
  bool isCompleted;

  WorkoutSetEntity({
    required this.setNumber,
    required this.weightKg,
    required this.reps,
    this.rpe = 8.0,
    this.isCompleted = false,
  });

  double get volume => weightKg * reps;
}

class SessionExerciseLogEntity {
  final ExerciseEntity exercise;
  final List<WorkoutSetEntity> sets;

  SessionExerciseLogEntity({
    required this.exercise,
    required this.sets,
  });

  double get totalExerciseVolume =>
      sets.where((s) => s.isCompleted).fold(0.0, (sum, s) => sum + s.volume);

  int get completedSetsCount => sets.where((s) => s.isCompleted).length;
}

class WorkoutDayExerciseEntity {
  final String exerciseId;
  final int targetSets;
  final String targetReps;
  final int targetRestSeconds;

  const WorkoutDayExerciseEntity({
    required this.exerciseId,
    required this.targetSets,
    required this.targetReps,
    this.targetRestSeconds = 90,
  });
}

class WorkoutSplitDayEntity {
  final String id;
  final String name;
  final List<WorkoutDayExerciseEntity> exercises;

  const WorkoutSplitDayEntity({
    required this.id,
    required this.name,
    required this.exercises,
  });
}

class WorkoutSplitEntity {
  final String id;
  final String name;
  final String frequency;
  final String description;
  final List<WorkoutSplitDayEntity> days;

  const WorkoutSplitEntity({
    required this.id,
    required this.name,
    required this.frequency,
    required this.description,
    required this.days,
  });
}

class CompletedWorkoutSessionEntity {
  final String id;
  final String splitName;
  final String dayName;
  final DateTime startTime;
  final DateTime endTime;
  final List<SessionExerciseLogEntity> exercises;
  final double totalVolumeKg;
  final int durationMinutes;

  const CompletedWorkoutSessionEntity({
    required this.id,
    required this.splitName,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.exercises,
    required this.totalVolumeKg,
    required this.durationMinutes,
  });
}
