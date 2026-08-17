import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/workout_entities.dart';

abstract class WorkoutLocalDataSource {
  Future<List<WorkoutSplitEntity>> getCustomSplits();
  Future<void> saveCustomSplit(WorkoutSplitEntity split);
  Future<List<CompletedWorkoutSessionEntity>> getCompletedSessions();
  Future<void> saveCompletedSession(CompletedWorkoutSessionEntity session);
}

class WorkoutLocalDataSourceImpl implements WorkoutLocalDataSource {
  static const String workoutsBoxName = 'apex_workouts_box';
  Box get _box => Hive.box(workoutsBoxName);

  @override
  Future<List<WorkoutSplitEntity>> getCustomSplits() async {
    final raw = _box.get('custom_splits');
    if (raw != null && raw is List) {
      // Return custom splits if present
    }
    return [];
  }

  @override
  Future<void> saveCustomSplit(WorkoutSplitEntity split) async {
    final current = await getCustomSplits();
    final updated = List<WorkoutSplitEntity>.from(current)..add(split);
    await _box.put('custom_splits', updated.map((s) => s.id).toList());
  }

  @override
  Future<List<CompletedWorkoutSessionEntity>> getCompletedSessions() async {
    final raw = _box.get('completed_sessions');
    if (raw != null && raw is List) {
      // Return completed sessions
    }
    return [];
  }

  @override
  Future<void> saveCompletedSession(CompletedWorkoutSessionEntity session) async {
    final current = await getCompletedSessions();
    final updated = List<CompletedWorkoutSessionEntity>.from(current)..add(session);
    await _box.put('completed_sessions', updated.map((s) => s.id).toList());
  }
}
