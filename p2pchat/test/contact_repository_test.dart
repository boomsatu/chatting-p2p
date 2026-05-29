import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:p2pchat/src/core/database/database.dart';
import 'package:p2pchat/src/core/database/dao/identity_dao.dart';
import 'package:p2pchat/src/core/database/dao/contacts_dao.dart';
import 'package:p2pchat/src/core/database/dao/conversations_dao.dart';
import 'package:p2pchat/src/core/repositories/contact_repository.dart';

void main() {
  late AppDatabase db;
  late IdentityDao identityDao;
  late ContactsDao contactsDao;
  late ConversationsDao conversationsDao;
  late ContactRepository contactRepository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    identityDao = IdentityDao(db);
    contactsDao = ContactsDao(db);
    conversationsDao = ConversationsDao(db);
    contactRepository = ContactRepository(db);

    // 1. Seed our own identity (required for sorted DM topic construction)
    final myIdentity = IdentityCompanion.insert(
      id: const Value(1),
      peerId: 'my_peer_id_123',
      pubKey: 'my_x25519_pub',
      signPubKey: 'my_ed25519_pub',
      displayName: const Value('Me'),
      createdAt: 1000,
    );
    await identityDao.insertOrUpdateIdentity(myIdentity);
  });

  tearDown(() async {
    await db.close();
  });

  group('ContactRepository Tests', () {
    test('Should successfully parse QR JSON, save contact, and create conversation', () async {
      // 1. Create a raw QR code data card matching ContactCard structure
      final qrCard = {
        'peerId': 'peer_friend_xyz',
        'displayName': 'Bob',
        'pubKey': 'bob_x25519_pubkey_base64',
        'signPubKey': 'bob_ed25519_pubkey_base64',
        'multiaddrs': ['/ip4/192.168.1.50/tcp/4001'],
      };
      final qrJson = jsonEncode(qrCard);

      // 2. Add contact
      final conversation = await contactRepository.addContactFromQr(qrJson);

      // 3. Verify returned Conversation
      expect(conversation, isNotNull);
      expect(conversation.displayName, 'Bob');
      expect(conversation.targetId, 'peer_friend_xyz');
      expect(conversation.type, 'dm');
      
      // Expected sorted DM topic name: dm:my_peer_id_123:peer_friend_xyz
      expect(conversation.topic, 'dm:my_peer_id_123:peer_friend_xyz');

      // 4. Verify SQLite Database Persistence
      final contact = await contactsDao.getContact('peer_friend_xyz');
      expect(contact, isNotNull);
      expect(contact!.displayName, 'Bob');
      expect(contact.pubKey, 'bob_x25519_pubkey_base64');
      expect(contact.signPubKey, 'bob_ed25519_pubkey_base64');
      
      final savedConvo = await conversationsDao.getConversationByTopic(conversation.topic);
      expect(savedConvo, isNotNull);
      expect(savedConvo!.targetId, 'peer_friend_xyz');
    });

    test('Should throw FormatException on missing or corrupted fields', () async {
      // Missing fields (missing pubKey)
      final corruptedCard = {
        'peerId': 'peer_friend_xyz',
        'displayName': 'Bob',
        'signPubKey': 'bob_ed25519_pubkey_base64',
        'multiaddrs': [],
      };
      final qrJson = jsonEncode(corruptedCard);

      expect(
        () => contactRepository.addContactFromQr(qrJson),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
