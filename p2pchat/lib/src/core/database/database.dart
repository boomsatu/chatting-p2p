import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/identity_table.dart';
import 'tables/contacts_table.dart';
import 'tables/conversations_table.dart';
import 'tables/messages_table.dart';
import 'tables/groups_table.dart';
import 'tables/message_queue_table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Identity,
  Contacts,
  Conversations,
  Messages,
  Groups,
  GroupMembers,
  MessageQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for unit testing with an in-memory database
  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'p2pchat.db'));
    return NativeDatabase.createInBackground(file);
  });
}
