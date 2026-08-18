import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/nutrition_log.dart';
import '../models/growth_log.dart';
import '../models/workout_models.dart';
import '../models/member_model.dart';
import '../models/fee_model.dart';
import '../models/diet_model.dart';
import '../services/hive_service.dart';
import '../services/firebase_service.dart';

enum AppRole { admin, user }

class GymProvider extends ChangeNotifier {
  // Current Active Role
  AppRole _currentRole = AppRole.admin;

  // Admin Section State
  List<MemberModel> _members = [];
  List<FeeRecord> _feeRecords = [];
  MemberModel? _activeMember; // Active selected member when in user mode

  // User Section State
  UserProfile _profile = UserProfile();
  DailyNutritionLog _todayNutrition = DailyNutritionLog(dateKey: _getTodayKey());
  DietPlan _activeDiet = kPresetDietPlans.first;
  final List<DietPlan> _customDiets = [];
  List<BodyMeasurement> _measurements = [];
  List<WorkoutSplit> _splits = List.from(kPresetWorkoutSplits);
  WorkoutSplit _activeSplit = kPresetWorkoutSplits.first;
  final List<CompletedWorkoutSession> _completedSessions = [];

  // Active Live Workout Session State
  bool _isWorkoutActive = false;
  String _activeSessionSplitName = '';
  String _activeSessionDayName = '';
  DateTime? _activeSessionStartTime;
  List<SessionExerciseLog> _activeExercises = [];
  int _restTimerSecondsRemaining = 0;
  int _restTimerTotalSeconds = 90;
  bool _isRestTimerRunning = false;
  bool _isSyncingWithCloud = false;
  Timer? _restTimer;

  GymProvider() {
    _initData();
  }

  // --- GETTERS ---
  AppRole get currentRole => _currentRole;
  bool get isAdmin => _currentRole == AppRole.admin;
  bool get isUser => _currentRole == AppRole.user;
  bool get isSyncingWithCloud => _isSyncingWithCloud;

  List<MemberModel> get members => _members;
  List<FeeRecord> get feeRecords => _feeRecords;
  MemberModel? get activeMember => _activeMember ?? (_members.isNotEmpty ? _members.first : null);

  UserProfile get profile => _profile;
  DailyNutritionLog get todayNutrition => _todayNutrition;
  DietPlan get activeDiet => _activeDiet;
  List<DietPlan> get allDietPlans => [...kPresetDietPlans, ..._customDiets];
  List<BodyMeasurement> get measurements => _measurements;
  List<WorkoutSplit> get splits => _splits;
  WorkoutSplit get activeSplit => _activeSplit;
  List<CompletedWorkoutSession> get completedSessions => _completedSessions;

  bool get isWorkoutActive => _isWorkoutActive;
  String get activeSessionSplitName => _activeSessionSplitName;
  String get activeSessionDayName => _activeSessionDayName;
  DateTime? get activeSessionStartTime => _activeSessionStartTime;
  List<SessionExerciseLog> get activeExercises => _activeExercises;
  int get restTimerSecondsRemaining => _restTimerSecondsRemaining;
  int get restTimerTotalSeconds => _restTimerTotalSeconds;
  bool get isRestTimerRunning => _isRestTimerRunning;

  double get activeWorkoutTotalVolume =>
      _activeExercises.fold(0.0, (sum, ex) => sum + ex.totalExerciseVolume);

  int get activeWorkoutTotalSetsCompleted =>
      _activeExercises.fold(0, (sum, ex) => sum + ex.completedSetsCount);

  GrowthRateAnalysis get growthAnalysis =>
      GrowthRateAnalysis.fromLogs(_measurements, _profile.goal.name);

