import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('can navigate from home to student list', (tester) async {
    await tester.pumpWidget(const StudentManagerApp());

    await tester.tap(find.text('Xem danh sách sinh viên'));
    await tester.pumpAndSettle();

    expect(find.text('Danh sách sinh viên'), findsOneWidget);
    expect(find.text('Nguyễn Văn A'), findsOneWidget);
    expect(find.text('Trần Thị B'), findsOneWidget);
    expect(find.text('Lê Văn C'), findsOneWidget);
  });

  testWidgets('form validates and adds a student', (tester) async {
    await tester.pumpWidget(const StudentManagerApp());
    await tester.tap(find.text('Xem danh sách sinh viên'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lưu'));
    await tester.pump();
    expect(find.text('Vui lòng nhập mã sinh viên'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).at(0), 'S004');
    await tester.enterText(find.byType(EditableText).at(1), 'Phạm Thị D');
    await tester.enterText(find.byType(EditableText).at(2), '22');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(find.text('Phạm Thị D'), findsOneWidget);
  });
}
