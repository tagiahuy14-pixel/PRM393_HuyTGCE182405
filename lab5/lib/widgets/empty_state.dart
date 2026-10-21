import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.wishlist = false});
  final bool wishlist;

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            wishlist ? Icons.favorite_border : Icons.shopping_cart_outlined,
            size: 58,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            wishlist ? 'Your wishlist is empty' : 'No shopping items yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            wishlist
                ? 'Add a Wishlist item or move a purchased item back.'
                : 'Tap + to add your favorite shopping items.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    ),
  );
}
