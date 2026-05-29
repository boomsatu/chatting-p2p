import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/database/database.dart';
import '../../../../core/database/dao/messages_dao.dart';
import '../../../../core/database/dao/conversations_dao.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/chat_input.dart';

/// Chat screen — DM conversation view with messages and input
class ChatScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = ref.watch(databaseProvider);
    final messagesDao = MessagesDao(db);
    final conversationsDao = ConversationsDao(db);
    final chatRepository = ref.watch(chatRepositoryProvider);
    final conversationId = int.tryParse(widget.conversationId) ?? 0;

    return FutureBuilder<Conversation?>(
      future: conversationsDao.getConversation(conversationId),
      builder: (context, convoSnapshot) {
        final convo = convoSnapshot.data;
        final title = convo?.displayName ?? 'Chat';
        final targetPeerId = convo?.targetId ?? '';

        return Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                onPressed: () {
                  // TODO: Show contact / chat info
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Message list
              Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: messagesDao.watchMessagesForConversation(conversationId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data ?? [];

                    if (messages.isEmpty) {
                      return Center(
                        child: Text(
                          'No messages yet.\nSay hello! 👋',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(100),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMine = msg.isMine == 1;
                        return ChatBubble(message: msg, isMine: isMine);
                      },
                    );
                  },
                ),
              ),
              // Input bar
              ChatInput(
                controller: _messageController,
                onSend: () {
                  final text = _messageController.text.trim();
                  if (text.isEmpty || targetPeerId.isEmpty) return;
                  
                  // Wire directly to our secure encryption/signature FFI GossipSub pipeline!
                  chatRepository.sendDM(targetPeerId: targetPeerId, content: text);
                  
                  _messageController.clear();
                  
                  // Smoothly scroll to bottom on send
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent + 60,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
