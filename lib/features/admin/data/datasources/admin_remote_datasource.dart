import 'package:flutter/foundation.dart';
import '../models/member_model.dart';
import '../models/fee_record_model.dart';

abstract class AdminRemoteDataSource {
  Future<void> syncMember(MemberModel member);
  Future<void> deleteMember(String id);
  Future<void> syncFeeRecord(FeeRecordModel record);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  @override
  Future<void> syncMember(MemberModel member) async {
    debugPrint('[Firestore Admin] Synced member: ${member.id} - ${member.name}');
  }

  @override
  Future<void> deleteMember(String id) async {
    debugPrint('[Firestore Admin] Deleted member: $id');
  }

  @override
  Future<void> syncFeeRecord(FeeRecordModel record) async {
    debugPrint('[Firestore Admin] Synced fee record: ${record.id} - ${record.status}');
  }
}
