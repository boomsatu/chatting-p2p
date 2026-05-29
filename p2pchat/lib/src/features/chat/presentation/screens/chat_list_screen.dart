import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/dao/conversations_dao.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/chat_list_item.dart';

/// Chat list screen — shows all conversations sorted by last message time
class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);
    final conversationsDao = ConversationsDao(db);

    return Scaffold(
      appBar: AppBar(
        title: const Text('P2P Chat', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () => context.push('/add-contact'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: conversationsDao.watchAllConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 80,
                    color: theme.colorScheme.onSurface.withAlpha(50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(100),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan a QR code to add a contact\nand start chatting.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(76),
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final convo = conversations[index];
              return ChatListItem(
                conversation: convo,
                onTap: () => context.go('/chat/${convo.id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-contact'),
        child: const Icon(Icons.qr_code_scanner_rounded),
      ),
    );
  }
}
