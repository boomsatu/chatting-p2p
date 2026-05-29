import 'package:drift/drift.dart';

class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get type => text()();        // 'dm' | 'group'
  TextColumn get topic => text().unique()(); // GossipSub topic name
  TextColumn get targetId => text()();    // peerId (DM) or groupId (group)
  TextColumn get displayName => text()();
  TextColumn get lastMessage => text().nullable()();
  IntColumn get lastMessageAt => integer().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  IntColumn get muted => integer().withDefault(const Constant(0))();    // 1 = muted, 0 = not
  IntColumn get archived => integer().withDefault(const Constant(0))(); // 1 = archived, 0 = not
  IntColumn get createdAt => integer()();
}
