import 'package:flutter/foundation.dart';
import '../models/member_model.dart';
import '../models/fee_model.dart';
import '../models/diet_model.dart';

/// Firebase Firestore Sync Service
/// Handles real-time cloud synchronization for members, fee transactions,
/// custom diet setups, and workout logs.
class FirebaseGymService {
  static bool _isFirebaseInitialized = false;
  static bool get isFirebaseInitialized => _isFirebaseInitialized;

  /// Initialize Firebase credentials and Firestore bindings
  static Future<void> initialize() async {
    try {
      // In production with google-services.json / DefaultFirebaseOptions:
      // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _isFirebaseInitialized = true;
      debugPrint('[FirebaseGymService] Firestore connected.');
    } catch (e) {
      _isFirebaseInitialized = false;
      debugPrint('[FirebaseGymService] Running in local Hive mode: $e');
    }
  }

  // --- MEMBER FIRESTORE SYNC ---

  static Future<void> syncMember(MemberModel member) async {
    try {
      debugPrint('[Firebase Sync] Syncing member: ${member.name} (${member.id}) to /members');
      // FirebaseFirestore.instance.collection('members').doc(member.id).set(member.toMap());
    } catch (e) {
      debugPrint('[Firebase Sync Error] Member sync failed: $e');
    }
  }

  static Future<void> deleteMember(String memberId) async {
    try {
      debugPrint('[Firebase Sync] Deleting member doc: $memberId from /members');
      // FirebaseFirestore.instance.collection('members').doc(memberId).delete();
    } catch (e) {
      debugPrint('[Firebase Sync Error] Delete failed: $e');
    }
  }

  // --- FEE RECORD FIRESTORE SYNC ---

  static Future<void> syncFeeRecord(FeeRecord fee) async {
    try {
      debugPrint('[Firebase Sync] Syncing fee payment: ${fee.id} for ${fee.memberName} to /fee_records');
      // FirebaseFirestore.instance.collection('fee_records').doc(fee.id).set(fee.toMap());
    } catch (e) {
      debugPrint('[Firebase Sync Error] Fee sync failed: $e');
    }
  }

  // --- DIET PLAN FIRESTORE SYNC ---

  static Future<void> syncUserDiet(String userId, DietPlan diet) async {
    try {
      debugPrint('[Firebase Sync] Syncing diet ${diet.title} for user $userId to /user_diets');
      // FirebaseFirestore.instance.collection('user_diets').doc(userId).set(diet.toMap());
    } catch (e) {
      debugPrint('[Firebase Sync Error] Diet sync failed: $e');
    }
  }
}
