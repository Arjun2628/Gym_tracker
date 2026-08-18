import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
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
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isFirebaseInitialized = true;
      debugPrint('[FirebaseGymService] Connected to Firebase Project: testproject-d7784');
    } catch (e) {
      _isFirebaseInitialized = false;
      debugPrint('[FirebaseGymService] Running in local Hive fallback mode: $e');
    }
  }

  // --- MEMBER FIRESTORE SYNC ---

  static Future<void> syncMember(MemberModel member) async {
    if (!_isFirebaseInitialized) return;
    try {
      debugPrint('[Firebase Sync] Syncing member: ${member.name} (${member.id}) to /members');
      await FirebaseFirestore.instance.collection('members').doc(member.id).set(member.toMap());
    } catch (e) {
      debugPrint('[Firebase Sync Error] Member sync failed: $e');
    }
  }

  static Future<void> deleteMember(String memberId) async {
    if (!_isFirebaseInitialized) return;
    try {
      debugPrint('[Firebase Sync] Deleting member doc: $memberId from /members');
      await FirebaseFirestore.instance.collection('members').doc(memberId).delete();
    } catch (e) {
      debugPrint('[Firebase Sync Error] Delete failed: $e');
    }
  }

  // --- FEE RECORD FIRESTORE SYNC ---

  static Future<void> syncFeeRecord(FeeRecord fee) async {
    if (!_isFirebaseInitialized) return;
    try {
      debugPrint('[Firebase Sync] Syncing fee payment: ${fee.id} for ${fee.memberName} to /fee_records');
      await FirebaseFirestore.instance.collection('fee_records').doc(fee.id).set(fee.toMap());
    } catch (e) {
      debugPrint('[Firebase Sync Error] Fee sync failed: $e');
    }
  }

  // --- DIET PLAN FIRESTORE SYNC ---

  static Future<void> syncUserDiet(String userId, DietPlan diet) async {
    if (!_isFirebaseInitialized) return;
    try {
      debugPrint('[Firebase Sync] Syncing diet ${diet.title} for user $userId to /user_diets');
      await FirebaseFirestore.instance.collection('user_diets').doc(userId).set(diet.toMap());
    } catch (e) {
      debugPrint('[Firebase Sync Error] Diet sync failed: $e');
    }
  }
}
