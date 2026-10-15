import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/bill.dart';
import '../widgets/bill_banner.dart';
import '../widgets/bill_card.dart';
import 'add_bill_screen.dart';
import 'update_bill_screen.dart';

class BillsListScreen extends StatefulWidget {
  const BillsListScreen({super.key, required this.onChanged});
  final VoidCallback onChanged;
  @override
  State<BillsListScreen> createState() => BillsListScreenState();
}

class BillsListScreenState extends State<BillsListScreen> {
  late Future<List<Bill>> _bills;
  @override
  void initState() {
    super.initState();
    _bills = DatabaseHelper.instance.getAllBills();
  }

  void reload() {
    setState(() {
      _bills = DatabaseHelper.instance.getAllBills();
    });
  }

  Future<void> _open(Widget page) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (changed == true) {
      reload();
      widget.onChanged();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: () => _open(const AddBillScreen()),
      backgroundColor: const Color(0xFF6200EE),
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
      child: const Icon(Icons.add),
    ),
    body: FutureBuilder<List<Bill>>(
      future: _bills,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Could not load bills. Please try again.'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final bills = snapshot.data!;
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _HomeHeader()),
            if (bills.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 58,
                          color: Color(0xFF777777),
                        ),
                        SizedBox(height: 8),
                        Text('No bills yet'),
                        Text(
                          'Press \'+\' button to add your recurring bills',
                          style: TextStyle(color: Color(0xFF888888)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 84),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => BillCard(
                      bill: bills[index],
                      onTap: () => _open(UpdateBillScreen(bill: bills[index])),
                    ),
                    childCount: bills.length,
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const BillBanner(),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: Container(
          height: 42,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: const Color(0xB34B4747),
          child: const Text(
            'Recurring Bills',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    ],
  );
}
