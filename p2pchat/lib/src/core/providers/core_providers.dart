import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../database/database.dart';
import '../services/keystore_service.dart';
import '../services/presence_service.dart';
import '../repositories/contact_repository.dart';
import '../repositories/chat_repository.dart';

import '../../rust/api/node_api.dart';
import '../database/dao/contacts_dao.dart';
import '../database/dao/messages_dao.dart';
import '../database/dao/groups_dao.dart';

/// Global database provider — single AppDatabase instance for the app
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Global keystore service provider
final keystoreServiceProvider = Provider<KeystoreService>((ref) {
  return KeystoreService();
});

/// Contact discovery repository provider
final contactRepositoryProvider = Provider<ContactRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ContactRepository(db);
});

/// Secure DM Chat repository provider (handles encrypt/decrypt and FFI stream)
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final repo = ChatRepository(db);
  repo.startIncomingMessageListener();
  ref.onDispose(() => repo.stopIncomingMessageListener());
  return repo;
});

/// Decentralized P2P presence & timeout heartbeat service provider
final presenceServiceProvider = Provider<PresenceService>((ref) {
  final db = ref.watch(databaseProvider);
  final service = PresenceService(db);
  service.start();
  ref.onDispose(() => service.stop());
  return service;
});

/// Stream of connection events or logs from the decentralized node
final nodeStatusProvider = StreamProvider<String>((ref) {
  return registerPeerEventStream();
});

/// Stream of all active contacts in the database
final contactsProvider = StreamProvider<List<Contact>>((ref) {
  final db = ref.watch(databaseProvider);
  return ContactsDao(db).watchAllContacts();
});

/// Stream of messages for a specific conversation ID
final chatProvider = StreamProvider.family<List<Message>, int>((ref, conversationId) {
  final db = ref.watch(databaseProvider);
  return MessagesDao(db).watchMessagesForConversation(conversationId);
});

/// Stream of all active groups in the database
final groupsProvider = StreamProvider<List<Group>>((ref) {
  final db = ref.watch(databaseProvider);
  return GroupsDao(db).watchAllGroups();
});

/// Theme mode notifier — reads and writes the application ThemeMode to secure storage
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _themeKey = 'app_theme_mode';

  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final value = await _storage.read(key: _themeKey);
      if (value == 'light') {
        state = ThemeMode.light;
      } else if (value == 'dark') {
        state = ThemeMode.dark;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    try {
      String value = 'system';
      if (mode == ThemeMode.light) {
        value = 'light';
      } else if (mode == ThemeMode.dark) {
        value = 'dark';
      }
      await _storage.write(key: _themeKey, value: value);
    } catch (_) {}
  }
}

/// Global provider for the active theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
