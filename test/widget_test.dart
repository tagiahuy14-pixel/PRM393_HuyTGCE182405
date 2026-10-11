import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:slot4/main.dart';

void main() {
  testWidgets('shows a loading indicator then the product list', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('T\u00e1o'), findsOneWidget);
    expect(find.text('Cam'), findsOneWidget);
    expect(find.text('Chu\u1ed1i'), findsOneWidget);
    expect(find.text('10000 VND'), findsOneWidget);
  });
}
