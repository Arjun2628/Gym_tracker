import '../entities/member_entity.dart';

abstract class MemberRepository {
  Future<List<MemberEntity>> getMembers();
  Future<void> addMember(MemberEntity member);
  Future<void> updateMember(MemberEntity member);
  Future<void> deleteMember(String id);
  Future<MemberEntity?> getMemberById(String id);
}
