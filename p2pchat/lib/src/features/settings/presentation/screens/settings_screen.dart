import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/dao/identity_dao.dart';
import 'package:p2pchat/src/rust/api/node_api.dart' as rust_node;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:drift/drift.dart' as drift;

import '../../../../core/providers/core_providers.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/dao/identity_dao.dart';
import 'package:p2pchat/src/rust/api/node_api.dart' as rust_node;
import 'package:p2pchat/src/rust/api/crypto_api.dart' as crypto_api;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late Future<IdentityData?> _identityFuture;
  bool _isRegenerating = false;

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  void _loadIdentity() {
    final db = ref.read(databaseProvider);
    _identityFuture = IdentityDao(db).getIdentity();
  }

  Future<void> _regenerateIdentity() async {
    setState(() => _isRegenerating = true);
    try {
      // 1. Generate identity from Rust FFI
      final identity = await crypto_api.generateIdentity();

      // 2. Save seed in secure storage
      final keystoreService = ref.read(keystoreServiceProvider);
      await keystoreService.storeIdentitySeed(identity.seed);

      // 3. Set active identity in Rust FFI keystore
      await crypto_api.setActiveIdentity(seed: identity.seed);

      // 4. Save to Drift SQLite database
      final db = ref.read(databaseProvider);
      final identityDao = IdentityDao(db);
      await identityDao.insertOrUpdateIdentity(IdentityCompanion(
        id: const drift.Value(1),
        peerId: drift.Value(identity.peerId),
        pubKey: drift.Value(identity.boxPubkey),
        signPubKey: drift.Value(identity.signingPubkey),
        displayName: const drift.Value('Me'),
        createdAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cryptographic identity successfully regenerated and fixed!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fixing profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRegenerating = false;
          _loadIdentity();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<IdentityData?>(
        future: _identityFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final identity = snapshot.data;
          if (identity == null) {
            return const Center(child: Text('Profile identity not found.'));
          }

          final isPending = identity.peerId == 'pending' || identity.peerId.isEmpty;

          // Build contact card payload for sharing
          final qrPayload = jsonEncode({
            'peerId': identity.peerId,
            'displayName': identity.displayName,
            'pubKey': identity.pubKey,
            'signPubKey': identity.signPubKey,
            'multiaddrs': <String>[],
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // Self-Healing Identity Recovery Banner
                if (isPending)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Profile Recovery Required',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your profile was set up under a previous version of the app and has a pending identity state. Generating a new cryptographic identity will fix your connection swarm and let you start chatting!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: _isRegenerating
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.vpn_key_rounded),
                            label: Text(_isRegenerating ? 'Generating Secure Keys...' : 'Fix Profile & Generate Keys'),
                            onPressed: _isRegenerating ? null : _regenerateIdentity,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                              foregroundColor: theme.colorScheme.onError,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // 1. Profile Avatar & Display Name
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            identity.displayName.isNotEmpty
                                ? identity.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        identity.displayName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Peer ID Glassmorphic Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Peer ID',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SelectableText(
                              identity.peerId,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFamily: 'monospace',
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 20),
                            onPressed: isPending
                                ? null
                                : () {
                                    Clipboard.setData(ClipboardData(text: identity.peerId));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Peer ID copied to clipboard!')),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Appearance Theme Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.palette_rounded, color: theme.colorScheme.primary, size: 22),
                          const SizedBox(width: 12),
                          Text(
                            'Appearance Theme',
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          segments: const [
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto_rounded, size: 18),
                              label: Text('System', style: TextStyle(fontSize: 12)),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_rounded, size: 18),
                              label: Text('Light', style: TextStyle(fontSize: 12)),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_rounded, size: 18),
                              label: Text('Dark', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                          selected: {ref.watch(themeModeProvider)},
                          onSelectionChanged: (Set<ThemeMode> newSelection) {
                            ref.read(themeModeProvider.notifier).setTheme(newSelection.first);
                          },
                          style: SegmentedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            selectedForegroundColor: theme.colorScheme.onPrimaryContainer,
                            selectedBackgroundColor: theme.colorScheme.primaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Share Contact QR Card
                if (!isPending)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'My Contact QR Card',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Let friends scan this QR card in person to instantly add you and secure your private P2P chat room.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Styled QR frame
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: QrImageView(
                            data: qrPayload,
                            version: QrVersions.auto,
                            size: 200.0,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Colors.black,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (!isPending) const SizedBox(height: 24),

                // 4. Live Network Status
                FutureBuilder<Map<String, dynamic>>(
                  future: () async {
                    try {
                      final running = await rust_node.isNodeRunning();
                      if (!running) return {'status': 'Offline', 'peers': BigInt.from(0)};
                      final count = await rust_node.getPeerCount();
                      return {'status': 'Running', 'peers': count};
                    } catch (_) {
                      return {'status': 'Offline', 'peers': BigInt.from(0)};
                    }
                  }(),
                  builder: (context, netSnapshot) {
                    final status = netSnapshot.data?['status'] ?? 'Offline';
                    final peerCount = netSnapshot.data?['peers'] ?? BigInt.from(0);
                    final isOnline = status == 'Running';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: isOnline ? Colors.green : Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'P2P Swarm Status',
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          Text(
                            isOnline ? '$status ($peerCount Peers)' : status,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOnline ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
