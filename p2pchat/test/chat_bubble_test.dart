import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2pchat/src/core/database/database.dart';
import 'package:p2pchat/src/features/chat/presentation/widgets/chat_bubble.dart';

void main() {
  testWidgets('Should display chat bubble content and status icons correctly', (WidgetTester tester) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Outgoing Read Message
    final messageRead = Message(
      id: 'msg_1',
      conversationId: 99,
      senderPeerId: 'my_peer_id',
      content: 'Hello, this is a bubble!',
      contentType: 'text',
      status: 'read',
      isMine: 1, // Mine
      createdAt: now,
      updatedAt: now,
    );

    // 2. Pump widget (outgoing)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatBubble(
            message: messageRead,
            isMine: true,
          ),
        ),
      ),
    );

    // 3. Verify content & read checkmarks
    expect(find.text('Hello, this is a bubble!'), findsOneWidget);
    expect(find.byIcon(Icons.done_all_rounded), findsOneWidget); // Read double check

    // 4. Outgoing Failed Message
    final messageFailed = Message(
      id: 'msg_2',
      conversationId: 99,
      senderPeerId: 'my_peer_id',
      content: 'Failed message packet',
      contentType: 'text',
      status: 'failed',
      isMine: 1,
      createdAt: now,
      updatedAt: now,
    );

    // 5. Pump failed message widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatBubble(
            message: messageFailed,
            isMine: true,
          ),
        ),
      ),
    );

    // 6. Verify error icon is displayed
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });
}
