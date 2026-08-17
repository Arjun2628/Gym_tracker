import 'dart:convert';

class MemberModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final int age;
  final String planType; // 'Monthly', 'Quarterly', 'Half-Yearly', 'Annual'
  final double monthlyFee;
  final int dueDayOfMonth;
  final DateTime joinDate;
  final String status; // 'Active', 'Pending Fee', 'Overdue', 'Inactive'
  final String? assignedDietId;
  final String? assignedSplitId;
  final String? emergencyContact;
  final String? notes;
  final double currentWeight;
  final int attendanceStreak;
  final int totalWorkoutsCompleted;

  MemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.gender = 'Male',
    this.age = 25,
    this.planType = 'Monthly',
    this.monthlyFee = 50.0,
    this.dueDayOfMonth = 5,
    DateTime? joinDate,
    this.status = 'Active',
    this.assignedDietId,
    this.assignedSplitId,
    this.emergencyContact,
    this.notes,
    this.currentWeight = 75.0,
    this.attendanceStreak = 0,
    this.totalWorkoutsCompleted = 0,
  }) : joinDate = joinDate ?? DateTime.now();

  MemberModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    int? age,
    String? planType,
    double? monthlyFee,
    int? dueDayOfMonth,
    DateTime? joinDate,
    String? status,
    String? assignedDietId,
    String? assignedSplitId,
    String? emergencyContact,
    String? notes,
    double? currentWeight,
    int? attendanceStreak,
    int? totalWorkoutsCompleted,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      planType: planType ?? this.planType,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      dueDayOfMonth: dueDayOfMonth ?? this.dueDayOfMonth,
      joinDate: joinDate ?? this.joinDate,
      status: status ?? this.status,
      assignedDietId: assignedDietId ?? this.assignedDietId,
      assignedSplitId: assignedSplitId ?? this.assignedSplitId,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      notes: notes ?? this.notes,
      currentWeight: currentWeight ?? this.currentWeight,
      attendanceStreak: attendanceStreak ?? this.attendanceStreak,
      totalWorkoutsCompleted: totalWorkoutsCompleted ?? this.totalWorkoutsCompleted,
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

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      gender: map['gender'] ?? 'Male',
      age: (map['age'] as num?)?.toInt() ?? 25,
      planType: map['planType'] ?? 'Monthly',
      monthlyFee: (map['monthlyFee'] as num?)?.toDouble() ?? 50.0,
      dueDayOfMonth: (map['dueDayOfMonth'] as num?)?.toInt() ?? 5,
      joinDate: map['joinDate'] != null ? DateTime.tryParse(map['joinDate']) ?? DateTime.now() : DateTime.now(),
      status: map['status'] ?? 'Active',
      assignedDietId: map['assignedDietId'],
      assignedSplitId: map['assignedSplitId'],
      emergencyContact: map['emergencyContact'],
      notes: map['notes'],
      currentWeight: (map['currentWeight'] as num?)?.toDouble() ?? 75.0,
      attendanceStreak: (map['attendanceStreak'] as num?)?.toInt() ?? 0,
      totalWorkoutsCompleted: (map['totalWorkoutsCompleted'] as num?)?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());
  factory MemberModel.fromJson(String source) => MemberModel.fromMap(json.decode(source));
}
