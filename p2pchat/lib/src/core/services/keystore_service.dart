import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps flutter_secure_storage for persisting identity seeds and group keys
/// on the device's hardware-backed keychain/keystore.
class KeystoreService {
  static const _seedKey = 'identity_seed';
  static const _groupKeyPrefix = 'group_key_';

  final FlutterSecureStorage _storage;

  KeystoreService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // ─── Identity Seed ───────────────────────────────────────────

  /// Store the 32-byte identity seed as a hex string
  Future<void> storeIdentitySeed(List<int> seed) async {
    final hex = seed.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: _seedKey, value: hex);
  }

  /// Load the stored identity seed (returns null if not yet created)
  Future<List<int>?> loadIdentitySeed() async {
    final hex = await _storage.read(key: _seedKey);
    if (hex == null) return null;
    return _hexToBytes(hex);
  }

  /// Check if an identity has been created
  Future<bool> hasIdentity() async {
    return await _storage.containsKey(key: _seedKey);
  }

  /// Delete the identity seed (factory reset)
  Future<void> deleteIdentitySeed() async {
    await _storage.delete(key: _seedKey);
  }

  // ─── Group Keys ──────────────────────────────────────────────

  /// Store a group symmetric key by group ID
  Future<void> storeGroupKey(String groupId, List<int> key) async {
    final hex = key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: '$_groupKeyPrefix$groupId', value: hex);
  }

  /// Load a group symmetric key by group ID
  Future<List<int>?> loadGroupKey(String groupId) async {
    final hex = await _storage.read(key: '$_groupKeyPrefix$groupId');
    if (hex == null) return null;
    return _hexToBytes(hex);
  }

  /// Delete a group key
  Future<void> deleteGroupKey(String groupId) async {
    await _storage.delete(key: '$_groupKeyPrefix$groupId');
  }

  // ─── Helpers ─────────────────────────────────────────────────

  List<int> _hexToBytes(String hex) {
    final result = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      result.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return result;
  }
}
