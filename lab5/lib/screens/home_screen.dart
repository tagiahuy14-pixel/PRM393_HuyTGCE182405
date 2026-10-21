import 'package:flutter/material.dart';

import '../models/shopping_item.dart';
import '../services/shopping_store.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/feedback_dialog.dart';
import '../widgets/shopping_item_card.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';
import 'wishlist_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.store});
  final ShoppingStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  Future<void> _add() async {
    final item = await Navigator.push<ShoppingItem>(
      context,
      MaterialPageRoute(builder: (_) => AddItemScreen(store: widget.store)),
    );
    if (!mounted || item == null) return;
    setState(() => _tab = 0);
    await showFeedback(
      context,
      'Added "${item.itemName}" to ${item.isWishlist ? 'wishlist' : 'purchased items'}',
    );
  }

  Future<void> _detail(ShoppingItem item) async {
    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(store: widget.store, itemId: item.id!),
      ),
    );
    if (!mounted) return;
    setState(() => _tab = 0);
    if (deleted != true) return;
    await showFeedback(context, 'Item deleted');
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, child) {
      final store = widget.store;
      return Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  if (store.loadError != null)
                    MaterialBanner(
                      content: Text(store.loadError!),
                      leading: const Icon(Icons.error_outline, color: appRed),
                      actions: [
                        TextButton(
                          onPressed: store.load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  if (store.loading) const LinearProgressIndicator(),
                  Expanded(
                    child: _tab == 0
                        ? _home(store)
                        : WishlistScreen(store: store, onItemTap: _detail),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _tab == 0
            ? FloatingActionButton(
                onPressed:
                    store.loading || store.saving || store.loadError != null
                    ? null
                    : _add,
                tooltip: 'Add Item',
                backgroundColor: appPurple,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(Icons.add),
              )
            : null,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (value) => setState(() => _tab = value),
          selectedItemColor: appPurple,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Wishlist',
            ),
          ],
        ),
      );
    },
  );

  Widget _home(ShoppingStore store) => Column(
    children: [
      _Banner(count: store.items.length),
      Expanded(
        child: store.items.isEmpty
            ? store.loading
                  ? const SizedBox.shrink()
                  : const EmptyState()
            : RefreshIndicator(
                onRefresh: store.load,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 90),
                  itemCount: store.items.length,
                  itemBuilder: (context, index) {
                    final item = store.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ShoppingItemCard(
                        key: ValueKey('item-${item.id}'),
                        item: item,
                        onTap: () => _detail(item),
                      ),
                    );
                  },
                ),
              ),
      ),
    ],
  );
}

class _Banner extends StatelessWidget {
  const _Banner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.bottomLeft,
    children: [
      Image.asset(
        'assets/images/shopping_banner.png',
        width: double.infinity,
        height: 148,
        fit: BoxFit.cover,
        excludeFromSemantics: true,
        errorBuilder: (_, error, stack) => Container(
          height: 148,
          width: double.infinity,
          color: const Color(0xFFFFE6CF),
          alignment: Alignment.topRight,
          padding: const EdgeInsets.all(16),
          child: const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Color(0xFF76C6B3),
          ),
        ),
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: const Color(0xFF625D55),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favorite Shopping Items',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count ${count == 1 ? 'item' : 'items'}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    ],
  );
}
