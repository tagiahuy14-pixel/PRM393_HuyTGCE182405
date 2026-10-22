import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/computer.dart';

class ComputerCard extends StatelessWidget {
  final Computer computer;
  final VoidCallback onTap;

  const ComputerCard({super.key, required this.computer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: computer.isFeaturedBool
              ? Colors.amber.shade400
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: computer.isFeaturedBool ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Product Name + Featured Badge + Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          computer.productName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Brand : ${computer.brandName ?? "Unknown"}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(' • '),
                            Text(
                              'Category : ${computer.categoryName ?? "Unknown"}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormatter.format(computer.price),
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (computer.isFeaturedBool) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade600),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 14),
                              SizedBox(width: 2),
                              Text(
                                'Featured',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const Divider(height: 18),

              // Specs Row: CPU, RAM, Storage
              Row(
                children: [
                  const Icon(Icons.memory, size: 16, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'CPU : ${computer.cpu}',
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.developer_board,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'RAM : ${computer.ram} GB',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.storage,
                          size: 16,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Storage : ${computer.storage} GB',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Stock & Sold row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: computer.stock == 0
                              ? Colors.red.shade100
                              : computer.stock < 5
                              ? Colors.orange.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Stock : ${computer.stock}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: computer.stock == 0
                                ? Colors.red.shade900
                                : computer.stock < 5
                                ? Colors.orange.shade900
                                : Colors.green.shade900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Sold : ${computer.soldQuantity}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
