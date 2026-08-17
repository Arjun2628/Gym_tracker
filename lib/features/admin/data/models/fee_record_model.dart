import '../../domain/entities/fee_record_entity.dart';

class FeeRecordModel extends FeeRecordEntity {
  const FeeRecordModel({
    required super.id,
    required super.memberId,
    required super.memberName,
    required super.monthYear,
    required super.amount,
    required super.dueDate,
    super.paidDate,
    super.status = 'Pending',
    super.paymentMethod,
    super.receiptNumber,
    super.notes,
  });

  factory FeeRecordModel.fromEntity(FeeRecordEntity entity) {
    return FeeRecordModel(
      id: entity.id,
      memberId: entity.memberId,
      memberName: entity.memberName,
      monthYear: entity.monthYear,
      amount: entity.amount,
      dueDate: entity.dueDate,
      paidDate: entity.paidDate,
      status: entity.status,
      paymentMethod: entity.paymentMethod,
      receiptNumber: entity.receiptNumber,
      notes: entity.notes,
    );
  }

  factory FeeRecordModel.fromMap(Map<String, dynamic> map) {
    return FeeRecordModel(
      id: map['id'] ?? '',
      memberId: map['memberId'] ?? '',
      memberName: map['memberName'] ?? '',
      monthYear: map['monthYear'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 50.0,
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'])
          : DateTime.now(),
      paidDate:
          map['paidDate'] != null ? DateTime.parse(map['paidDate']) : null,
      status: map['status'] ?? 'Pending',
      paymentMethod: map['paymentMethod'],
      receiptNumber: map['receiptNumber'],
      notes: map['notes'],
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
}
