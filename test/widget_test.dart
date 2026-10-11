import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:live_counter_stream/main.dart';

void main() {
  testWidgets('shows the live counter screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Live Counter Stream'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
