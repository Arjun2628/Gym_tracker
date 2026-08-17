import '../../domain/entities/member_entity.dart';
import '../../domain/repositories/member_repository.dart';
import '../datasources/admin_local_datasource.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/member_model.dart';

class MemberRepositoryImpl implements MemberRepository {
  final AdminLocalDataSource localDataSource;
  final AdminRemoteDataSource remoteDataSource;

  MemberRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<MemberEntity>> getMembers() async {
    return localDataSource.getMembers();
  }

  @override
  Future<void> addMember(MemberEntity member) async {
    final model = MemberModel.fromEntity(member);
    final current = await localDataSource.getMembers();
    final updated = List<MemberModel>.from(current)..add(model);
    await localDataSource.saveMembers(updated);
    await remoteDataSource.syncMember(model);
  }

  @override
  Future<void> updateMember(MemberEntity member) async {
    final model = MemberModel.fromEntity(member);
    final current = await localDataSource.getMembers();
    final idx = current.indexWhere((m) => m.id == member.id);
    if (idx >= 0) {
      current[idx] = model;
      await localDataSource.saveMembers(current);
      await remoteDataSource.syncMember(model);
    }
  }

  @override
  Future<void> deleteMember(String id) async {
    final current = await localDataSource.getMembers();
    current.removeWhere((m) => m.id == id);
    await localDataSource.saveMembers(current);
    await remoteDataSource.deleteMember(id);
  }

  @override
  Future<MemberEntity?> getMemberById(String id) async {
    final members = await localDataSource.getMembers();
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
