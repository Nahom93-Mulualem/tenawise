import 'package:flutter_test/flutter_test.dart';
import 'package:tenawise/main.dart';
import 'package:tenawise/core/widgets/tactile_card.dart';
import 'package:tenawise/core/widgets/staggered_entrance.dart';

void main() {
  testWidgets('TenaWiseApp smoke test verifies new tactile & staggered UI',
      (WidgetTester tester) async {
    // Build our app and trigger frames.
    await tester.pumpWidget(const TenaWiseApp());
    await tester.pump(const Duration(milliseconds: 600));

    // Verify header title appears
    expect(find.text('TenaWise'), findsOneWidget);

    // Verify new StaggeredEntrance widgets exist in widget tree
    expect(find.byType(StaggeredEntrance), findsWidgets);

    // Verify new TactileCard widgets exist in widget tree
    expect(find.byType(TactileCard), findsWidgets);

    // Verify headline appears
    expect(
      find.text('Your health, your choice, your safe space.'),
      findsOneWidget,
    );
  });
}
