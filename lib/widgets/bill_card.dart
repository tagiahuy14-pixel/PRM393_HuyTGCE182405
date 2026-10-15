import 'package:flutter/material.dart';

import '../models/bill.dart';

String formatVnd(double value) {
  final text = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write('.');
    buffer.write(text[i]);
  }
  return '${buffer.toString()} VND';
}

class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.bill,
    this.onTap,
    this.compact = false,
  });
  final Bill bill;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final unpaid = bill.status == 'Unpaid';
    final color = unpaid ? const Color(0xFFFF9500) : const Color(0xFF43B65B);
    final icon = switch (bill.category) {
      'Utilities' => Icons.bolt_rounded,
      'Subscription' => Icons.wifi_rounded,
      'Rent' => Icons.home_rounded,
      'Finance' => Icons.account_balance_wallet_rounded,
      'Health' => Icons.health_and_safety_rounded,
      _ => Icons.receipt_long_rounded,
    };
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 11 : 12,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: compact ? 16 : 18,
                backgroundColor: (unpaid
                    ? const Color(0xFFF1E5FF)
                    : const Color(0xFFE4F7E8)),
                child: Icon(
                  icon,
                  size: compact ? 17 : 20,
                  color: unpaid ? const Color(0xFF7C35D8) : color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.billName,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      bill.category,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    if (!compact)
                      Text(
                        'Due: ${bill.dueDate}',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatVnd(bill.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: compact ? 12 : 13,
                      color: unpaid
                          ? const Color(0xFF8A2BE2)
                          : const Color(0xFF6B33C7),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (!compact)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        bill.status,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
