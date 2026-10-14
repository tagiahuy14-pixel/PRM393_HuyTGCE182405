import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_dashboard_app/main.dart';

void main() {
  testWidgets('dashboard opens product grid and returns with back', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Hello, User 👋'), findsOneWidget);
    expect(find.text('Welcome to Simple Product Dashboard'), findsOneWidget);
    expect(find.byIcon(Icons.notifications), findsOneWidget);

    await tester.tap(find.text('Xem danh sách sản phẩm'));
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Product #0'), findsOneWidget);
    expect(find.text('\$10.00'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(10));

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });
}
