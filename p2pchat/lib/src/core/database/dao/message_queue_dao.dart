import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/message_queue_table.dart';

part 'message_queue_dao.g.dart';

@DriftAccessor(tables: [MessageQueue])
class MessageQueueDao extends DatabaseAccessor<AppDatabase> with _$MessageQueueDaoMixin {
  MessageQueueDao(AppDatabase db) : super(db);

  Future<List<MessageQueueData>> getPendingMessages() =>
      (select(messageQueue)..orderBy([(t) => OrderingTerm(expression: t.nextRetryAt, mode: OrderingMode.asc)])).get();

  Future<int> enqueueMessage(MessageQueueCompanion data) =>
      into(messageQueue).insert(data);

  Future<bool> incrementRetry(int id, int nextRetryAt) async {
    final record = await (select(messageQueue)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (record != null) {
      final updated = await (update(messageQueue)..where((t) => t.id.equals(id))).write(
        MessageQueueCompanion(
          retryCount: Value(record.retryCount + 1),
          nextRetryAt: Value(nextRetryAt),
        ),
      );
      return updated > 0;
    }
    return false;
  }

  Future<int> removeFromQueue(int id) =>
      (delete(messageQueue)..where((t) => t.id.equals(id))).go();
}
