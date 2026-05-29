import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2pchat/src/features/chat/presentation/widgets/chat_input.dart';

void main() {
  testWidgets('ChatInput Widget Tests', (WidgetTester tester) async {
    final controller = TextEditingController();
    bool sendTriggered = false;

    // 1. Pump ChatInput widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ChatInput(
                controller: controller,
                onSend: () {
                  sendTriggered = true;
                },
              ),
            ],
          ),
        ),
      ),
    );

    // 2. Verify layout
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Type a message...'), findsOneWidget);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);

    // 3. Test text editing and callback execution
    await tester.enterText(find.byType(TextField), 'Test message');
    expect(controller.text, 'Test message');

    // 4. Tap the send button
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    expect(sendTriggered, isTrue);
  });
}
