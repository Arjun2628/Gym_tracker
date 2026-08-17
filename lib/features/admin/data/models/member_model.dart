import '../../domain/entities/member_entity.dart';

class MemberModel extends MemberEntity {
  const MemberModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    super.gender = 'Male',
    super.age = 25,
    super.planType = 'Monthly',
    super.monthlyFee = 50.0,
    super.dueDayOfMonth = 5,
    required super.joinDate,
    super.status = 'Active',
    super.assignedDietId,
    super.assignedSplitId,
    super.emergencyContact,
    super.notes,
    super.currentWeight = 75.0,
    super.attendanceStreak = 0,
    super.totalWorkoutsCompleted = 0,
  });

  factory MemberModel.fromEntity(MemberEntity entity) {
    return MemberModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      gender: entity.gender,
      age: entity.age,
      planType: entity.planType,
      monthlyFee: entity.monthlyFee,
      dueDayOfMonth: entity.dueDayOfMonth,
      joinDate: entity.joinDate,
      status: entity.status,
      assignedDietId: entity.assignedDietId,
      assignedSplitId: entity.assignedSplitId,
      emergencyContact: entity.emergencyContact,
      notes: entity.notes,
      currentWeight: entity.currentWeight,
      attendanceStreak: entity.attendanceStreak,
      totalWorkoutsCompleted: entity.totalWorkoutsCompleted,
    );
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? 'Male',
      age: map['age'] ?? 25,
      planType: map['planType'] ?? 'Monthly',
      monthlyFee: (map['monthlyFee'] as num?)?.toDouble() ?? 50.0,
      dueDayOfMonth: map['dueDayOfMonth'] ?? 5,
      joinDate: map['joinDate'] != null
          ? DateTime.parse(map['joinDate'])
          : DateTime.now(),
      status: map['status'] ?? 'Active',
      assignedDietId: map['assignedDietId'],
      assignedSplitId: map['assignedSplitId'],
      emergencyContact: map['emergencyContact'],
      notes: map['notes'],
      currentWeight: (map['currentWeight'] as num?)?.toDouble() ?? 75.0,
      attendanceStreak: map['attendanceStreak'] ?? 0,
      totalWorkoutsCompleted: map['totalWorkoutsCompleted'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'age': age,
      'planType': planType,
      'monthlyFee': monthlyFee,
      'dueDayOfMonth': dueDayOfMonth,
      'joinDate': joinDate.toIso8601String(),
      'status': status,
      'assignedDietId': assignedDietId,
      'assignedSplitId': assignedSplitId,
      'emergencyContact': emergencyContact,
      'notes': notes,
      'currentWeight': currentWeight,
      'attendanceStreak': attendanceStreak,
      'totalWorkoutsCompleted': totalWorkoutsCompleted,
    };
  }
}
