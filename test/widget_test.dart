import 'package:flutter_test/flutter_test.dart';
import 'package:waddah/main.dart';

void main() {
  testWidgets('App should build successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WaddahApp());

    // Verify that WaddahApp builds successfully.
    expect(find.byType(WaddahApp), findsOneWidget);
  });
}
