import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:p2pchat/src/core/database/database.dart';
import 'package:p2pchat/src/core/database/dao/identity_dao.dart';
import 'package:p2pchat/src/core/database/dao/contacts_dao.dart';
import 'package:p2pchat/src/core/database/dao/conversations_dao.dart';
import 'package:p2pchat/src/core/database/dao/messages_dao.dart';
import 'package:p2pchat/src/core/database/dao/groups_dao.dart';
import 'package:p2pchat/src/core/database/dao/message_queue_dao.dart';

void main() {
  late AppDatabase db;
  late IdentityDao identityDao;
  late ContactsDao contactsDao;
  late ConversationsDao conversationsDao;
  late MessagesDao messagesDao;
  late GroupsDao groupsDao;
  late MessageQueueDao messageQueueDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    identityDao = IdentityDao(db);
    contactsDao = ContactsDao(db);
    conversationsDao = ConversationsDao(db);
    messagesDao = MessagesDao(db);
    groupsDao = GroupsDao(db);
    messageQueueDao = MessageQueueDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('IdentityDao Tests', () {
    test('Should insert, retrieve, update, and delete identity', () async {
      // 1. Initial should be null
      var current = await identityDao.getIdentity();
      expect(current, isNull);

      // 2. Insert identity
      final identityCompanion = IdentityCompanion.insert(
        id: const Value(1),
        peerId: 'peer_123',
        pubKey: 'pub_key_base64',
        signPubKey: 'sign_pub_key_base64',
        displayName: const Value('John Doe'),
        createdAt: 1000,
      );

      await identityDao.insertOrUpdateIdentity(identityCompanion);
      current = await identityDao.getIdentity();
      expect(current, isNotNull);
      expect(current!.peerId, 'peer_123');
      expect(current.displayName, 'John Doe');

      // 3. Update identity
      final updatedCompanion = IdentityCompanion.insert(
        id: const Value(1),
        peerId: 'peer_123',
        pubKey: 'pub_key_base64',
        signPubKey: 'sign_pub_key_base64',
        displayName: const Value('John Doe Updated'),
        createdAt: 1000,
      );
      await identityDao.insertOrUpdateIdentity(updatedCompanion);
      current = await identityDao.getIdentity();
      expect(current!.displayName, 'John Doe Updated');

      // 4. Delete identity
      await identityDao.deleteIdentity();
      current = await identityDao.getIdentity();
      expect(current, isNull);
    });
  });

  group('ContactsDao Tests', () {
    test('Should perform basic CRUD operations on contacts', () async {
      // 1. Initially empty
      var list = await contactsDao.getAllContacts();
      expect(list, isEmpty);

      // 2. Insert contact
      final contactCompanion = ContactsCompanion.insert(
        peerId: 'peer_abc',
        displayName: 'Alice',
        pubKey: 'alice_pub',
        signPubKey: 'alice_sign',
        multiaddrs: '["/ip4/127.0.0.1/tcp/4001"]',
        createdAt: 2000,
        updatedAt: 2000,
      );

      await contactsDao.insertOrUpdateContact(contactCompanion);
      list = await contactsDao.getAllContacts();
      expect(list.length, 1);
      expect(list.first.displayName, 'Alice');

      // 3. Query single contact
      var alice = await contactsDao.getContact('peer_abc');
      expect(alice, isNotNull);
      expect(alice!.status, 'offline');

      // 4. Update contact status
      final success = await contactsDao.updateContactStatus('peer_abc', 'online', 2500);
      expect(success, isTrue);

      alice = await contactsDao.getContact('peer_abc');
      expect(alice!.status, 'online');
      expect(alice.lastSeen, 2500);

      // 5. Delete contact
      await contactsDao.deleteContact('peer_abc');
      alice = await contactsDao.getContact('peer_abc');
      expect(alice, isNull);
    });

    test('Should support streaming contacts list', () async {
      final stream = contactsDao.watchAllContacts();
      expect(
        stream,
        emitsInOrder([
          isEmpty,
          isNotEmpty,
        ]),
      );

      final contactCompanion = ContactsCompanion.insert(
        peerId: 'peer_xyz',
        displayName: 'Bob',
        pubKey: 'bob_pub',
        signPubKey: 'bob_sign',
        multiaddrs: '[]',
        createdAt: 3000,
        updatedAt: 3000,
      );

      await contactsDao.insertOrUpdateContact(contactCompanion);
    });
  });

  group('ConversationsDao Tests', () {
    test('Should perform CRUD on conversations including unread status tracking', () async {
      // 1. Insert conversation
      final convo = ConversationsCompanion.insert(
        type: 'dm',
        topic: 'chat/peer_abc',
        targetId: 'peer_abc',
        displayName: 'Alice',
        createdAt: 4000,
      );

      final convoId = await conversationsDao.insertOrUpdateConversation(convo);
      expect(convoId, isPositive);

      // 2. Fetch conversation
      var record = await conversationsDao.getConversation(convoId);
      expect(record, isNotNull);
      expect(record!.topic, 'chat/peer_abc');
      expect(record.unreadCount, 0);

      // 3. Update last message
      var updated = await conversationsDao.updateLastMessage('chat/peer_abc', 'Hello Alice', 4100);
      expect(updated, isTrue);

      record = await conversationsDao.getConversationByTopic('chat/peer_abc');
      expect(record!.lastMessage, 'Hello Alice');
      expect(record.lastMessageAt, 4100);

      // 4. Increment unread count
      var incremented = await conversationsDao.incrementUnreadCount('chat/peer_abc');
      expect(incremented, isTrue);

      record = await conversationsDao.getConversationByTopic('chat/peer_abc');
      expect(record!.unreadCount, 1);

      // 5. Reset unread count
      var reset = await conversationsDao.resetUnreadCount('chat/peer_abc');
      expect(reset, isTrue);

      record = await conversationsDao.getConversationByTopic('chat/peer_abc');
      expect(record!.unreadCount, 0);

      // 6. Delete conversation
      await conversationsDao.deleteConversation(convoId);
      record = await conversationsDao.getConversation(convoId);
      expect(record, isNull);
    });
  });

  group('MessagesDao Tests', () {
    test('Should insert, paginate, update status and fetch messages', () async {
      // Setup conversation
      final convo = ConversationsCompanion.insert(
        id: const Value(10),
        type: 'dm',
        topic: 'chat/peer_abc',
        targetId: 'peer_abc',
        displayName: 'Alice',
        createdAt: 4000,
      );
      await conversationsDao.insertOrUpdateConversation(convo);

      // 1. Insert messages
      final msg1 = MessagesCompanion.insert(
        id: 'msg_uuid_1',
        conversationId: 10,
        senderPeerId: 'peer_abc',
        content: 'Hello, how are you?',
        isMine: 0,
        createdAt: 5000,
        updatedAt: 5000,
      );

      final msg2 = MessagesCompanion.insert(
        id: 'msg_uuid_2',
        conversationId: 10,
        senderPeerId: 'my_peer_id',
        content: 'I am good! Thanks!',
        isMine: 1,
        createdAt: 5100,
        updatedAt: 5100,
      );

      await messagesDao.insertMessage(msg1);
      await messagesDao.insertMessage(msg2);

      // 2. Fetch single message
      var fetched = await messagesDao.getMessage('msg_uuid_1');
      expect(fetched, isNotNull);
      expect(fetched!.content, 'Hello, how are you?');
      expect(fetched.status, 'sent');

      // 3. Paginate messages (should be sorted by createdAt DESC)
      var list = await messagesDao.getMessagesForConversation(10, limit: 1, offset: 0);
      expect(list.length, 1);
      expect(list.first.id, 'msg_uuid_2'); // newer message first

      // 4. Update message status
      var statusUpdated = await messagesDao.updateMessageStatus('msg_uuid_1', 'read');
      expect(statusUpdated, isTrue);

      fetched = await messagesDao.getMessage('msg_uuid_1');
      expect(fetched!.status, 'read');
    });
  });

  group('GroupsDao Tests', () {
    test('Should handle transactional group and member creation', () async {
      final groupCompanion = GroupsCompanion.insert(
        id: 'group_uuid_1',
        name: 'Super Hackers',
        topic: 'group/group_uuid_1',
        groupKeyId: 'key_id_xyz',
        adminPeerId: 'my_peer_id',
        createdAt: 6000,
        updatedAt: 6000,
      );

      final members = [
        GroupMembersCompanion.insert(
          groupId: 'group_uuid_1',
          peerId: 'my_peer_id',
          role: const Value('admin'),
          joinedAt: 6000,
        ),
        GroupMembersCompanion.insert(
          groupId: 'group_uuid_1',
          peerId: 'peer_bob',
          role: const Value('member'),
          joinedAt: 6100,
        ),
      ];

      // 1. Insert Group and Members in transaction
      await groupsDao.insertGroup(groupCompanion, members);

      // 2. Retrieve Group
      var group = await groupsDao.getGroup('group_uuid_1');
      expect(group, isNotNull);
      expect(group!.name, 'Super Hackers');

      // 3. Retrieve Members
      var memberList = await groupsDao.getMembers('group_uuid_1');
      expect(memberList.length, 2);
      expect(memberList.any((m) => m.peerId == 'peer_bob'), isTrue);

      // 4. Remove a member
      await groupsDao.removeMember('group_uuid_1', 'peer_bob');
      memberList = await groupsDao.getMembers('group_uuid_1');
      expect(memberList.length, 1);
      expect(memberList.first.peerId, 'my_peer_id');

      // 5. Delete group
      await groupsDao.deleteGroup('group_uuid_1');
      group = await groupsDao.getGroup('group_uuid_1');
      expect(group, isNull);
    });
  });

  group('MessageQueueDao Tests', () {
    test('Should manage outgoing message retry queues', () async {
      // 1. Initially empty
      var pending = await messageQueueDao.getPendingMessages();
      expect(pending, isEmpty);

      // 2. Enqueue
      final messageQueueCompanion = MessageQueueCompanion.insert(
        messageId: 'msg_uuid_1',
        topic: 'chat/peer_abc',
        payload: 'encrypted_payload_hex',
        nextRetryAt: 7000,
        createdAt: 6000,
      );

      final queueId = await messageQueueDao.enqueueMessage(messageQueueCompanion);
      expect(queueId, isPositive);

      // 3. Fetch pending ordered by nextRetryAt ASC
      pending = await messageQueueDao.getPendingMessages();
      expect(pending.length, 1);
      expect(pending.first.messageId, 'msg_uuid_1');
      expect(pending.first.retryCount, 0);

      // 4. Increment retry
      var success = await messageQueueDao.incrementRetry(queueId, 7500);
      expect(success, isTrue);

      pending = await messageQueueDao.getPendingMessages();
      expect(pending.first.retryCount, 1);
      expect(pending.first.nextRetryAt, 7500);

      // 5. Remove from queue
      await messageQueueDao.removeFromQueue(queueId);
      pending = await messageQueueDao.getPendingMessages();
      expect(pending, isEmpty);
    });
  });
}
