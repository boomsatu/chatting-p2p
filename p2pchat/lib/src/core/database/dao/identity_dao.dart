import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/identity_table.dart';

part 'identity_dao.g.dart';

@DriftAccessor(tables: [Identity])
class IdentityDao extends DatabaseAccessor<AppDatabase> with _$IdentityDaoMixin {
  IdentityDao(AppDatabase db) : super(db);

  Future<IdentityData?> getIdentity() =>
      (select(identity)..limit(1)).getSingleOrNull();

  Future<int> insertOrUpdateIdentity(IdentityCompanion data) =>
      into(identity).insertOnConflictUpdate(data);

  Future<int> deleteIdentity() => delete(identity).go();
}
