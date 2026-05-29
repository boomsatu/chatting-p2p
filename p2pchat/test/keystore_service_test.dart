import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:p2pchat/src/core/services/keystore_service.dart';

class FakeSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #write) {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String?;
      if (value != null) {
        _data[key] = value;
      } else {
        _data.remove(key);
      }
      return Future<void>.value();
    }
    if (invocation.memberName == #read) {
      final key = invocation.namedArguments[#key] as String;
      return Future<String?>.value(_data[key]);
    }
    if (invocation.memberName == #containsKey) {
      final key = invocation.namedArguments[#key] as String;
      return Future<bool>.value(_data.containsKey(key));
    }
    if (invocation.memberName == #delete) {
      final key = invocation.namedArguments[#key] as String;
      _data.remove(key);
      return Future<void>.value();
    }
    if (invocation.memberName == #deleteAll) {
      _data.clear();
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  late FakeSecureStorage fakeStorage;
  late KeystoreService keystoreService;

  setUp(() {
    fakeStorage = FakeSecureStorage();
    keystoreService = KeystoreService(storage: fakeStorage);
  });

  group('KeystoreService Identity Seed Tests', () {
    test('Should store, load, delete and check existence of identity seed', () async {
      // 1. Initially should not have identity
      var exists = await keystoreService.hasIdentity();
      expect(exists, isFalse);

      var seed = await keystoreService.loadIdentitySeed();
      expect(seed, isNull);

      // 2. Store identity seed
      final testSeed = List<int>.generate(32, (i) => i);
      await keystoreService.storeIdentitySeed(testSeed);

      // 3. Verify existence and values
      exists = await keystoreService.hasIdentity();
      expect(exists, isTrue);

      seed = await keystoreService.loadIdentitySeed();
      expect(seed, isNotNull);
      expect(seed, equals(testSeed));

      // 4. Delete and verify removal
      await keystoreService.deleteIdentitySeed();
      exists = await keystoreService.hasIdentity();
      expect(exists, isFalse);

      seed = await keystoreService.loadIdentitySeed();
      expect(seed, isNull);
    });
  });

  group('KeystoreService Group Key Tests', () {
    test('Should store, load, and delete group keys', () async {
      final testKey = List<int>.generate(32, (i) => 255 - i);
      const groupId = 'group-123-abc';

      // 1. Initial state
      var loadedKey = await keystoreService.loadGroupKey(groupId);
      expect(loadedKey, isNull);

      // 2. Store group key
      await keystoreService.storeGroupKey(groupId, testKey);

      // 3. Load group key
      loadedKey = await keystoreService.loadGroupKey(groupId);
      expect(loadedKey, isNotNull);
      expect(loadedKey, equals(testKey));

      // 4. Delete group key
      await keystoreService.deleteGroupKey(groupId);
      loadedKey = await keystoreService.loadGroupKey(groupId);
      expect(loadedKey, isNull);
    });
  });
}
