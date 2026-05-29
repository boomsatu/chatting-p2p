import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/contacts_table.dart';

part 'contacts_dao.g.dart';

@DriftAccessor(tables: [Contacts])
class ContactsDao extends DatabaseAccessor<AppDatabase> with _$ContactsDaoMixin {
  ContactsDao(AppDatabase db) : super(db);

  Future<Contact?> getContact(String peerId) =>
      (select(contacts)..where((t) => t.peerId.equals(peerId))).getSingleOrNull();

  Stream<Contact?> watchContact(String peerId) =>
      (select(contacts)..where((t) => t.peerId.equals(peerId))).watchSingleOrNull();

  Future<List<Contact>> getAllContacts() => select(contacts).get();

  Stream<List<Contact>> watchAllContacts() => select(contacts).watch();

  Future<int> insertOrUpdateContact(ContactsCompanion data) =>
      into(contacts).insertOnConflictUpdate(data);

  Future<bool> updateContactStatus(String peerId, String status, int lastSeen) async {
    final updated = await (update(contacts)..where((t) => t.peerId.equals(peerId))).write(
      ContactsCompanion(
        status: Value(status),
        lastSeen: Value(lastSeen),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
    return updated > 0;
  }

  Future<int> deleteContact(String peerId) =>
      (delete(contacts)..where((t) => t.peerId.equals(peerId))).go();
}
