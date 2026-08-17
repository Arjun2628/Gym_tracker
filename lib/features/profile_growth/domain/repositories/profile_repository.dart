import '../entities/profile_growth_entities.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getUserProfile();
  Future<void> saveUserProfile(UserProfileEntity profile);
  Future<List<BodyMeasurementEntity>> getMeasurements();
  Future<void> saveMeasurements(List<BodyMeasurementEntity> measurements);
}
