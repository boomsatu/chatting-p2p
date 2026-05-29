import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/providers/core_providers.dart';
import 'src/rust/frb_generated.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize flutter_rust_bridge
  await RustLib.init();

  runApp(const ProviderScope(child: P2PChatApp()));
}

class P2PChatApp extends ConsumerWidget {
  const P2PChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Eagerly initialize the GossipSub incoming message listener and presence timers
    ref.watch(chatRepositoryProvider);
    ref.watch(presenceServiceProvider);

    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'P2P Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
