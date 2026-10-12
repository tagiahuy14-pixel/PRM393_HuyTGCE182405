import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:slot6/main.dart';

void main() {
  testWidgets('student selection toggles independently', (tester) async {
    await tester.pumpWidget(const StudentListApp());

    expect(find.text('Student List'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(5));
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(5));

    await tester.tap(find.text('Nguyễn Văn A'));
    await tester.pump();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(4));

    await tester.tap(find.text('Nguyễn Văn A'));
    await tester.pump();

    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(5));
  });
}
