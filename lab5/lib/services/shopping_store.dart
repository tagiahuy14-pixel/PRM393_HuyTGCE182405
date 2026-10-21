import 'package:flutter/foundation.dart';

import '../models/shopping_item.dart';
import '../utils/currency.dart';
import 'shopping_database.dart';

class ShoppingStore extends ChangeNotifier {
  ShoppingStore(this.database);

  final ShoppingDatabase database;
  List<ShoppingItem> _items = [];
  bool loading = false;
  bool saving = false;
  String? loadError;
  bool _disposed = false;

  List<ShoppingItem> get items => List.unmodifiable(_items);
  List<ShoppingItem> get wishlist =>
      _items.where((item) => item.isWishlist).toList();
  double get wishlistTotal => totalPrices(wishlist.map((item) => item.price));
  ShoppingItem? itemById(int id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    if (loading || saving) return;
    loading = true;
    loadError = null;
    _notify();
    try {
      _items = await database.getItems();
    } catch (error, stack) {
      debugPrint('Loading shopping items failed: $error\n$stack');
      loadError = 'Could not load saved items. Please try again.';
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<T> _write<T>(Future<T> Function() action) async {
    if (saving || loading) {
      throw StateError('Please wait for the current operation');
    }
    saving = true;
    _notify();
    try {
      return await action();
    } finally {
      saving = false;
      _notify();
    }
  }

  Future<ShoppingItem> add(ShoppingItem item) => _write(() async {
    final saved = await database.insert(item);
    _items = [saved, ..._items];
    return saved;
  });

  Future<ShoppingItem> toggle(int id) => _write(() async {
    final current = itemById(id);
    if (current == null) throw StateError('Item no longer exists');
    final updated = current.copyWith(
      status: current.isWishlist
          ? ShoppingItem.purchased
          : ShoppingItem.wishlist,
    );
    await database.updateStatus(id, updated.status);
    _items = _items.map((item) => item.id == id ? updated : item).toList();
    return updated;
  });

  Future<void> delete(int id) => _write(() async {
    await database.delete(id);
    _items = _items.where((item) => item.id != id).toList();
  });

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
