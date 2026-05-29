import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/groups_table.dart';

part 'groups_dao.g.dart';

@DriftAccessor(tables: [Groups, GroupMembers])
class GroupsDao extends DatabaseAccessor<AppDatabase> with _$GroupsDaoMixin {
  GroupsDao(AppDatabase db) : super(db);

  Future<Group?> getGroup(String id) =>
      (select(groups)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Group?> watchGroup(String id) =>
      (select(groups)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<List<Group>> getAllGroups() => select(groups).get();

  Stream<List<Group>> watchAllGroups() => select(groups).watch();

  Future<void> insertGroup(GroupsCompanion groupData, List<GroupMembersCompanion> memberList) {
    return transaction(() async {
      await into(groups).insertOnConflictUpdate(groupData);
      for (final member in memberList) {
        await into(groupMembers).insertOnConflictUpdate(member);
      }
    });
  }

  Future<List<GroupMember>> getMembers(String groupId) =>
      (select(groupMembers)..where((t) => t.groupId.equals(groupId))).get();

  Stream<List<GroupMember>> watchMembers(String groupId) =>
      (select(groupMembers)..where((t) => t.groupId.equals(groupId))).watch();

  Future<int> removeMember(String groupId, String peerId) =>
      (delete(groupMembers)..where((t) => t.groupId.equals(groupId) & t.peerId.equals(peerId))).go();

  Future<int> deleteGroup(String id) =>
      (delete(groups)..where((t) => t.id.equals(id))).go();
}
