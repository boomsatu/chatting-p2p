import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/onboarding/presentation/screens/generate_keys_screen.dart';
import '../../features/onboarding/presentation/screens/setup_profile_screen.dart';
import '../../features/onboarding/presentation/screens/tutorial_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/add_contact_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/generate-keys',
      builder: (context, state) => const GenerateKeysScreen(),
    ),
    GoRoute(
      path: '/setup-profile',
      builder: (context, state) => const SetupProfileScreen(),
    ),
    GoRoute(
      path: '/tutorial',
      builder: (context, state) => const TutorialScreen(),
    ),
    GoRoute(
      path: '/chats',
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/add-contact',
      builder: (context, state) => const AddContactScreen(),
    ),
    GoRoute(
      path: '/chat/:conversationId',
      builder: (context, state) {
        final conversationId = state.pathParameters['conversationId']!;
        return ChatScreen(conversationId: conversationId);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
