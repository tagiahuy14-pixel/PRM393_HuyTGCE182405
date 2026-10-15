import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/bill.dart';
import '../widgets/bill_card.dart';

class UnpaidSummaryScreen extends StatefulWidget {
  const UnpaidSummaryScreen({super.key});
  @override
  State<UnpaidSummaryScreen> createState() => UnpaidSummaryScreenState();
}

class UnpaidSummaryScreenState extends State<UnpaidSummaryScreen> {
  late Future<_UnpaidData> _data;

  @override
  void initState() {
    super.initState();
    _data = _loadData();
  }

  Future<_UnpaidData> _loadData() async {
    final results = await Future.wait([
      DatabaseHelper.instance.getUnpaidBills(),
      DatabaseHelper.instance.getUnpaidTotal(),
    ]);
    return _UnpaidData(results[0] as List<Bill>, results[1] as double);
  }

  void reload() {
    setState(() {
      _data = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FutureBuilder<_UnpaidData>(
      future: _data,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Could not load unpaid bills. Please try again.'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final bills = snapshot.data!.bills;
        final total = snapshot.data!.total;
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 26, 16, 14),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFFFF0D5),
                    child: const Icon(
                      Icons.priority_high_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unpaid Bills',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${bills.length} bill${bills.length == 1 ? '' : 's'} unpaid',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            if (bills.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: Text('No unpaid bills. Great job!')),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                child: Column(
                  children: bills
                      .map((bill) => BillCard(bill: bill, compact: true))
                      .toList(),
                ),
              ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(10, 6, 10, 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFAB3D), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.receipt_long, color: Color(0xFF6200EE)),
                      SizedBox(width: 8),
                      Text(
                        'Outstanding Summary',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(),
                  Text('Number of unpaid bills: ${bills.length}'),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total outstanding:'),
                      Text(
                        formatVnd(total),
                        style: const TextStyle(
                          color: Color(0xFFFF8A00),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _UnpaidData {
  const _UnpaidData(this.bills, this.total);
  final List<Bill> bills;
  final double total;
}
