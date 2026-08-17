/// Domain Entity for Gym Member
class MemberEntity {
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

  const MemberEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.gender = 'Male',
    this.age = 25,
    this.planType = 'Monthly',
    this.monthlyFee = 50.0,
    this.dueDayOfMonth = 5,
    required this.joinDate,
    this.status = 'Active',
    this.assignedDietId,
    this.assignedSplitId,
    this.emergencyContact,
    this.notes,
    this.currentWeight = 75.0,
    this.attendanceStreak = 0,
    this.totalWorkoutsCompleted = 0,
  });

  bool get isActive => status == 'Active';
  bool get isOverdue => status == 'Overdue';
  bool get isPendingFee => status == 'Pending Fee';
}
