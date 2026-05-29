import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/conversations_table.dart';

part 'conversations_dao.g.dart';

@DriftAccessor(tables: [Conversations])
class ConversationsDao extends DatabaseAccessor<AppDatabase> with _$ConversationsDaoMixin {
  ConversationsDao(AppDatabase db) : super(db);

  Future<Conversation?> getConversation(int id) =>
      (select(conversations)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Conversation?> getConversationByTopic(String topic) =>
      (select(conversations)..where((t) => t.topic.equals(topic))).getSingleOrNull();

  Stream<List<Conversation>> watchAllConversations() =>
      (select(conversations)..orderBy([(t) => OrderingTerm(expression: t.lastMessageAt, mode: OrderingMode.desc)])).watch();

  Future<int> insertOrUpdateConversation(ConversationsCompanion data) =>
      into(conversations).insertOnConflictUpdate(data);

  Future<bool> updateLastMessage(String topic, String lastMessage, int lastMessageAt) async {
    final updated = await (update(conversations)..where((t) => t.topic.equals(topic))).write(
      ConversationsCompanion(
        lastMessage: Value(lastMessage),
        lastMessageAt: Value(lastMessageAt),
      ),
    );
    return updated > 0;
  }

  Future<bool> incrementUnreadCount(String topic) async {
    final convo = await getConversationByTopic(topic);
    if (convo != null) {
      final updated = await (update(conversations)..where((t) => t.topic.equals(topic))).write(
        ConversationsCompanion(
          unreadCount: Value(convo.unreadCount + 1),
        ),
      );
      return updated > 0;
    }
    return false;
  }

  Future<bool> resetUnreadCount(String topic) async {
    final updated = await (update(conversations)..where((t) => t.topic.equals(topic))).write(
      const ConversationsCompanion(
        unreadCount: Value(0),
      ),
    );
    return updated > 0;
  }

  Future<int> deleteConversation(int id) =>
      (delete(conversations)..where((t) => t.id.equals(id))).go();
}
