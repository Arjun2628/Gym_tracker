import '../entities/fee_record_entity.dart';

abstract class FeeRepository {
  Future<List<FeeRecordEntity>> getFeeRecords();
  Future<void> recordFeePayment({
    required String feeId,
    required String paymentMethod,
    String? receiptNumber,
    String? notes,
  });
  Future<void> addFeeRecord(FeeRecordEntity fee);
  Future<List<MonthlyFeeSummaryEntity>> getMonthlyFeeSummaries();
  Future<List<FeeRecordEntity>> getMemberFeeHistory(String memberId);
}
