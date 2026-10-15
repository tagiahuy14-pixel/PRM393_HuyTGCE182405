import 'package:flutter_test/flutter_test.dart';
import 'package:recurring_bills_app/models/bill.dart';

void main() {
  test('Bill serializes to and from SQLite map', () {
    const bill = Bill(
      id: 7,
      billName: 'Internet',
      category: 'Utilities',
      amount: 250000,
      status: 'Unpaid',
      dueDate: '2026-10-20',
    );
    expect(Bill.fromMap(bill.toMap()).id, 7);
    expect(Bill.fromMap(bill.toMap()).amount, 250000);
    expect(Bill.fromMap(bill.toMap()).status, 'Unpaid');
  });
}
