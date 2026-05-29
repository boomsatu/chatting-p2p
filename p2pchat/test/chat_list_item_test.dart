import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2pchat/src/core/database/database.dart';
import 'package:p2pchat/src/features/chat/presentation/widgets/chat_list_item.dart';

void main() {
  testWidgets('Should display conversation details, initials, and unread badge in ChatListItem', (WidgetTester tester) async {
    // 1. Arrange a mock Conversation object
    final conversation = Conversation(
      id: 99,
      type: 'dm',
      topic: 'dm:peer_alice:peer_bob',
      targetId: 'peer_bob',
      displayName: 'Bob Builder',
      lastMessage: 'Yes we can!',
      lastMessageAt: DateTime.now().millisecondsSinceEpoch,
      unreadCount: 3,
      muted: 0,
      archived: 0,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    bool isTapped = false;

    // 2. Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChatListItem(
            conversation: conversation,
            onTap: () {
              isTapped = true;
            },
          ),
        ),
      ),
    );

    // 3. Assert Display Name & Message Content
    expect(find.text('Bob Builder'), findsOneWidget);
    expect(find.text('Yes we can!'), findsOneWidget);

    // 4. Assert Initial Letter Avatar
    expect(find.text('B'), findsOneWidget);

    // 5. Assert Unread Count Badge
    expect(find.text('3'), findsOneWidget);

    // 6. Assert Tap Callback Action
    await tester.tap(find.byType(ChatListItem));
    expect(isTapped, isTrue);
  });
}
