import 'package:flutter_test/flutter_test.dart';
import 'package:tenawise/main.dart';

void main() {
  testWidgets('TenaWiseApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TenaWiseApp());

    // Verify that the title appears.
    expect(find.text('TenaWise'), findsOneWidget);
  });
}
