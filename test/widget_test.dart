import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_dashboard/main.dart';
import 'package:responsive_dashboard/widgets/summary_card.dart';

void main() {
  Future<void> pumpDashboard(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ResponsiveDashboardApp());
    await tester.pump();
  }

  testWidgets('uses a vertical summary layout and two grid columns on mobile', (
    WidgetTester tester,
  ) async {
    await pumpDashboard(tester, const Size(320, 568));

    expect(find.text('Revenue'), findsOneWidget);
    expect(find.textContaining('2 columns'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Column &&
            widget.children.whereType<SummaryCard>().length == 3,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('remains scrollable with two grid columns on a standard phone', (
    WidgetTester tester,
  ) async {
    await pumpDashboard(tester, const Size(390, 844));

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.textContaining('2 columns'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses three grid columns at tablet width', (
    WidgetTester tester,
  ) async {
    await pumpDashboard(tester, const Size(800, 1280));

    expect(find.textContaining('3 columns'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Row && widget.children.whereType<Expanded>().length == 3,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'uses four grid columns and configures twelve products on wide screens',
    (WidgetTester tester) async {
      await pumpDashboard(tester, const Size(1200, 800));

      expect(find.textContaining('4 columns'), findsOneWidget);
      final GridView gridView = tester.widget<GridView>(find.byType(GridView));
      final SliverChildBuilderDelegate delegate =
          gridView.childrenDelegate as SliverChildBuilderDelegate;
      expect(delegate.childCount, 12);
      expect(tester.takeException(), isNull);
    },
  );
}
