import 'package:drift/drift.dart';

class Contacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get peerId => text().unique()();
  TextColumn get displayName => text()();
  TextColumn get pubKey => text()();           // base64 X25519 public key
  TextColumn get signPubKey => text()();       // base64 Ed25519 public key
  TextColumn get multiaddrs => text()();       // JSON array of multiaddr strings
  TextColumn get avatarUri => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('offline'))(); // 'online' | 'offline'
  IntColumn get lastSeen => integer().nullable()();
  IntColumn get verified => integer().withDefault(const Constant(0))();     // 1 = verified via QR, 0 = not
  IntColumn get blocked => integer().withDefault(const Constant(0))();      // 1 = blocked, 0 = not
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}
