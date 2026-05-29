import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:p2pchat/src/features/onboarding/presentation/screens/welcome_screen.dart';
import 'package:p2pchat/src/features/onboarding/presentation/screens/tutorial_screen.dart';

void main() {
  group('Onboarding Screens Widget Tests', () {
    testWidgets('WelcomeScreen renders key UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      // Verify header and major titles
      expect(find.text('Welcome to P2P Chat'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);

      // Verify highlight features exist
      expect(find.text('End-to-End Encrypted'), findsOneWidget);
      expect(find.text('No Central Server'), findsOneWidget);
      expect(find.text('Cryptographic Identity'), findsOneWidget);
    });

    testWidgets('TutorialScreen page transitions and skip work', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TutorialScreen(),
        ),
      );

      // Slide 1 verification
      expect(find.text('Serverless P2P Network'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.byIcon(Icons.hub_rounded), findsOneWidget);

      // Tap next page button (arrow icon)
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      // Slide 2 verification
      expect(find.text('Direct QR Code Invitation'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);

      // Tap next page button again
      await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
      await tester.pumpAndSettle();

      // Slide 3 verification (Last slide has check icon instead of arrow)
      expect(find.text('Cryptographic Privacy'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
