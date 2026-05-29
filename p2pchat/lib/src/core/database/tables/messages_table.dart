import 'package:drift/drift.dart';
import 'conversations_table.dart';

class Messages extends Table {
  TextColumn get id => text()(); // UUID v4
  IntColumn get conversationId => integer().references(Conversations, #id)();
  TextColumn get senderPeerId => text()();
  TextColumn get content => text()(); // Plaintext content (decrypted)
  TextColumn get contentType => text().withDefault(const Constant('text'))(); // 'text' | 'image' | 'file' | 'voice' | 'system'
  TextColumn get status => text().withDefault(const Constant('sent'))();      // 'sending' | 'sent' | 'delivered' | 'read' | 'failed'
  IntColumn get isMine => integer()(); // 1 = sent by me, 0 = received from peer
  TextColumn get replyToId => text().nullable()();
  TextColumn get metadata => text().nullable()(); // JSON string for file size, etc.
  IntColumn get disappearsAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
