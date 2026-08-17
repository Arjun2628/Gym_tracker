import 'package:intl/intl.dart';
import '../../domain/entities/fee_record_entity.dart';
import '../../domain/repositories/fee_repository.dart';
import '../datasources/admin_local_datasource.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/fee_record_model.dart';

class FeeRepositoryImpl implements FeeRepository {
  final AdminLocalDataSource localDataSource;
  final AdminRemoteDataSource remoteDataSource;

  FeeRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<FeeRecordEntity>> getFeeRecords() async {
    return localDataSource.getFeeRecords();
  }

  @override
  Future<void> addFeeRecord(FeeRecordEntity fee) async {
    final model = FeeRecordModel.fromEntity(fee);
    final current = await localDataSource.getFeeRecords();
    final updated = List<FeeRecordModel>.from(current)..add(model);
    await localDataSource.saveFeeRecords(updated);
    await remoteDataSource.syncFeeRecord(model);
  }

  @override
  Future<void> recordFeePayment({
    required String feeId,
    required String paymentMethod,
    String? receiptNumber,
    String? notes,
  }) async {
    final current = await localDataSource.getFeeRecords();
    final idx = current.indexWhere((f) => f.id == feeId);
    if (idx >= 0) {
      final old = current[idx];
      final receipt = receiptNumber ??
          'REC-${DateTime.now().year}-${(1000 + idx).toString().padLeft(4, '0')}';
      final updated = FeeRecordModel(
        id: old.id,
        memberId: old.memberId,
        memberName: old.memberName,
        monthYear: old.monthYear,
        amount: old.amount,
        dueDate: old.dueDate,
        paidDate: DateTime.now(),
        status: 'Paid',
        paymentMethod: paymentMethod,
        receiptNumber: receipt,
        notes: notes ?? old.notes,
      );
      current[idx] = updated;
      await localDataSource.saveFeeRecords(current);
      await remoteDataSource.syncFeeRecord(updated);
    }
  }

  @override
  Future<List<MonthlyFeeSummaryEntity>> getMonthlyFeeSummaries() async {
    final records = await localDataSource.getFeeRecords();
    final Map<String, List<FeeRecordEntity>> grouped = {};

    for (final r in records) {
      grouped.putIfAbsent(r.monthYear, () => []).add(r);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedKeys.map((k) {
      final list = grouped[k]!;
      final expected = list.fold(0.0, (sum, item) => sum + item.amount);
      final collected = list
          .where((i) => i.isPaid)
          .fold(0.0, (sum, item) => sum + item.amount);
      final pending = expected - collected;
      final paidCount = list.where((i) => i.isPaid).length;
      final pendingCount = list.where((i) => !i.isPaid).length;

      String label = k;
      try {
        final parts = k.split('-');
        if (parts.length == 2) {
          final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
          label = DateFormat('MMMM yyyy').format(dt);
        }
      } catch (_) {}

      return MonthlyFeeSummaryEntity(
        monthYear: k,
        monthLabel: label,
        totalExpected: expected,
        totalCollected: collected,
        totalPending: pending,
        paidCount: paidCount,
        pendingCount: pendingCount,
        records: list,
      );
    }).toList();
  }

  @override
  Future<List<FeeRecordEntity>> getMemberFeeHistory(String memberId) async {
    final records = await localDataSource.getFeeRecords();
    return records.where((r) => r.memberId == memberId).toList();
  }
}
