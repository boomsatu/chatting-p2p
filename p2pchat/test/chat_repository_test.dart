import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:p2pchat/src/core/database/database.dart';
import 'package:p2pchat/src/core/database/dao/identity_dao.dart';
import 'package:p2pchat/src/core/database/dao/contacts_dao.dart';
import 'package:p2pchat/src/core/database/dao/conversations_dao.dart';
import 'package:p2pchat/src/core/database/dao/messages_dao.dart';
import 'package:p2pchat/src/core/database/dao/message_queue_dao.dart';
import 'package:p2pchat/src/core/repositories/chat_repository.dart';

void main() {
  late AppDatabase db;
  late IdentityDao identityDao;
  late ContactsDao contactsDao;
  late ConversationsDao conversationsDao;
  late MessagesDao messagesDao;
  late MessageQueueDao messageQueueDao;
  late ChatRepository chatRepository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    identityDao = IdentityDao(db);
    contactsDao = ContactsDao(db);
    conversationsDao = ConversationsDao(db);
    messagesDao = MessagesDao(db);
    messageQueueDao = MessageQueueDao(db);
    chatRepository = ChatRepository(db);

    // 1. Seed our own identity
    final myIdentity = IdentityCompanion.insert(
      id: const Value(1),
      peerId: 'my_peer_id_123',
      pubKey: 'my_x25519_pub',
      signPubKey: 'my_ed25519_pub',
      displayName: const Value('Me'),
      createdAt: 1000,
    );
    await identityDao.insertOrUpdateIdentity(myIdentity);

    // 2. Seed a friend contact
    final contact = ContactsCompanion.insert(
      peerId: 'peer_bob_456',
      displayName: 'Bob',
      pubKey: 'bob_x25519_pub',
      signPubKey: 'bob_ed25519_pub',
      multiaddrs: '[]',
      createdAt: 1500,
      updatedAt: 1500,
    );
    await contactsDao.insertOrUpdateContact(contact);
  });

  tearDown(() async {
    await db.close();
  });

  group('ChatRepository Tests', () {
    test('Should handle secure DM sending, handle FFI failure gracefully, and enqueue message', () async {
      // 1. Trigger DM sending
      // Since FFI is not loaded in unit tests, this will trigger the FFI failure path,
      // which gracefully updates the message status to 'failed' and enqueues it in the retry queue.
      await chatRepository.sendDM(
        targetPeerId: 'peer_bob_456',
        content: 'Hi Bob, this is Me!',
      );

      // 2. Verify that a DM conversation was automatically generated
      // Expected sorted DM topic name: dm:my_peer_id_123:peer_bob_456
      final expectedTopic = 'dm:my_peer_id_123:peer_bob_456';
      final conversation = await conversationsDao.getConversationByTopic(expectedTopic);
      expect(conversation, isNotNull);
      expect(conversation!.targetId, 'peer_bob_456');
      expect(conversation.displayName, 'Bob');

      // 3. Verify that the local message was stored
      final messages = await messagesDao.getMessagesForConversation(conversation.id);
      expect(messages.length, 1);
      expect(messages.first.content, 'Hi Bob, this is Me!');
      expect(messages.first.isMine, 1);
      expect(messages.first.senderPeerId, 'my_peer_id_123');
      
      // Expected status should be 'failed' due to missing FFI library in Dart host tests
      expect(messages.first.status, 'failed');

      // 4. Verify that the failed message was enqueued into the MessageQueue for background retries
      final pendingQueue = await messageQueueDao.getPendingMessages();
      expect(pendingQueue.length, 1);
      expect(pendingQueue.first.messageId, messages.first.id);
      expect(pendingQueue.first.topic, expectedTopic);
      expect(pendingQueue.first.retryCount, 0);
    });
  });
}