  // --- ROLE MANAGEMENT ---
  void setRole(AppRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void toggleRole() {
    _currentRole = _currentRole == AppRole.admin ? AppRole.user : AppRole.admin;
    notifyListeners();
  }

  void setActiveMember(String memberId) {
    _activeMember = _members.firstWhere(
      (m) => m.id == memberId,
      orElse: () => _members.first,
    );
    // Sync profile name to active member
    if (_activeMember != null) {
      _profile.name = _activeMember!.name;
      _profile.weightKg = _activeMember!.currentWeight;
    }
    notifyListeners();
  }

  // --- INITIALIZATION & PERSISTENCE ---

  static String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _initData() async {
    // 1. Initialize Hive storage
    await HiveGymService.init();

    // 2. Load Members from Hive or Seed
    _members = HiveGymService.getMembers();
    if (_members.isEmpty) {
      _members = HiveGymService.getSeedMembers();
      await HiveGymService.saveMembers(_members);
    }
    if (_members.isNotEmpty) {
      _activeMember = _members.first;
    }

    // 3. Load Fee Records from Hive or Seed
    _feeRecords = HiveGymService.getFeeRecords();
    if (_feeRecords.isEmpty) {
      _feeRecords = HiveGymService.getSeedFeeRecords(_members);
      await HiveGymService.saveFeeRecords(_feeRecords);
    }

    // 4. Load Active Diet Plan
    final savedDiet = HiveGymService.getActiveDiet();
    if (savedDiet != null) {
      _activeDiet = savedDiet;
    }

    // 5. Load Legacy SharedPreferences for backward compatibility
    final prefs = await SharedPreferences.getInstance();

    final profileJson = prefs.getString('user_profile');
    if (profileJson != null) {
      try {
        _profile = UserProfile.fromJson(profileJson);
      } catch (e) {
        debugPrint('Error loading profile: $e');
      }
    }

    final measurementsJson = prefs.getString('measurements_list');
    if (measurementsJson != null) {
      try {
        final list = json.decode(measurementsJson) as List<dynamic>;
        _measurements = list.map((m) => BodyMeasurement.fromMap(m)).toList();
      } catch (e) {
        debugPrint('Error loading measurements: $e');
      }
    }

    if (_measurements.isEmpty) {
      _seedSampleMeasurements();
    }

    final nutritionJson = prefs.getString('nutrition_${_getTodayKey()}');
    if (nutritionJson != null) {
      try {
        _todayNutrition = DailyNutritionLog.fromMap(json.decode(nutritionJson));
      } catch (e) {
        debugPrint('Error loading nutrition: $e');
      }
    } else {
      _seedSampleMealsForToday();
    }

    final splitsJson = prefs.getString('custom_splits');
    if (splitsJson != null) {
      try {
        final list = json.decode(splitsJson) as List<dynamic>;
        if (list.isNotEmpty) {
          _splits = list.map((s) => WorkoutSplit.fromMap(s)).toList();
        }
      } catch (e) {
        debugPrint('Error loading splits: $e');
      }
    }
    if (_splits.isNotEmpty) {
      _activeSplit = _splits.first;
    }

    notifyListeners();

    // Auto-sync all local members & fees to Cloud Firestore in the background
    unawaited(syncAllToCloud());
  }

  // --- ADMIN: MEMBER MANAGEMENT ---

  Future<void> addMember(MemberModel member) async {
    _members.insert(0, member);
    // Generate initial fee record for current month
    final now = DateTime.now();
    final currentMonthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final fee = FeeRecord(
      id: 'fee_${member.id}_$currentMonthYear',
      memberId: member.id,
      memberName: member.name,
      monthYear: currentMonthYear,
      amount: member.monthlyFee,
      dueDate: DateTime(now.year, now.month, member.dueDayOfMonth),
      status: 'Pending',
    );
    _feeRecords.insert(0, fee);

    notifyListeners();
    await HiveGymService.saveMembers(_members);
    await HiveGymService.saveFeeRecords(_feeRecords);
    await FirebaseGymService.syncMember(member);
    await FirebaseGymService.syncFeeRecord(fee);
  }

  Future<void> updateMember(MemberModel member) async {
    final index = _members.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      _members[index] = member;
      if (_activeMember?.id == member.id) {
        _activeMember = member;
      }
      notifyListeners();
      await HiveGymService.saveMembers(_members);
      await FirebaseGymService.syncMember(member);
    }
  }

  Future<void> deleteMember(String id) async {
    _members.removeWhere((m) => m.id == id);
    _feeRecords.removeWhere((f) => f.memberId == id);
    if (_activeMember?.id == id) {
      _activeMember = _members.isNotEmpty ? _members.first : null;
    }
    notifyListeners();
    await HiveGymService.saveMembers(_members);
    await HiveGymService.saveFeeRecords(_feeRecords);
    await FirebaseGymService.deleteMember(id);
  }

