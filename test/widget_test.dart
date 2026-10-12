import 'package:flutter_test/flutter_test.dart';
import 'package:slot7/main.dart';

void main() {
  testWidgets('opens create plan and validates an empty title', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('My Planner'), findsOneWidget);
    expect(find.text('No plans yet.\nTap "Create Plan" to add one.'), findsOneWidget);

    await tester.tap(find.text('Create Plan'));
    await tester.pumpAndSettle();

    expect(find.text('Create Plan'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Title is required'), findsOneWidget);
  });
}
