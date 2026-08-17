import 'package:hive_flutter/hive_flutter.dart';
import '../models/member_model.dart';
import '../models/fee_record_model.dart';

abstract class AdminLocalDataSource {
  Future<List<MemberModel>> getMembers();
  Future<void> saveMembers(List<MemberModel> members);
  Future<List<FeeRecordModel>> getFeeRecords();
  Future<void> saveFeeRecords(List<FeeRecordModel> records);
}

class AdminLocalDataSourceImpl implements AdminLocalDataSource {
  static const String membersBoxName = 'apex_members_box';
  static const String feesBoxName = 'apex_fees_box';

  Box get _membersBox => Hive.box(membersBoxName);
  Box get _feesBox => Hive.box(feesBoxName);

  @override
  Future<List<MemberModel>> getMembers() async {
    final raw = _membersBox.get('members_list');
    if (raw != null && raw is List) {
      return raw.map((item) => MemberModel.fromMap(Map<String, dynamic>.from(item))).toList();
    }
    return [];
  }

  @override
  Future<void> saveMembers(List<MemberModel> members) async {
    final mapped = members.map((m) => m.toMap()).toList();
    await _membersBox.put('members_list', mapped);
  }

  @override
  Future<List<FeeRecordModel>> getFeeRecords() async {
    final raw = _feesBox.get('fee_records_list');
    if (raw != null && raw is List) {
      return raw.map((item) => FeeRecordModel.fromMap(Map<String, dynamic>.from(item))).toList();
    }
    return [];
  }

  @override
  Future<void> saveFeeRecords(List<FeeRecordModel> records) async {
    final mapped = records.map((r) => r.toMap()).toList();
    await _feesBox.put('fee_records_list', mapped);
  }
}
