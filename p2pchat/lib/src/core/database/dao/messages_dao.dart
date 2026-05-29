import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/messages_table.dart';

part 'messages_dao.g.dart';

@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<AppDatabase> with _$MessagesDaoMixin {
  MessagesDao(AppDatabase db) : super(db);

  Future<Message?> getMessage(String id) =>
      (select(messages)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Message>> getMessagesForConversation(int conversationId, {int limit = 50, int offset = 0}) =>
      (select(messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])
            ..limit(limit, offset: offset))
          .get();

  Stream<List<Message>> watchMessagesForConversation(int conversationId) =>
      (select(messages)
            ..where((t) => t.conversationId.equals(conversationId))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
          .watch();

  Future<int> insertMessage(MessagesCompanion data) =>
      into(messages).insertOnConflictUpdate(data);

  Future<bool> updateMessageStatus(String messageId, String status) async {
    final updated = await (update(messages)..where((t) => t.id.equals(messageId))).write(
      MessagesCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    return updated > 0;
  }
}
