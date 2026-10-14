import 'package:flutter/material.dart';

import '../widgets/responsive_grid.dart';
import '../widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(title: const Text('Responsive Dashboard')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              _Header(),
              SizedBox(height: 16),
              _SummarySection(),
              SizedBox(height: 24),
              ResponsiveProductGrid(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = (screenWidth * 0.06).clamp(20, 32).toDouble();

    return Text(
      'Dashboard',
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isNarrow = constraints.maxWidth < 600;
        final List<SummaryCard> cards = <SummaryCard>[
          const SummaryCard(
            title: 'Revenue',
            value: r'$12,300',
            color: Colors.blue,
          ),
          const SummaryCard(title: 'Orders', value: '320', color: Colors.green),
          const SummaryCard(
            title: 'Customers',
            value: '89',
            color: Colors.purple,
          ),
        ];

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              cards[0],
              SizedBox(height: 12),
              cards[1],
              SizedBox(height: 12),
              cards[2],
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: cards[0]),
            SizedBox(width: 12),
            Expanded(child: cards[1]),
            SizedBox(width: 12),
            Expanded(child: cards[2]),
          ],
        );
      },
    );
  }
}
