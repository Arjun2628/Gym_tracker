import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../models/member_model.dart';
import '../models/fee_model.dart';
import '../models/diet_model.dart';
import '../models/workout_models.dart';
import '../models/nutrition_log.dart';
import '../models/growth_log.dart';
import '../models/user_profile.dart';

/// Firebase Firestore Full Database Service
/// Handles real-time cloud synchronization for all domain entities:
/// - Members & Membership Status (/members)
/// - Monthly Fee Records & Receipts (/fee_records)
/// - Workout Sessions & Exercise Logs (/workout_sessions)
/// - Diet Protocols & Custom Macro Plans (/user_diets)
/// - Daily Nutrition & Hydration Logs (/nutrition_logs)
/// - Bodyweight & Circumference Checkpoints (/body_measurements)
/// - User Profiles & Biomarker Blueprint (/user_profiles)
class FirebaseGymService {
  static bool _isFirebaseInitialized = false;
  static bool get isFirebaseInitialized => _isFirebaseInitialized;

  static FirebaseFirestore get db => _db;
  static FirebaseFirestore get _db {
    try {
      return FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'default');
    } catch (_) {
      return FirebaseFirestore.instance;
    }
  }

  /// Initialize Firebase credentials and Firestore bindings
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isFirebaseInitialized = true;
      debugPrint('[FirebaseGymService] Connected to Cloud Firestore: testproject-d7784');
    } catch (e) {
      _isFirebaseInitialized = false;
      debugPrint('[FirebaseGymService] Running in local Hive fallback mode: $e');
    }
  }

  // ==========================================
  // 1. MEMBERS COLLECTION (/members)
  // ==========================================

  static Future<bool> syncMember(MemberModel member) async {
    if (!_isFirebaseInitialized) {
      debugPrint('[Firestore Warning] Firebase is not initialized. Skipping cloud sync.');
      return false;
    }
    try {
      debugPrint('[Firestore] Syncing member: ${member.name} (${member.id}) to Cloud Firestore...');
      await _db
          .collection('members')
          .doc(member.id)
          .set(member.toMap(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 8));
      debugPrint('[Firestore SUCCESS] Member ${member.name} successfully saved to Firebase Firestore!');
      return true;
    } catch (e) {
      debugPrint('[Firestore ERROR] syncMember failed or timed out: $e');
      debugPrint('[Firestore Tip] Check Firebase Console > Firestore Database > Rules and verify database is created in test mode.');
      return false;
    }
  }

  static Future<void> deleteMember(String memberId) async {
    if (!_isFirebaseInitialized) return;
    try {
      debugPrint('[Firestore] Deleting member: $memberId');
      await _db.collection('members').doc(memberId).delete();
    } catch (e) {
      debugPrint('[Firestore Error] deleteMember failed: $e');
    }
  }

  static Future<List<MemberModel>> fetchMembers() async {
    if (!_isFirebaseInitialized) return [];
    try {
      final snapshot = await _db.collection('members').get();
      return snapshot.docs.map((doc) => MemberModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('[Firestore Error] fetchMembers failed: $e');
      return [];
    }
  }

  static Stream<List<MemberModel>> streamMembers() {
    if (!_isFirebaseInitialized) return const Stream.empty();
    return _db.collection('members').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MemberModel.fromMap(doc.data())).toList();
    });
  }

  // ==========================================
  // 2. FEE RECORDS COLLECTION (/fee_records)
  // ==========================================

  static Future<bool> syncFeeRecord(FeeRecord fee) async {
    if (!_isFirebaseInitialized) return false;
    try {
      debugPrint('[Firestore] Syncing fee: ${fee.id} for ${fee.memberName}...');
      await _db
          .collection('fee_records')
          .doc(fee.id)
          .set(fee.toMap(), SetOptions(merge: true))
          .timeout(const Duration(seconds: 8));
      debugPrint('[Firestore SUCCESS] Fee record ${fee.id} saved to Cloud Firestore!');
      return true;
    } catch (e) {
      debugPrint('[Firestore ERROR] syncFeeRecord failed or timed out: $e');
      return false;
    }
  }

  static Future<List<FeeRecord>> fetchFeeRecords() async {
    if (!_isFirebaseInitialized) return [];
    try {
      final snapshot = await _db.collection('fee_records').get();
      return snapshot.docs.map((doc) => FeeRecord.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('[Firestore Error] fetchFeeRecords failed: $e');
      return [];
    }
  }

  static Stream<List<FeeRecord>> streamFeeRecords() {
    if (!_isFirebaseInitialized) return const Stream.empty();
    return _db.collection('fee_records').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FeeRecord.fromMap(doc.data())).toList();
    });
  }

  /// Bulk upload all local Hive members & fee records to Cloud Firestore
  static Future<Map<String, int>> syncAllMembersAndFees(
      List<MemberModel> members, List<FeeRecord> fees) async {
    if (!_isFirebaseInitialized) return {'members': 0, 'fees': 0};
    int syncedMembers = 0;
    int syncedFees = 0;

    for (final member in members) {
      final ok = await syncMember(member);
      if (ok) syncedMembers++;
    }

    for (final fee in fees) {
      final ok = await syncFeeRecord(fee);
      if (ok) syncedFees++;
    }

    debugPrint('[Firestore BULK SYNC] Uploaded $syncedMembers/${members.length} members and $syncedFees/${fees.length} fees to Firestore.');
    return {'members': syncedMembers, 'fees': syncedFees};
  }

  // ==========================================
  // 3. WORKOUT SESSIONS (/workout_sessions)
  // ==========================================

  static Future<void> syncWorkoutSession(CompletedWorkoutSession session) async {
    if (!_isFirebaseInitialized) return;
    try {
      debugPrint('[Firestore] Syncing workout session: ${session.id} (${session.splitName})');
      await _db.collection('workout_sessions').doc(session.id).set(session.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Firestore Error] syncWorkoutSession failed: $e');
    }
  }

  static Future<List<CompletedWorkoutSession>> fetchWorkoutSessions() async {
    if (!_isFirebaseInitialized) return [];
    try {
      final snapshot = await _db.collection('workout_sessions').orderBy('startTime', descending: true).get();
      return snapshot.docs.map((doc) => CompletedWorkoutSession.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('[Firestore Error] fetchWorkoutSessions failed: $e');
      return [];
    }
  }

  // ==========================================
  // 4. DIET PLANS COLLECTION (/user_diets)
  // ==========================================

  static Future<void> syncUserDiet(String userId, DietPlan diet) async {
    if (!_isFirebaseInitialized) return;
    try {
      debugPrint('[Firestore] Syncing diet ${diet.title} for user $userId');
      await _db.collection('user_diets').doc('${userId}_${diet.id}').set({
        'userId': userId,
        ...diet.toMap(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Firestore Error] syncUserDiet failed: $e');
    }
  }

  static Future<List<DietPlan>> fetchUserDiets(String userId) async {
    if (!_isFirebaseInitialized) return [];
    try {
      final snapshot = await _db.collection('user_diets').where('userId', isEqualTo: userId).get();
      return snapshot.docs.map((doc) => DietPlan.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('[Firestore Error] fetchUserDiets failed: $e');
      return [];
    }
  }

  // ==========================================
  // 5. DAILY NUTRITION LOGS (/nutrition_logs)
  // ==========================================

  static Future<void> syncDailyNutrition(DailyNutritionLog log) async {
    if (!_isFirebaseInitialized) return;
    try {
      debugPrint('[Firestore] Syncing nutrition log for date: ${log.dateKey}');
      await _db.collection('nutrition_logs').doc(log.dateKey).set(log.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Firestore Error] syncDailyNutrition failed: $e');
    }
  }

  static Future<DailyNutritionLog?> fetchDailyNutrition(String dateKey) async {
    if (!_isFirebaseInitialized) return null;
    try {
      final doc = await _db.collection('nutrition_logs').doc(dateKey).get();
      if (doc.exists && doc.data() != null) {
        return DailyNutritionLog.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('[Firestore Error] fetchDailyNutrition failed: $e');
    }
    return null;
  }

  // ==========================================
  // 6. BODY MEASUREMENTS (/body_measurements)
  // ==========================================

  static Future<void> syncBodyMeasurement(BodyMeasurement measurement) async {
    if (!_isFirebaseInitialized) return;
    try {
      debugPrint('[Firestore] Syncing body checkpoint: ${measurement.id} (${measurement.weightKg} kg)');
      await _db.collection('body_measurements').doc(measurement.id).set(measurement.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Firestore Error] syncBodyMeasurement failed: $e');
    }
  }

  static Future<void> deleteBodyMeasurement(String measurementId) async {
    if (!_isFirebaseInitialized) return;
    try {
      await _db.collection('body_measurements').doc(measurementId).delete();
    } catch (e) {
      debugPrint('[Firestore Error] deleteBodyMeasurement failed: $e');
    }
  }

  static Future<List<BodyMeasurement>> fetchBodyMeasurements() async {
    if (!_isFirebaseInitialized) return [];
    try {
      final snapshot = await _db.collection('body_measurements').orderBy('date', descending: true).get();
      return snapshot.docs.map((doc) => BodyMeasurement.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('[Firestore Error] fetchBodyMeasurements failed: $e');
      return [];
    }
  }

  // ==========================================
  // 7. USER PROFILE (/user_profiles)
  // ==========================================

  static Future<void> syncUserProfile(UserProfile profile) async {
    if (!_isFirebaseInitialized) return;
    try {
      debugPrint('[Firestore] Syncing user profile: ${profile.name}');
      await _db.collection('user_profiles').doc('active_athlete_profile').set(profile.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[Firestore Error] syncUserProfile failed: $e');
    }
  }

  static Future<UserProfile?> fetchUserProfile() async {
    if (!_isFirebaseInitialized) return null;
    try {
      final doc = await _db.collection('user_profiles').doc('active_athlete_profile').get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('[Firestore Error] fetchUserProfile failed: $e');
    }
    return null;
  }
}
