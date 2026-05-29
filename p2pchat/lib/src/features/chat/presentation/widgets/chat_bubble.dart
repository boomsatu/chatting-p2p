import 'package:flutter/material.dart';
import '../../../../core/database/database.dart';
import '../../../../core/theme/app_theme.dart';

/// Reusable ChatBubble widget for rendering outgoing and incoming chat bubbles.
class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMine;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isMine ? 64 : 0,
          right: isMine ? 0 : 64,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine
              ? (isDark ? AppTheme.sentBubbleDark : AppTheme.sentBubbleLight)
              : (isDark ? AppTheme.receivedBubbleDark : AppTheme.receivedBubbleLight),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMine ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMine ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMine ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatMessageTime(message.createdAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isMine
                        ? Colors.white.withAlpha(150)
                        : theme.colorScheme.onSurface.withAlpha(100),
                    fontSize: 9,
                  ),
                ),
                if (isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _statusIcon(message.status),
                    size: 14,
                    color: message.status == 'read'
                        ? Colors.blue[300]
                        : Colors.white.withAlpha(180),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'sending':
        return Icons.access_time_rounded;
      case 'sent':
        return Icons.check_rounded;
      case 'delivered':
        return Icons.done_all_rounded;
      case 'read':
        return Icons.done_all_rounded;
      case 'failed':
        return Icons.error_outline_rounded;
      default:
        return Icons.check_rounded;
    }
  }

  String _formatMessageTime(int timestampMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