  Future<Map<String, int>> syncAllToCloud() async {
    _isSyncingWithCloud = true;
    notifyListeners();
    try {
      final result = await FirebaseGymService.syncAllMembersAndFees(_members, _feeRecords);
      return result;
    } finally {
      _isSyncingWithCloud = false;
      notifyListeners();
    }
  }

  // --- ADMIN: FEES & MONTHLY PENDING MANAGEMENT ---

  Future<void> recordFeePayment({
    required String feeId,
    required String paymentMethod,
    String? receiptNumber,
    String? notes,
  }) async {
    final index = _feeRecords.indexWhere((f) => f.id == feeId);
    if (index != -1) {
      final existing = _feeRecords[index];
      final updated = existing.copyWith(
        status: 'Paid',
        paidDate: DateTime.now(),
        paymentMethod: paymentMethod,
        receiptNumber: receiptNumber ?? 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        notes: notes,
      );
      _feeRecords[index] = updated;

      // Update member status if needed
      await _updateMemberFeeStatus(existing.memberId);

      notifyListeners();
      await HiveGymService.saveFeeRecords(_feeRecords);
      await FirebaseGymService.syncFeeRecord(updated);
    }
  }

  Future<void> _updateMemberFeeStatus(String memberId) async {
    final memberIndex = _members.indexWhere((m) => m.id == memberId);
    if (memberIndex != -1) {
      final memberDues = _feeRecords.where((f) => f.memberId == memberId && f.status != 'Paid').toList();
      final hasOverdue = memberDues.any((f) => f.status == 'Overdue');
      final newStatus = hasOverdue
          ? 'Overdue'
          : (memberDues.isNotEmpty ? 'Pending Fee' : 'Active');
      _members[memberIndex] = _members[memberIndex].copyWith(status: newStatus);
      await HiveGymService.saveMembers(_members);
      await FirebaseGymService.syncMember(_members[memberIndex]);
    }
  }

