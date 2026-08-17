import '../entities/member_entity.dart';
import '../entities/fee_record_entity.dart';
import '../repositories/member_repository.dart';
import '../repositories/fee_repository.dart';

class GetMembersUseCase {
  final MemberRepository repository;
  GetMembersUseCase(this.repository);

  Future<List<MemberEntity>> call() => repository.getMembers();
}

class AddMemberUseCase {
  final MemberRepository memberRepository;
  final FeeRepository feeRepository;
  AddMemberUseCase(this.memberRepository, this.feeRepository);

  Future<void> call(MemberEntity member) async {
    await memberRepository.addMember(member);
    // Generate current month fee record
    final now = DateTime.now();
    final currentMonthYear = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final initialFee = FeeRecordEntity(
      id: 'fee_${member.id}_$currentMonthYear',
      memberId: member.id,
      memberName: member.name,
      monthYear: currentMonthYear,
      amount: member.monthlyFee,
      dueDate: DateTime(now.year, now.month, member.dueDayOfMonth),
      status: 'Pending',
    );
    await feeRepository.addFeeRecord(initialFee);
  }
}

class UpdateMemberUseCase {
  final MemberRepository repository;
  UpdateMemberUseCase(this.repository);

  Future<void> call(MemberEntity member) => repository.updateMember(member);
}

class DeleteMemberUseCase {
  final MemberRepository repository;
  DeleteMemberUseCase(this.repository);

  Future<void> call(String id) => repository.deleteMember(id);
}

class RecordFeePaymentUseCase {
  final FeeRepository repository;
  RecordFeePaymentUseCase(this.repository);

  Future<void> call({
    required String feeId,
    required String paymentMethod,
    String? receiptNumber,
    String? notes,
  }) {
    return repository.recordFeePayment(
      feeId: feeId,
      paymentMethod: paymentMethod,
      receiptNumber: receiptNumber,
      notes: notes,
    );
  }
}

class GetMonthlyFeeSummariesUseCase {
  final FeeRepository repository;
  GetMonthlyFeeSummariesUseCase(this.repository);

  Future<List<MonthlyFeeSummaryEntity>> call() => repository.getMonthlyFeeSummaries();
}
