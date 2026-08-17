import '../../features/admin/data/datasources/admin_local_datasource.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/member_repository_impl.dart';
import '../../features/admin/data/repositories/fee_repository_impl.dart';
import '../../features/admin/domain/repositories/member_repository.dart';
import '../../features/admin/domain/repositories/fee_repository.dart';
import '../../features/admin/domain/usecases/admin_usecases.dart';

import '../../features/nutrition/data/datasources/nutrition_local_datasource.dart';
import '../../features/nutrition/data/repositories/nutrition_repository_impl.dart';
import '../../features/nutrition/domain/repositories/nutrition_repository.dart';
import '../../features/nutrition/domain/usecases/nutrition_usecases.dart';

import '../../features/workout/data/datasources/workout_local_datasource.dart';

/// Clean Architecture Service Locator / DI Container
class ServiceLocator {
  static final ServiceLocator instance = ServiceLocator._internal();
  ServiceLocator._internal();

  // Admin Module
  late final AdminLocalDataSource adminLocalDataSource;
  late final AdminRemoteDataSource adminRemoteDataSource;
  late final MemberRepository memberRepository;
  late final FeeRepository feeRepository;
  late final GetMembersUseCase getMembersUseCase;
  late final AddMemberUseCase addMemberUseCase;
  late final UpdateMemberUseCase updateMemberUseCase;
  late final DeleteMemberUseCase deleteMemberUseCase;
  late final RecordFeePaymentUseCase recordFeePaymentUseCase;
  late final GetMonthlyFeeSummariesUseCase getMonthlyFeeSummariesUseCase;

  // Nutrition Module
  late final NutritionLocalDataSource nutritionLocalDataSource;
  late final NutritionRepository nutritionRepository;
  late final GetActiveDietUseCase getActiveDietUseCase;
  late final SelectDietPlanUseCase selectDietPlanUseCase;
  late final SaveCustomDietUseCase saveCustomDietUseCase;
  late final AddFoodItemUseCase addFoodItemUseCase;
  late final RemoveFoodItemUseCase removeFoodItemUseCase;
  late final UpdateWaterUseCase updateWaterUseCase;

  // Workout Module
  late final WorkoutLocalDataSource workoutLocalDataSource;

  void init() {
    // 1. Admin Data Sources & Repositories
    adminLocalDataSource = AdminLocalDataSourceImpl();
    adminRemoteDataSource = AdminRemoteDataSourceImpl();
    memberRepository = MemberRepositoryImpl(
      localDataSource: adminLocalDataSource,
      remoteDataSource: adminRemoteDataSource,
    );
    feeRepository = FeeRepositoryImpl(
      localDataSource: adminLocalDataSource,
      remoteDataSource: adminRemoteDataSource,
    );

    // Admin Use Cases
    getMembersUseCase = GetMembersUseCase(memberRepository);
    addMemberUseCase = AddMemberUseCase(memberRepository, feeRepository);
    updateMemberUseCase = UpdateMemberUseCase(memberRepository);
    deleteMemberUseCase = DeleteMemberUseCase(memberRepository);
    recordFeePaymentUseCase = RecordFeePaymentUseCase(feeRepository);
    getMonthlyFeeSummariesUseCase = GetMonthlyFeeSummariesUseCase(feeRepository);

    // 2. Nutrition Data Sources & Repositories
    nutritionLocalDataSource = NutritionLocalDataSourceImpl();
    nutritionRepository = NutritionRepositoryImpl(localDataSource: nutritionLocalDataSource);

    // Nutrition Use Cases
    getActiveDietUseCase = GetActiveDietUseCase(nutritionRepository);
    selectDietPlanUseCase = SelectDietPlanUseCase(nutritionRepository);
    saveCustomDietUseCase = SaveCustomDietUseCase(nutritionRepository);
    addFoodItemUseCase = AddFoodItemUseCase(nutritionRepository);
    removeFoodItemUseCase = RemoveFoodItemUseCase(nutritionRepository);
    updateWaterUseCase = UpdateWaterUseCase(nutritionRepository);

    // 3. Workout
    workoutLocalDataSource = WorkoutLocalDataSourceImpl();
  }
}

final sl = ServiceLocator.instance;
