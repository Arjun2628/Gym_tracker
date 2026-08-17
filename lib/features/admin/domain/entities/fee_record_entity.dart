import 'package:intl/intl.dart';

/// Domain Entity for Fee Record
class FeeRecordEntity {
  final String id;
  final String memberId;
  final String memberName;
  final String monthYear; // 'YYYY-MM'
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status; // 'Paid', 'Pending', 'Overdue'
  final String? paymentMethod; // 'Cash', 'UPI / GPay', 'Card', 'Bank Transfer'
  final String? receiptNumber;
  final String? notes;

  const FeeRecordEntity({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.monthYear,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    this.status = 'Pending',
    this.paymentMethod,
    this.receiptNumber,
    this.notes,
  });

  bool get isPaid => status == 'Paid';
  bool get isPending => status == 'Pending';
  bool get isOverdue => status == 'Overdue';

  String get formattedDueDate => DateFormat('dd MMM yyyy').format(dueDate);
  String get formattedPaidDate => paidDate != null
      ? DateFormat('dd MMM yyyy, hh:mm a').format(paidDate!)
      : 'Not Paid';

  String get formattedMonth {
    try {
      final parts = monthYear.split('-');
      if (parts.length == 2) {
        final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        return DateFormat('MMMM yyyy').format(date);
      }
    } catch (_) {}
    return monthYear;
  }
}

/// Domain Entity for Grouped Monthly Fee Summary
class MonthlyFeeSummaryEntity {
  final String monthYear;
  final String monthLabel;
  final double totalExpected;
  final double totalCollected;
  final double totalPending;
  final int paidCount;
  final int pendingCount;
  final List<FeeRecordEntity> records;

  const MonthlyFeeSummaryEntity({
    required this.monthYear,
    required this.monthLabel,
    required this.totalExpected,
    required this.totalCollected,
    required this.totalPending,
    required this.paidCount,
    required this.pendingCount,
    required this.records,
  });

  double get collectionPercentage =>
      totalExpected > 0 ? (totalCollected / totalExpected) * 100 : 0.0;
}
