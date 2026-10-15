import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/bill.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await openDatabase(
      join(await getDatabasesPath(), 'recurring_bills.db'),
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE bills (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bill_name TEXT NOT NULL,
          category TEXT NOT NULL,
          amount REAL NOT NULL,
          status TEXT NOT NULL DEFAULT 'Unpaid',
          due_date TEXT NOT NULL
        )
      '''),
    );
    return _database!;
  }

  Future<int> insertBill(Bill bill) async {
    final db = await database;
    final values = bill.toMap()..remove('id');
    return db.insert('bills', values);
  }

  Future<List<Bill>> getAllBills() async {
    final db = await database;
    final rows = await db.query('bills', orderBy: 'due_date ASC, id DESC');
    return rows.map(Bill.fromMap).toList();
  }

  Future<Bill?> getBillById(int id) async {
    final db = await database;
    final rows = await db.query('bills', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : Bill.fromMap(rows.first);
  }

  Future<int> updateBill(Bill bill) async {
    if (bill.id == null) {
      throw ArgumentError('A bill ID is required for update.');
    }
    final db = await database;
    final values = bill.toMap()..remove('id');
    return db.update('bills', values, where: 'id = ?', whereArgs: [bill.id]);
  }

  Future<int> deleteBill(int id) async {
    final db = await database;
    return db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Bill>> getUnpaidBills() async {
    final db = await database;
    final rows = await db.query(
      'bills',
      where: 'status = ?',
      whereArgs: ['Unpaid'],
      orderBy: 'due_date ASC',
    );
    return rows.map(Bill.fromMap).toList();
  }

  Future<double> getUnpaidTotal() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM bills WHERE status = ?',
      ['Unpaid'],
    );
    return (result.first['total'] as num).toDouble();
  }
}
