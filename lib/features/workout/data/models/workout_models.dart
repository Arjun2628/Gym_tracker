import '../../domain/entities/workout_entities.dart';

class WorkoutSetModel extends WorkoutSetEntity {
  WorkoutSetModel({
    required super.setNumber,
    required super.weightKg,
    required super.reps,
    super.rpe = 8.0,
    super.isCompleted = false,
  });

  factory WorkoutSetModel.fromEntity(WorkoutSetEntity entity) {
    return WorkoutSetModel(
      setNumber: entity.setNumber,
      weightKg: entity.weightKg,
      reps: entity.reps,
      rpe: entity.rpe,
      isCompleted: entity.isCompleted,
    );
  }

  factory WorkoutSetModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSetModel(
      setNumber: map['setNumber'] ?? 1,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 0.0,
      reps: map['reps'] ?? 0,
      rpe: (map['rpe'] as num?)?.toDouble() ?? 8.0,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'setNumber': setNumber,
      'weightKg': weightKg,
      'reps': reps,
      'rpe': rpe,
      'isCompleted': isCompleted,
    };
  }
}

class ExerciseModel extends ExerciseEntity {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.primaryMuscle,
    required super.equipment,
    required super.executionTip,
  });

  factory ExerciseModel.fromEntity(ExerciseEntity entity) {
    return ExerciseModel(
      id: entity.id,
      name: entity.name,
      primaryMuscle: entity.primaryMuscle,
      equipment: entity.equipment,
      executionTip: entity.executionTip,
    );
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      primaryMuscle: MuscleGroupEntity.values.firstWhere(
        (m) => m.name == map['primaryMuscle'],
        orElse: () => MuscleGroupEntity.chest,
      ),
      equipment: map['equipment'] ?? '',
      executionTip: map['executionTip'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'primaryMuscle': primaryMuscle.name,
      'equipment': equipment,
      'executionTip': executionTip,
    };
  }
}
