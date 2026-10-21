import 'package:flutter/material.dart';

import '../models/shopping_item.dart';
import '../services/shopping_store.dart';
import '../theme.dart';
import '../utils/currency.dart';
import '../widgets/empty_state.dart';
import '../widgets/shopping_item_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({
    super.key,
    required this.store,
    required this.onItemTap,
  });
  final ShoppingStore store;
  final ValueChanged<ShoppingItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final items = store.wishlist;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxHeight < 600 ||
            MediaQuery.textScalerOf(context).scale(14) > 21) {
          return RefreshIndicator(
            onRefresh: store.load,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              itemCount: items.isEmpty ? 3 : items.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) return _header(items.length);
                if (index == (items.isEmpty ? 2 : items.length + 1)) {
                  return _Estimate(
                    count: items.length,
                    total: store.wishlistTotal,
                  );
                }
                if (items.isEmpty) return const EmptyState(wishlist: true);
                final item = items[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ShoppingItemCard(
                    item: item,
                    number: index,
                    onTap: () => onItemTap(item),
                  ),
                );
              },
            ),
          );
        }
        return Column(
          children: [
            Container(height: 3, color: appPurple),
            _header(items.length),
            Expanded(
              child: items.isEmpty
                  ? const EmptyState(wishlist: true)
                  : RefreshIndicator(
                      onRefresh: store.load,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: items.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ShoppingItemCard(
                            item: items[index],
                            number: index + 1,
                            onTap: () => onItemTap(items[index]),
                          ),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: _Estimate(count: items.length, total: store.wishlistTotal),
            ),
          ],
        );
      },
    );
  }

  Widget _header(int count) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Column(
      children: [
        const CircleAvatar(
          radius: 26,
          backgroundColor: Color(0xFFFFF0DC),
          child: Icon(Icons.favorite, color: appOrange, size: 30),
        ),
        const SizedBox(height: 8),
        const Text(
          'Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        Text(
          '$count ${count == 1 ? 'item' : 'items'} in wishlist',
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    ),
  );
}

class _Estimate extends StatelessWidget {
  const _Estimate({required this.count, required this.total});
  final int count;
  final double total;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: appOrange, width: 1.5),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Row(
          children: [
            Icon(Icons.calculate, color: appPurple),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Total Estimate',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
        const Divider(height: 24),
        _line('Number of items:', '$count'),
        const SizedBox(height: 10),
        _line('Total cost:', formatVnd(total), highlight: true),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFF5F5F5),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info, size: 14, color: Colors.grey),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'This is the estimated total for items you want to buy',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _line(String label, String value, {bool highlight = false}) => Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(color: Colors.black54)),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          key: highlight ? const Key('wishlist-total') : null,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: highlight ? appOrange : Colors.black87,
          ),
        ),
      ),
    ],
  );
}
