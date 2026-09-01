import 'package:flutter_test/flutter_test.dart';
import 'package:mydigi_app/main.dart';

void main() {
  testWidgets('MyDigi App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyDigiApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Verify that app exists
    expect(find.byType(MyDigiApp), findsOneWidget);
  });
}
