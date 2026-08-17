import '../entities/workout_entities.dart';
import '../repositories/workout_repository.dart';

class GetWorkoutSplitsUseCase {
  final WorkoutRepository repository;
  GetWorkoutSplitsUseCase(this.repository);

  Future<List<WorkoutSplitEntity>> call() => repository.getWorkoutSplits();
}

class SaveCustomSplitUseCase {
  final WorkoutRepository repository;
  SaveCustomSplitUseCase(this.repository);

  Future<void> call(WorkoutSplitEntity split) => repository.saveCustomSplit(split);
}

class GetCompletedSessionsUseCase {
  final WorkoutRepository repository;
  GetCompletedSessionsUseCase(this.repository);

  Future<List<CompletedWorkoutSessionEntity>> call() => repository.getCompletedSessions();
}

class SaveCompletedSessionUseCase {
  final WorkoutRepository repository;
  SaveCompletedSessionUseCase(this.repository);

  Future<void> call(CompletedWorkoutSessionEntity session) =>
      repository.saveCompletedSession(session);
}
