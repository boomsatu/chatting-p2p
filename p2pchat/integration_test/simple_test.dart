import 'package:flutter_test/flutter_test.dart';
import 'package:p2pchat/main.dart';
import 'package:p2pchat/src/rust/frb_generated.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async => await RustLib.init());
  testWidgets('Can call rust function', (WidgetTester tester) async {
    await tester.pumpWidget(const P2PChatApp());
    // Splash screen should appear
    expect(find.text('P2P Chat'), findsOneWidget);
  });
}
