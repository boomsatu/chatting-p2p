import 'dart:async';
import 'package:flutter/foundation.dart';
import '../database/database.dart';
import '../database/dao/contacts_dao.dart';
import '../../rust/api/node_api.dart' as rust_node;

class PresenceService {
  final ContactsDao _contactsDao;

  Timer? _heartbeatTimer;
  Timer? _timeoutTimer;
  bool _isRunning = false;

  PresenceService(AppDatabase db) : _contactsDao = ContactsDao(db);

  /// Starts the P2P presence heartbeat broadcasts and offline sweeps.
  void start() {
    if (_isRunning) return;
    _isRunning = true;

    // 1. Broadcaster: Send our own signed presence heartbeat every 30 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _publishPresenceHeartbeat();
    });

    // 2. Sweeper: Check for offline timeouts (90 seconds inactivity) every 10 seconds
    _timeoutTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      await sweepOfflineContacts();
    });

    // Send initial heartbeat immediately
    _publishPresenceHeartbeat();
  }

  /// Stops all presence background tasks.
  void stop() {
    _heartbeatTimer?.cancel();
    _timeoutTimer?.cancel();
    _heartbeatTimer = null;
    _timeoutTimer = null;
    _isRunning = false;
  }

  /// Calls FFI to sign and publish our presence updates to GossipSub.
  Future<void> _publishPresenceHeartbeat() async {
    try {
      if (await rust_node.isNodeRunning()) {
        await rust_node.publishPresence();
      }
    } catch (e) {
      debugPrint('Failed to broadcast presence heartbeat: $e');
    }
  }

  /// Sweeps all contacts and transitions inactive online contacts to offline.
  Future<void> sweepOfflineContacts() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final contacts = await _contactsDao.getAllContacts();

      for (final contact in contacts) {
        if (contact.status == 'online') {
          final lastSeen = contact.lastSeen ?? 0;
          // Timeout threshold: 90 seconds
          if (now - lastSeen > 90000) {
            await _contactsDao.updateContactStatus(
              contact.peerId,
              'offline',
              lastSeen,
            );
            debugPrint('Presence: Contact ${contact.displayName} timed out to offline.');
          }
        }
      }
    } catch (e) {
      debugPrint('Error sweeping offline contacts: $e');
    }
  }
}
