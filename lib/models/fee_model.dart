import 'dart:convert';
import 'package:intl/intl.dart';

class FeeRecord {
  final String id;
  final String memberId;
  final String memberName;
  final String monthYear; // '2026-08'
  final double amount;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String status; // 'Paid', 'Pending', 'Overdue'
  final String? paymentMethod; // 'Cash', 'UPI / GPay', 'Card', 'Bank Transfer'
  final String? receiptNumber;
  final String? notes;

  FeeRecord({
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
  String get formattedPaidDate => paidDate != null ? DateFormat('dd MMM yyyy, hh:mm a').format(paidDate!) : 'Not Paid';

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

  FeeRecord copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? monthYear,
    double? amount,
    DateTime? dueDate,
    DateTime? paidDate,
    String? status,
    String? paymentMethod,
    String? receiptNumber,
    String? notes,
  }) {
    return FeeRecord(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      monthYear: monthYear ?? this.monthYear,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paidDate: paidDate ?? this.paidDate,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'memberName': memberName,
      'monthYear': monthYear,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status,
      'paymentMethod': paymentMethod,
      'receiptNumber': receiptNumber,
      'notes': notes,
    };
  }

  factory FeeRecord.fromMap(Map<String, dynamic> map) {
    return FeeRecord(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      monthYear: map['monthYear'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: map['dueDate'] != null ? DateTime.tryParse(map['dueDate']) ?? DateTime.now() : DateTime.now(),
      paidDate: map['paidDate'] != null ? DateTime.tryParse(map['paidDate']) : null,
      status: map['status'] ?? 'Pending',
      paymentMethod: map['paymentMethod'],
      receiptNumber: map['receiptNumber'],
      notes: map['notes'],
    );
  }

  String toJson() => json.encode(toMap());
  factory FeeRecord.fromJson(String source) => FeeRecord.fromMap(json.decode(source));
}

class MonthlyFeeSummary {
  final String monthYear;
  final String monthLabel;
  final double totalExpected;
  final double totalCollected;
  final double totalPending;
  final int paidCount;
  final int pendingCount;
  final List<FeeRecord> records;

  MonthlyFeeSummary({
    required this.monthYear,
    required this.monthLabel,
    required this.totalExpected,
    required this.totalCollected,
    required this.totalPending,
    required this.paidCount,
    required this.pendingCount,
    required this.records,
  });

  double get collectionPercentage => totalExpected > 0 ? (totalCollected / totalExpected) * 100 : 0.0;
}
