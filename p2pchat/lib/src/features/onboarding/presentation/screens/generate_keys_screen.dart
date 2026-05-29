import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/dao/identity_dao.dart';
import 'package:drift/drift.dart' show Value;
import 'package:p2pchat/src/rust/api/crypto_api.dart' as crypto_api;

/// Generate Keys screen — creates the cryptographic identity with an animation
class GenerateKeysScreen extends ConsumerStatefulWidget {
  const GenerateKeysScreen({super.key});

  @override
  ConsumerState<GenerateKeysScreen> createState() => _GenerateKeysScreenState();
}

class _GenerateKeysScreenState extends ConsumerState<GenerateKeysScreen>
    with TickerProviderStateMixin {
  bool _isGenerating = false;
  bool _isDone = false;
  String? _peerId;
  String? _error;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _generateKeys() async {
    setState(() {
      _isGenerating = true;
      _error = null;
    });
    _pulseController.repeat(reverse: true);

    try {
      // Call Rust to generate the identity
      final identity = await crypto_api.generateIdentity();

      // Store the seed in secure storage
      final keystoreService = ref.read(keystoreServiceProvider);
      await keystoreService.storeIdentitySeed(identity.seed);

      // Activate the identity in the Rust keystore
      await crypto_api.setActiveIdentity(seed: identity.seed);

      // Save keys directly to Drift database
      final db = ref.read(databaseProvider);
      final identityDao = IdentityDao(db);
      await identityDao.insertOrUpdateIdentity(IdentityCompanion(
        id: const Value(1),
        peerId: Value(identity.peerId),
        pubKey: Value(identity.boxPubkey),
        signPubKey: Value(identity.signingPubkey),
        displayName: const Value('Me'), // placeholder, updated in next screen
        createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      ));

      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _isDone = true;
        _peerId = identity.peerId;
      });
      _pulseController.stop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _error = e.toString();
      });
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Animated key icon
              ScaleTransition(
                scale: _isGenerating ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isDone
                          ? [Colors.green.shade400, Colors.green.shade700]
                          : [theme.colorScheme.primary, theme.colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: (_isDone ? Colors.green : theme.colorScheme.primary)
                            .withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isDone ? Icons.check_rounded : Icons.vpn_key_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                _isDone
                    ? 'Identity Created!'
                    : _isGenerating
                        ? 'Generating Keys...'
                        : 'Create Your Identity',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (_isDone && _peerId != null) ...[
                Text(
                  'Your Peer ID:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    _peerId!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ] else if (_error != null)
                Text(
                  'Error: $_error',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                )
              else if (!_isGenerating)
                Text(
                  'We\'ll generate a unique cryptographic keypair that serves as your identity. '
                  'No email, phone number, or account needed.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _isGenerating
                      ? null
                      : _isDone
                          ? () => context.go('/setup-profile')
                          : _generateKeys,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isDone ? 'Continue' : 'Generate Keys',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
