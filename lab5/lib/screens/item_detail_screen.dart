import 'package:flutter/material.dart';

import '../services/shopping_store.dart';
import '../theme.dart';
import '../utils/currency.dart';
import '../widgets/feedback_dialog.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.store,
    required this.itemId,
  });
  final ShoppingStore store;
  final int itemId;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _busy = false;

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final updated = await widget.store.toggle(widget.itemId);
      if (mounted) {
        await showFeedback(
          context,
          updated.isWishlist
              ? 'Item moved to Wishlist'
              : 'Item marked as Purchased',
        );
      }
    } catch (error, stack) {
      debugPrint('Updating item failed: $error\n$stack');
      if (mounted) {
        await showFeedback(
          context,
          'Could not update the status. Please try again.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (_busy) return;
    setState(() => _busy = true);
    final item = widget.store.itemById(widget.itemId);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete "${item?.itemName ?? 'this item'}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            key: const Key('confirm-delete'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: appRed)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed != true) {
      setState(() => _busy = false);
      return;
    }
    try {
      await widget.store.delete(widget.itemId);
      if (mounted) Navigator.pop(context, true);
    } catch (error, stack) {
      debugPrint('Deleting item failed: $error\n$stack');
      if (mounted) {
        await showFeedback(
          context,
          'Could not delete the item. Please try again.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, child) {
      final item = widget.store.itemById(widget.itemId);
      final blocked = _busy || widget.store.saving || widget.store.loading;
      return PopScope(
        canPop: !_busy,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Item Details'),
            automaticallyImplyLeading: !_busy,
          ),
          body: SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (item == null)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('This item is no longer available.'),
                          ),
                        )
                      else
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.itemName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Detail Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _detail(Icons.key, 'ID', '#${item.id}'),
                                _detail(
                                  Icons.grid_view,
                                  'Category',
                                  item.category,
                                ),
                                _detail(
                                  Icons.payments_outlined,
                                  'Price',
                                  formatVnd(item.price),
                                  color: appPurple,
                                ),
                                _detail(
                                  Icons.flag_outlined,
                                  'Status',
                                  item.status,
                                  color: item.isWishlist ? appOrange : appGreen,
                                ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                      if (_busy && widget.store.saving)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: LinearProgressIndicator(),
                        ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _action(
                              'toggle-status',
                              item?.isWishlist == false
                                  ? 'Move to Wishlist'
                                  : 'Mark Purchased',
                              Icons.swap_horiz,
                              appOrange,
                              blocked || item == null ? null : _toggle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _action(
                              'delete-item',
                              'Delete',
                              Icons.delete,
                              appRed,
                              blocked || item == null ? null : _delete,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _action(
                              'back-home',
                              'Back',
                              Icons.arrow_back,
                              Colors.grey,
                              blocked ? null : () => Navigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  Widget _detail(IconData icon, String label, String value, {Color? color}) =>
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.grey, size: 21),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  flex: 2,
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      );

  Widget _action(
    String key,
    String label,
    IconData icon,
    Color color,
    VoidCallback? onPressed,
  ) => FilledButton(
    key: Key(key),
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
      minimumSize: const Size(48, 90),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    ),
  );
}
