import 'package:drift/drift.dart';

class MessageQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get topic => text()();
  TextColumn get payload => text()(); // Encrypted JSON payload for transmission
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(10))();
  IntColumn get nextRetryAt => integer()(); // Timestamp ms
  IntColumn get createdAt => integer()();
}
