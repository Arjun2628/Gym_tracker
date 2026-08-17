import '../entities/workout_entities.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutSplitEntity>> getWorkoutSplits();
  Future<void> saveCustomSplit(WorkoutSplitEntity split);
  Future<List<CompletedWorkoutSessionEntity>> getCompletedSessions();
  Future<void> saveCompletedSession(CompletedWorkoutSessionEntity session);
}