  // Group fees by month with analytics
  List<MonthlyFeeSummary> getMonthlyFeeSummaries() {
    final Map<String, List<FeeRecord>> grouped = {};
    for (final record in _feeRecords) {
      grouped.putIfAbsent(record.monthYear, () => []).add(record);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedKeys.map((my) {
      final list = grouped[my]!;
      final expected = list.fold(0.0, (sum, f) => sum + f.amount);
      final collected = list.where((f) => f.isPaid).fold(0.0, (sum, f) => sum + f.amount);
      final pending = list.where((f) => !f.isPaid).fold(0.0, (sum, f) => sum + f.amount);
      final paidCnt = list.where((f) => f.isPaid).length;
      final pendingCnt = list.where((f) => !f.isPaid).length;

      return MonthlyFeeSummary(
        monthYear: my,
        monthLabel: list.first.formattedMonth,
        totalExpected: expected,
        totalCollected: collected,
        totalPending: pending,
        paidCount: paidCnt,
        pendingCount: pendingCnt,
        records: list,
      );
    }).toList();
  }

  double get totalRevenueAllTime =>
      _feeRecords.where((f) => f.isPaid).fold(0.0, (sum, f) => sum + f.amount);

  double get totalPendingDuesAllTime =>
      _feeRecords.where((f) => !f.isPaid).fold(0.0, (sum, f) => sum + f.amount);

  int get totalDefaultersCount {
    final pendingMemberIds = _feeRecords.where((f) => !f.isPaid).map((f) => f.memberId).toSet();
    return pendingMemberIds.length;
  }

  // --- USER: DIET & NUTRITION CUSTOMIZATION ---

  Future<void> selectDietPlan(DietPlan plan) async {
    _activeDiet = plan;
    _profile.customDailyCalories = plan.targetCalories.toDouble();
    _profile.customDailyProteinG = plan.proteinGrams.toDouble();
    _profile.customDailyCarbsG = plan.carbsGrams.toDouble();
    _profile.customDailyFatG = plan.fatGrams.toDouble();
    notifyListeners();
    await HiveGymService.saveActiveDiet(plan);
    await updateProfile(_profile);
    if (_activeMember != null) {
      FirebaseGymService.syncUserDiet(_activeMember!.id, plan);
    }
  }

  Future<void> saveCustomDiet({
    required String title,
    required String tag,
    required String description,
    required int calories,
    required int protein,
    required int carbs,
    required int fat,
    required List<String> suggestions,
    required List<String> benefits,
  }) async {
    final custom = DietPlan(
      id: 'custom_diet_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      tag: tag,
      description: description,
      targetCalories: calories,
      proteinGrams: protein,
      carbsGrams: carbs,
      fatGrams: fat,
      mealSuggestions: suggestions,
      scientificBenefits: benefits,
      isCustom: true,
    );
    _customDiets.add(custom);
    await selectDietPlan(custom);
  }

  // --- PROFILE METHODS ---

  Future<void> updateProfile(UserProfile updated) async {
    _profile = updated;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', _profile.toJson());
    FirebaseGymService.syncUserProfile(_profile);
  }

  // --- NUTRITION METHODS ---

  Future<void> addFoodItem(FoodItem item) async {
    _todayNutrition.meals.add(item);
    notifyListeners();
    await _saveNutrition();
  }

  Future<void> removeFoodItem(String id) async {
    _todayNutrition.meals.removeWhere((m) => m.id == id);
    notifyListeners();
    await _saveNutrition();
  }

  Future<void> addQuickPreset(NutritionPreset preset) async {
    final item = FoodItem(
      id: 'food_${DateTime.now().millisecondsSinceEpoch}',
      name: preset.name,
      proteinG: preset.proteinG,
      carbsG: preset.carbsG,
      fatG: preset.fatG,
      calories: preset.calories,
      category: preset.defaultCategory,
      timestamp: DateTime.now(),
    );
    await addFoodItem(item);
  }

  Future<void> updateWater(int deltaMl) async {
    _todayNutrition.waterMl = (_todayNutrition.waterMl + deltaMl).clamp(0, 10000);
    notifyListeners();
    await _saveNutrition();
  }

  Future<void> _saveNutrition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'nutrition_${_todayNutrition.dateKey}',
      json.encode(_todayNutrition.toMap()),
    );
    FirebaseGymService.syncDailyNutrition(_todayNutrition);
  }

  // --- MEASUREMENT & GROWTH METHODS ---

  Future<void> logMeasurement(BodyMeasurement measurement) async {
    _measurements.add(measurement);
    _profile.weightKg = measurement.weightKg;
    if (_activeMember != null) {
      final idx = _members.indexWhere((m) => m.id == _activeMember!.id);
      if (idx != -1) {
        _members[idx] = _members[idx].copyWith(currentWeight: measurement.weightKg);
        await HiveGymService.saveMembers(_members);
        FirebaseGymService.syncMember(_members[idx]);
      }
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final list = _measurements.map((m) => m.toMap()).toList();
    await prefs.setString('measurements_list', json.encode(list));
    await prefs.setString('user_profile', _profile.toJson());
    FirebaseGymService.syncBodyMeasurement(measurement);
    FirebaseGymService.syncUserProfile(_profile);
  }

  Future<void> deleteMeasurement(String id) async {
    _measurements.removeWhere((m) => m.id == id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final list = _measurements.map((m) => m.toMap()).toList();
    await prefs.setString('measurements_list', json.encode(list));
    FirebaseGymService.deleteBodyMeasurement(id);
  }

  // --- WORKOUT SPLIT METHODS ---

  void setActiveSplit(WorkoutSplit split) {
    _activeSplit = split;
    notifyListeners();
  }

  Future<void> addCustomSplit(WorkoutSplit split) async {
    _splits.add(split);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final list = _splits.map((s) => s.toMap()).toList();
    await prefs.setString('custom_splits', json.encode(list));
  }

  // --- ACTIVE WORKOUT SESSION METHODS ---

  void startWorkoutSession({
    required String splitName,
    required WorkoutSplitDay day,
  }) {
    _isWorkoutActive = true;
    _activeSessionSplitName = splitName;
    _activeSessionDayName = day.name;
    _activeSessionStartTime = DateTime.now();

    _activeExercises = day.exercises.map((p) {
      final exercise = kGlobalExerciseLibrary.firstWhere(
        (e) => e.id == p.exerciseId,
        orElse: () => Exercise(
          id: p.exerciseId,
          name: p.exerciseId.replaceAll('_', ' ').toUpperCase(),
          primaryMuscle: MuscleGroup.chest,
          equipment: 'Gym',
          executionTip: 'Focus on proper form.',
        ),
      );

      final sets = List.generate(
        p.targetSets,
        (i) => WorkoutSet(
          setNumber: i + 1,
          weightKg: 0.0,
          reps: int.tryParse(p.targetReps.split('-').first) ?? 10,
          rpe: 8.0,
          isCompleted: false,
        ),
      );

      return SessionExerciseLog(exercise: exercise, sets: sets);
    }).toList();

    notifyListeners();
  }

  void addExerciseToActiveWorkout(Exercise exercise) {
    if (!_isWorkoutActive) return;
    _activeExercises.add(
      SessionExerciseLog(
        exercise: exercise,
        sets: [
          WorkoutSet(setNumber: 1, weightKg: 0.0, reps: 10, rpe: 8.0),
          WorkoutSet(setNumber: 2, weightKg: 0.0, reps: 10, rpe: 8.0),
          WorkoutSet(setNumber: 3, weightKg: 0.0, reps: 10, rpe: 8.0),
        ],
      ),
    );
    notifyListeners();
  }

  void addSetToExercise(int exerciseIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      final ex = _activeExercises[exerciseIndex];
      final newSetNumber = ex.sets.length + 1;
      final prevWeight = ex.sets.isNotEmpty ? ex.sets.last.weightKg : 0.0;
      final prevReps = ex.sets.isNotEmpty ? ex.sets.last.reps : 10;
      ex.sets.add(
        WorkoutSet(
          setNumber: newSetNumber,
          weightKg: prevWeight,
          reps: prevReps,
          rpe: 8.0,
        ),
      );
      notifyListeners();
    }
  }

  void removeSetFromExercise(int exerciseIndex, int setIndex) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      final ex = _activeExercises[exerciseIndex];
      if (setIndex >= 0 && setIndex < ex.sets.length) {
        ex.sets.removeAt(setIndex);
        for (int i = 0; i < ex.sets.length; i++) {
          ex.sets[i].setNumber = i + 1;
        }
        notifyListeners();
      }
    }
  }

  void toggleSetCompleted(int exerciseIndex, int setIndex, {int restSeconds = 90}) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      final set = _activeExercises[exerciseIndex].sets[setIndex];
      set.isCompleted = !set.isCompleted;

      if (set.isCompleted) {
        startRestTimer(restSeconds);
      }

      notifyListeners();
    }
  }

  void updateSetData(
    int exerciseIndex,
    int setIndex, {
    double? weightKg,
    int? reps,
    double? rpe,
  }) {
    if (exerciseIndex >= 0 && exerciseIndex < _activeExercises.length) {
      final set = _activeExercises[exerciseIndex].sets[setIndex];
      if (weightKg != null) set.weightKg = weightKg;
      if (reps != null) set.reps = reps;
      if (rpe != null) set.rpe = rpe;
      notifyListeners();
    }
  }

  // --- REST TIMER ---

  void startRestTimer(int seconds) {
    _restTimer?.cancel();
    _restTimerTotalSeconds = seconds;
    _restTimerSecondsRemaining = seconds;
    _isRestTimerRunning = true;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restTimerSecondsRemaining > 0) {
        _restTimerSecondsRemaining--;
        notifyListeners();
      } else {
        _isRestTimerRunning = false;
        _restTimer?.cancel();
        notifyListeners();
      }
    });
  }

  void stopRestTimer() {
    _restTimer?.cancel();
    _isRestTimerRunning = false;
    _restTimerSecondsRemaining = 0;
    notifyListeners();
  }

  void addRestTime(int seconds) {
    _restTimerSecondsRemaining += seconds;
    _restTimerTotalSeconds += seconds;
    notifyListeners();
  }

  // --- FINISH WORKOUT ---

  CompletedWorkoutSession? finishWorkoutSession() {
    if (!_isWorkoutActive || _activeSessionStartTime == null) return null;

    final now = DateTime.now();
    final duration = now.difference(_activeSessionStartTime!).inMinutes.clamp(1, 480);
    final totalVol = activeWorkoutTotalVolume;

    final session = CompletedWorkoutSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      splitName: _activeSessionSplitName,
      dayName: _activeSessionDayName,
      startTime: _activeSessionStartTime!,
      endTime: now,
      exercises: List.from(_activeExercises),
      totalVolumeKg: totalVol,
      durationMinutes: duration,
    );

    _completedSessions.insert(0, session);
    _isWorkoutActive = false;
    _activeExercises = [];
    _activeSessionStartTime = null;
    stopRestTimer();

    // Sync workout session to Cloud Firestore
    FirebaseGymService.syncWorkoutSession(session);

    // Increment member workouts completed
    if (_activeMember != null) {
      final idx = _members.indexWhere((m) => m.id == _activeMember!.id);
      if (idx != -1) {
        _members[idx] = _members[idx].copyWith(
          totalWorkoutsCompleted: _members[idx].totalWorkoutsCompleted + 1,
          attendanceStreak: _members[idx].attendanceStreak + 1,
        );
        HiveGymService.saveMembers(_members);
        FirebaseGymService.syncMember(_members[idx]);
      }
    }

    notifyListeners();
    return session;
  }

  void cancelActiveWorkout() {
    _isWorkoutActive = false;
    _activeExercises = [];
    _activeSessionStartTime = null;
    stopRestTimer();
    notifyListeners();
  }

  void _seedSampleMeasurements() {
    final now = DateTime.now();
    _measurements = [
      BodyMeasurement(
        id: 'm1',
        date: now.subtract(const Duration(days: 28)),
        weightKg: 73.2,
        bodyFatPct: 15.8,
        chestCm: 101.0,
        armsCm: 36.5,
        waistCm: 81.0,
        thighsCm: 56.5,
        notes: 'Initial body scan. Baseline week.',
      ),
      BodyMeasurement(
        id: 'm2',
        date: now.subtract(const Duration(days: 21)),
        weightKg: 73.6,
        bodyFatPct: 15.7,
        chestCm: 101.5,
        armsCm: 36.8,
        waistCm: 81.2,
        thighsCm: 56.8,
        notes: 'Week 1 surplus +300 kcal.',
      ),
      BodyMeasurement(
        id: 'm3',
        date: now.subtract(const Duration(days: 14)),
        weightKg: 74.1,
        bodyFatPct: 15.5,
        chestCm: 102.0,
        armsCm: 37.1,
        waistCm: 81.3,
        thighsCm: 57.2,
        notes: 'Steady strength gains on squat and bench.',
      ),
      BodyMeasurement(
        id: 'm4',
        date: now.subtract(const Duration(days: 7)),
        weightKg: 74.5,
        bodyFatPct: 15.4,
        chestCm: 102.8,
        armsCm: 37.4,
        waistCm: 81.5,
        thighsCm: 57.6,
        notes: 'Arms +0.3cm, waist stable.',
      ),
      BodyMeasurement(
        id: 'm5',
        date: now,
        weightKg: _profile.weightKg,
        bodyFatPct: 15.2,
        chestCm: 103.2,
        armsCm: 37.8,
        waistCm: 81.6,
        thighsCm: 58.0,
        notes: 'Current checkpoint. Feeling high energy.',
      ),
    ];
  }

  void _seedSampleMealsForToday() {
    final now = DateTime.now();
    _todayNutrition = DailyNutritionLog(
      dateKey: _getTodayKey(),
      waterMl: 2250,
      meals: [
        FoodItem(
          id: 'meal_1',
          name: '4 Whole Eggs & Oats with Honey',
          proteinG: 28.0,
          carbsG: 55.0,
          fatG: 22.0,
          calories: 520.0,
          category: MealCategory.breakfast,
          timestamp: DateTime(now.year, now.month, now.day, 8, 30),
        ),
        FoodItem(
          id: 'meal_2',
          name: 'Grilled Chicken Breast & Basmati Rice',
          proteinG: 54.0,
          carbsG: 65.0,
          fatG: 9.0,
          calories: 560.0,
          category: MealCategory.lunch,
          timestamp: DateTime(now.year, now.month, now.day, 13, 15),
        ),
        FoodItem(
          id: 'meal_3',
          name: 'Whey Protein Isolate with Banana',
          proteinG: 27.0,
          carbsG: 30.0,
          fatG: 2.0,
          calories: 250.0,
          category: MealCategory.postWorkout,
          timestamp: DateTime(now.year, now.month, now.day, 17, 45),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
}
