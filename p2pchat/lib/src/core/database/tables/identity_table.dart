import 'package:drift/drift.dart';

class Identity extends Table {
  IntColumn get id => integer()();
  TextColumn get peerId => text().unique()();
  TextColumn get pubKey => text()();           // base64 X25519 public key
  TextColumn get signPubKey => text()();       // base64 Ed25519 public key
  TextColumn get displayName => text().withDefault(const Constant('Anonymous'))();
  TextColumn get avatarUri => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
