import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firebase_service.dart';
import '../models/member_model.dart';
import '../models/fee_record_model.dart';

abstract class AdminRemoteDataSource {
  Future<void> syncMember(MemberModel member);
  Future<void> deleteMember(String id);
  Future<void> syncFeeRecord(FeeRecordModel record);
  Future<List<MemberModel>> fetchMembers();
  Future<List<FeeRecordModel>> fetchFeeRecords();
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  @override
  Future<void> syncMember(MemberModel member) async {
    if (!FirebaseGymService.isFirebaseInitialized) {
      debugPrint('[Firestore Admin] Local fallback: Member ${member.name}');
      return;
    }
    try {
      await FirebaseGymService.db
          .collection('members')
          .doc(member.id)
          .set(member.toMap(), SetOptions(merge: true));
      debugPrint('[Firestore Admin] Synced member to Cloud: ${member.id} - ${member.name}');
    } catch (e) {
      debugPrint('[Firestore Admin Error] Sync member failed: $e');
    }
  }

  @override
  Future<void> deleteMember(String id) async {
    if (!FirebaseGymService.isFirebaseInitialized) return;
    try {
      await FirebaseGymService.db.collection('members').doc(id).delete();
      debugPrint('[Firestore Admin] Deleted member from Cloud: $id');
    } catch (e) {
      debugPrint('[Firestore Admin Error] Delete member failed: $e');
    }
  }

  @override
  Future<void> syncFeeRecord(FeeRecordModel record) async {
    if (!FirebaseGymService.isFirebaseInitialized) return;
    try {
      await FirebaseGymService.db
          .collection('fee_records')
          .doc(record.id)
          .set(record.toMap(), SetOptions(merge: true));
      debugPrint('[Firestore Admin] Synced fee record to Cloud: ${record.id}');
    } catch (e) {
      debugPrint('[Firestore Admin Error] Sync fee record failed: $e');
    }
  }

  @override
  Future<List<MemberModel>> fetchMembers() async {
    if (!FirebaseGymService.isFirebaseInitialized) return [];
    try {
      final snapshot = await FirebaseGymService.db.collection('members').get();
      return snapshot.docs.map((doc) => MemberModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('[Firestore Admin Error] Fetch members failed: $e');
      return [];
    }
  }

  @override
  Future<List<FeeRecordModel>> fetchFeeRecords() async {
    if (!FirebaseGymService.isFirebaseInitialized) return [];
    try {
      final snapshot = await FirebaseGymService.db.collection('fee_records').get();
      return snapshot.docs.map((doc) => FeeRecordModel.fromMap(doc.data())).toList();
    } catch (e) {
      debugPrint('[Firestore Admin Error] Fetch fee records failed: $e');
      return [];
    }
  }
}
