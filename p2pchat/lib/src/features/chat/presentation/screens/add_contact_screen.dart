import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/dao/identity_dao.dart';

/// AddContactScreen — features QR code scanning and sharing
class AddContactScreen extends ConsumerStatefulWidget {
  const AddContactScreen({super.key});

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _isProcessingScan = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // Pause scanner when switching to "My Code" tab
      if (_tabController.index == 1) {
        _scannerController.stop();
      } else {
        _scannerController.start();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);
    final identityDao = IdentityDao(db);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Scan Code', icon: Icon(Icons.qr_code_scanner_rounded)),
            Tab(text: 'My Code', icon: Icon(Icons.qr_code_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Prevent accidental swipes
        children: [
          // TAB 1: SCAN QR CODE
          _buildScannerTab(context),

          // TAB 2: MY QR CODE CARD
          _buildMyCodeTab(context, identityDao, theme),
        ],
      ),
    );
  }

  Widget _buildScannerTab(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: (BarcodeCapture capture) async {
            if (_isProcessingScan) return;

            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final String? rawValue = barcode.rawValue;
              if (rawValue != null && rawValue.isNotEmpty) {
                setState(() {
                  _isProcessingScan = true;
                });
                _scannerController.stop();
                await _handleScannedData(context, rawValue);
                break;
              }
            }
          },
        ),
        // Scanner Target Overlay
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(180),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'Scan your friend\'s QR Card',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        if (_isProcessingScan)
          Container(
            color: Colors.black54,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Adding contact...',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMyCodeTab(BuildContext context, IdentityDao identityDao, ThemeData theme) {
    return FutureBuilder<IdentityData?>(
      future: identityDao.getIdentity(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final identity = snapshot.data;
        if (identity == null) {
          return const Center(
            child: Text('Identity not generated. Try resetting onboarding.'),
          );
        }

        // Build QR Card payload matching ContactCard schema
        final qrPayload = jsonEncode({
          'peerId': identity.peerId,
          'displayName': identity.displayName,
          'pubKey': identity.pubKey,
          'signPubKey': identity.signPubKey,
          'multiaddrs': <String>[], // listener multiaddresses can be blank, handled by mDNS local discovery
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Card(
                elevation: 8,
                shadowColor: theme.colorScheme.shadow.withAlpha(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    children: [
                      Text(
                        identity.displayName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'P2P Chat Card',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(128),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: QrImageView(
                          data: qrPayload,
                          version: QrVersions.auto,
                          size: 200.0,
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                          dataModuleStyle: QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.circle,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'MY PEER ID',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Text(
                                    identity.peerId,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: identity.peerId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Peer ID copied to clipboard!')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Let your friend scan this card to exchange credentials and establish a secure, end-to-end encrypted connection.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleScannedData(BuildContext context, String rawData) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final repository = ref.read(contactRepositoryProvider);
      final conversation = await repository.addContactFromQr(rawData);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Added contact: ${conversation.displayName}'),
          backgroundColor: Colors.green,
        ),
      );

      if (context.mounted) {
        context.go('/chat/${conversation.id}');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to add contact: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isProcessingScan = false;
      });
      _scannerController.start();
    }
  }
}
