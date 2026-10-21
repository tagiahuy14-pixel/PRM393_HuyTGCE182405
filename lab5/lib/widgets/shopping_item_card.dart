import 'package:flutter/material.dart';

import '../models/shopping_item.dart';
import '../theme.dart';
import '../utils/currency.dart';

IconData categoryIcon(String category) => switch (category) {
  'Fashion' => Icons.checkroom_outlined,
  'Electronics' => Icons.phone_android,
  'Home' => Icons.chair_outlined,
  _ => Icons.shopping_bag_outlined,
};

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.item});
  final ShoppingItem item;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: item.isWishlist ? appOrange : appGreen,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      item.status,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class ShoppingItemCard extends StatelessWidget {
  const ShoppingItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.number,
  });
  final ShoppingItem item;
  final VoidCallback onTap;
  final int? number;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (number != null) ...[
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: appOrange,
                    child: Text(
                      '$number',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                CircleAvatar(
                  radius: 19,
                  backgroundColor: const Color(0xFFF4ECFF),
                  child: Icon(
                    categoryIcon(item.category),
                    color: appPurple,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item.category,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black38,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatVnd(item.price),
                    style: TextStyle(
                      color: number == null ? appPurple : appOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (number == null) ...[
                  const SizedBox(width: 8),
                  StatusBadge(item: item),
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
