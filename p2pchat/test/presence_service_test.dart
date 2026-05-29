import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:p2pchat/src/core/database/database.dart';
import 'package:p2pchat/src/core/database/dao/contacts_dao.dart';
import 'package:p2pchat/src/core/services/presence_service.dart';

void main() {
  late AppDatabase db;
  late ContactsDao contactsDao;
  late PresenceService presenceService;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    contactsDao = ContactsDao(db);
    presenceService = PresenceService(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('PresenceService Tests', () {
    test('Should transition stale online contacts to offline, leaving active contacts online', () async {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. Contact A: Stale (last seen 100 seconds ago, timeout threshold is 90s)
      final contactA = ContactsCompanion.insert(
        peerId: 'peer_stale_123',
        displayName: 'Alice Stale',
        pubKey: 'alice_pub',
        signPubKey: 'alice_sign',
        multiaddrs: '[]',
        status: const Value('online'),
        lastSeen: Value(now - 100000), // 100s ago
        createdAt: now - 150000,
        updatedAt: now - 100000,
      );

      // 2. Contact B: Active (last seen 10 seconds ago)
      final contactB = ContactsCompanion.insert(
        peerId: 'peer_active_456',
        displayName: 'Bob Active',
        pubKey: 'bob_pub',
        signPubKey: 'bob_sign',
        multiaddrs: '[]',
        status: const Value('online'),
        lastSeen: Value(now - 10000), // 10s ago
        createdAt: now - 150000,
        updatedAt: now - 100000,
      );

      await contactsDao.insertOrUpdateContact(contactA);
      await contactsDao.insertOrUpdateContact(contactB);

      // 3. Manually trigger the offline sweep
      await presenceService.sweepOfflineContacts();

      // 4. Verify results
      final resultA = await contactsDao.getContact('peer_stale_123');
      expect(resultA, isNotNull);
      expect(resultA!.status, 'offline'); // should be offline now!

      final resultB = await contactsDao.getContact('peer_active_456');
      expect(resultB, isNotNull);
      expect(resultB!.status, 'online'); // should remain online!
    });
  });
}
