import 'package:flutter/material.dart';

import 'bills_list_screen.dart';
import 'unpaid_summary_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final _homeKey = GlobalKey<BillsListScreenState>();
  final _summaryKey = GlobalKey<UnpaidSummaryScreenState>();

  void _selectTab(int value) {
    setState(() => _index = value);
    if (value == 0) _homeKey.currentState?.reload();
    if (value == 1) _summaryKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _index,
      children: [
        BillsListScreen(
          key: _homeKey,
          onChanged: () => _summaryKey.currentState?.reload(),
        ),
        UnpaidSummaryScreen(key: _summaryKey),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _index,
      onTap: _selectTab,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Unpaid',
        ),
      ],
    ),
  );
}
