import 'package:drift/drift.dart';

class Groups extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get topic => text().unique()(); // GossipSub group topic
  TextColumn get groupKeyId => text()();    // Reference ID of group symmetric key in secure storage
  TextColumn get adminPeerId => text()();
  TextColumn get avatarUri => text().nullable()();
  IntColumn get memberCount => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class GroupMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get groupId => text().references(Groups, #id, onDelete: KeyAction.cascade)();
  TextColumn get peerId => text()();
  TextColumn get role => text().withDefault(const Constant('member'))(); // 'admin' | 'member'
  IntColumn get joinedAt => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {groupId, peerId}
      ];
}
