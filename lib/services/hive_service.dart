import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/member_model.dart';
import '../models/fee_model.dart';
import '../models/diet_model.dart';

class HiveGymService {
  static const String membersBoxName = 'apex_members_box';
  static const String feesBoxName = 'apex_fees_box';
  static const String dietsBoxName = 'apex_diets_box';
  static const String settingsBoxName = 'apex_settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(membersBoxName);
    await Hive.openBox(feesBoxName);
    await Hive.openBox(dietsBoxName);
    await Hive.openBox(settingsBoxName);
  }

  // --- MEMBERS ---

  static List<MemberModel> getMembers() {
    try {
      final box = Hive.box(membersBoxName);
      final rawList = box.get('members_list');
      if (rawList != null) {
        final List<dynamic> decoded = json.decode(rawList);
        return decoded.map((m) => MemberModel.fromMap(m as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error loading members from Hive: $e');
    }
    return [];
  }

  static Future<void> saveMembers(List<MemberModel> members) async {
    try {
      final box = Hive.box(membersBoxName);
      final encoded = json.encode(members.map((m) => m.toMap()).toList());
      await box.put('members_list', encoded);
    } catch (e) {
      debugPrint('Error saving members to Hive: $e');
    }
  }

  // --- FEES ---

  static List<FeeRecord> getFeeRecords() {
    try {
      final box = Hive.box(feesBoxName);
      final rawList = box.get('fees_list');
      if (rawList != null) {
        final List<dynamic> decoded = json.decode(rawList);
        return decoded.map((f) => FeeRecord.fromMap(f as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('Error loading fees from Hive: $e');
    }
    return [];
  }

  static Future<void> saveFeeRecords(List<FeeRecord> feeRecords) async {
    try {
      final box = Hive.box(feesBoxName);
      final encoded = json.encode(feeRecords.map((f) => f.toMap()).toList());
      await box.put('fees_list', encoded);
    } catch (e) {
      debugPrint('Error saving fees to Hive: $e');
    }
  }

  // --- ACTIVE DIET ---

  static DietPlan? getActiveDiet() {
    try {
      final box = Hive.box(dietsBoxName);
      final raw = box.get('active_diet');
      if (raw != null) {
        return DietPlan.fromJson(raw);
      }
    } catch (e) {
      debugPrint('Error loading active diet from Hive: $e');
    }
    return null;
  }

  static Future<void> saveActiveDiet(DietPlan diet) async {
    try {
      final box = Hive.box(dietsBoxName);
      await box.put('active_diet', diet.toJson());
    } catch (e) {
      debugPrint('Error saving active diet to Hive: $e');
    }
  }

  // --- SEED SAMPLE GYM DATA ---

  static List<MemberModel> getSeedMembers() {
    final now = DateTime.now();
    return [
      MemberModel(
        id: 'mem_01',
        name: 'Alex Mercer',
        email: 'alex.mercer@gmail.com',
        phone: '+1 (555) 234-5678',
        gender: 'Male',
        age: 28,
        planType: 'Annual',
        monthlyFee: 45.0,
        dueDayOfMonth: 5,
        joinDate: now.subtract(const Duration(days: 120)),
        status: 'Active',
        assignedDietId: 'diet_hypertrophy_mass',
        assignedSplitId: 'split_ppl',
        currentWeight: 82.5,
        attendanceStreak: 14,
        totalWorkoutsCompleted: 48,
      ),
      MemberModel(
        id: 'mem_02',
        name: 'Elena Rostova',
        email: 'elena.r@outlook.com',
        phone: '+1 (555) 345-6789',
        gender: 'Female',
        age: 26,
        planType: 'Quarterly',
        monthlyFee: 55.0,
        dueDayOfMonth: 10,
        joinDate: now.subtract(const Duration(days: 90)),
        status: 'Pending Fee',
        assignedDietId: 'diet_lean_shred',
        assignedSplitId: 'split_upper_lower',
        currentWeight: 63.0,
        attendanceStreak: 8,
        totalWorkoutsCompleted: 32,
      ),
      MemberModel(
        id: 'mem_03',
        name: 'Marcus Vance',
        email: 'marcus.vance@techcorp.io',
        phone: '+1 (555) 456-7890',
        gender: 'Male',
        age: 32,
        planType: 'Monthly',
        monthlyFee: 60.0,
        dueDayOfMonth: 1,
        joinDate: now.subtract(const Duration(days: 45)),
        status: 'Overdue',
        assignedDietId: 'diet_clean_bulk',
        assignedSplitId: 'split_arnold',
        currentWeight: 88.0,
        attendanceStreak: 3,
        totalWorkoutsCompleted: 18,
      ),
      MemberModel(
        id: 'mem_04',
        name: 'Sophia Chen',
        email: 'sophia.chen@designhub.co',
        phone: '+1 (555) 567-8901',
        gender: 'Female',
        age: 24,
        planType: 'Monthly',
        monthlyFee: 60.0,
        dueDayOfMonth: 15,
        joinDate: now.subtract(const Duration(days: 60)),
        status: 'Active',
        assignedDietId: 'diet_veg_muscle',
        assignedSplitId: 'split_full_body',
        currentWeight: 57.5,
        attendanceStreak: 19,
        totalWorkoutsCompleted: 40,
      ),
      MemberModel(
        id: 'mem_05',
        name: 'David Miller',
        email: 'david.miller@gmail.com',
        phone: '+1 (555) 678-9012',
        gender: 'Male',
        age: 35,
        planType: 'Annual',
        monthlyFee: 45.0,
        dueDayOfMonth: 5,
        joinDate: now.subtract(const Duration(days: 180)),
        status: 'Active',
        assignedDietId: 'diet_keto_anabolic',
        assignedSplitId: 'split_ppl',
        currentWeight: 79.0,
        attendanceStreak: 25,
        totalWorkoutsCompleted: 72,
      ),
      MemberModel(
        id: 'mem_06',
        name: 'Priya Sharma',
        email: 'priya.sharma@healthfit.org',
        phone: '+1 (555) 789-0123',
        gender: 'Female',
        age: 29,
        planType: 'Quarterly',
        monthlyFee: 55.0,
        dueDayOfMonth: 8,
        joinDate: now.subtract(const Duration(days: 75)),
        status: 'Pending Fee',
        assignedDietId: 'diet_veg_muscle',
        assignedSplitId: 'split_upper_lower',
        currentWeight: 61.2,
        attendanceStreak: 11,
        totalWorkoutsCompleted: 28,
      ),
    ];
  }

  static List<FeeRecord> getSeedFeeRecords(List<MemberModel> members) {
    final now = DateTime.now();
    final currentMonthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final prevDate = DateTime(now.year, now.month - 1, 1);
    final prevMonthYear = '${prevDate.year}-${prevDate.month.toString().padLeft(2, '0')}';
    final prevPrevDate = DateTime(now.year, now.month - 2, 1);
    final prevPrevMonthYear = '${prevPrevDate.year}-${prevPrevDate.month.toString().padLeft(2, '0')}';

    final List<FeeRecord> records = [];

    for (final member in members) {
      // 1. Current Month Record
      if (member.id == 'mem_01' || member.id == 'mem_04' || member.id == 'mem_05') {
        records.add(FeeRecord(
          id: 'fee_${member.id}_$currentMonthYear',
          memberId: member.id,
          memberName: member.name,
          monthYear: currentMonthYear,
          amount: member.monthlyFee,
          dueDate: DateTime(now.year, now.month, member.dueDayOfMonth),
          paidDate: DateTime(now.year, now.month, member.dueDayOfMonth - 1, 14, 30),
          status: 'Paid',
          paymentMethod: member.id == 'mem_01' ? 'UPI / GPay' : 'Card',
          receiptNumber: 'REC-2026-${1000 + records.length}',
        ));
      } else if (member.id == 'mem_03') {
        records.add(FeeRecord(
          id: 'fee_${member.id}_$currentMonthYear',
          memberId: member.id,
          memberName: member.name,
          monthYear: currentMonthYear,
          amount: member.monthlyFee,
          dueDate: DateTime(now.year, now.month, member.dueDayOfMonth),
          status: 'Overdue',
          notes: 'Reminder sent via SMS. Payment promised by Friday.',
        ));
      } else {
        records.add(FeeRecord(
          id: 'fee_${member.id}_$currentMonthYear',
          memberId: member.id,
          memberName: member.name,
          monthYear: currentMonthYear,
          amount: member.monthlyFee,
          dueDate: DateTime(now.year, now.month, member.dueDayOfMonth),
          status: 'Pending',
        ));
      }

      // 2. Previous Month Record
      if (member.id == 'mem_03') {
        // Overdue also in previous month
        records.add(FeeRecord(
          id: 'fee_${member.id}_$prevMonthYear',
          memberId: member.id,
          memberName: member.name,
          monthYear: prevMonthYear,
          amount: member.monthlyFee,
          dueDate: DateTime(prevDate.year, prevDate.month, member.dueDayOfMonth),
          status: 'Overdue',
          notes: 'Unpaid dues carried over.',
        ));
      } else {
        records.add(FeeRecord(
          id: 'fee_${member.id}_$prevMonthYear',
          memberId: member.id,
          memberName: member.name,
          monthYear: prevMonthYear,
          amount: member.monthlyFee,
          dueDate: DateTime(prevDate.year, prevDate.month, member.dueDayOfMonth),
          paidDate: DateTime(prevDate.year, prevDate.month, member.dueDayOfMonth, 11, 0),
          status: 'Paid',
          paymentMethod: 'Cash',
          receiptNumber: 'REC-2026-${900 + records.length}',
        ));
      }

      // 3. Two Months Ago Record
      records.add(FeeRecord(
        id: 'fee_${member.id}_$prevPrevMonthYear',
        memberId: member.id,
        memberName: member.name,
        monthYear: prevPrevMonthYear,
        amount: member.monthlyFee,
        dueDate: DateTime(prevPrevDate.year, prevPrevDate.month, member.dueDayOfMonth),
        paidDate: DateTime(prevPrevDate.year, prevPrevDate.month, member.dueDayOfMonth, 16, 20),
        status: 'Paid',
        paymentMethod: 'UPI / GPay',
        receiptNumber: 'REC-2026-${800 + records.length}',
      ));
    }

    return records;
  }
}
