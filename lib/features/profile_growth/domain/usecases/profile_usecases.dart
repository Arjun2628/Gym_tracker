import '../entities/profile_growth_entities.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository repository;
  GetUserProfileUseCase(this.repository);

  Future<UserProfileEntity> call() => repository.getUserProfile();
}

class UpdateUserProfileUseCase {
  final ProfileRepository repository;
  UpdateUserProfileUseCase(this.repository);

  Future<void> call(UserProfileEntity profile) => repository.saveUserProfile(profile);
}

class GetMeasurementsUseCase {
  final ProfileRepository repository;
  GetMeasurementsUseCase(this.repository);

  Future<List<BodyMeasurementEntity>> call() => repository.getMeasurements();
}

class LogMeasurementUseCase {
  final ProfileRepository repository;
  LogMeasurementUseCase(this.repository);

  Future<List<BodyMeasurementEntity>> call(List<BodyMeasurementEntity> current, BodyMeasurementEntity measurement) async {
    final updated = List<BodyMeasurementEntity>.from(current)..add(measurement);
    await repository.saveMeasurements(updated);
    return updated;
  }
}

class DeleteMeasurementUseCase {
  final ProfileRepository repository;
  DeleteMeasurementUseCase(this.repository);

  Future<List<BodyMeasurementEntity>> call(List<BodyMeasurementEntity> current, String id) async {
    final updated = List<BodyMeasurementEntity>.from(current)..removeWhere((m) => m.id == id);
    await repository.saveMeasurements(updated);
    return updated;
  }
}
