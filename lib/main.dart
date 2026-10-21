import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

const _purple = Color(0xFF651FFF);
const _orange = Color(0xFFFF9200);
const _green = Color(0xFF45B854);

class ShoppingItem {
  ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.purchased = false,
  });

  final int id;
  final String name;
  final String category;
  final int price;
  bool purchased;
}

class WishlistApp extends StatelessWidget {
  const WishlistApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Shopping Wishlist',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _purple),
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
        ),
      ),
    ),
    home: const WishlistHome(),
  );
}

/// Conventional root-widget name retained for Flutter test and IDE templates.
class MyApp extends WishlistApp {
  const MyApp({super.key});
}

class WishlistHome extends StatefulWidget {
  const WishlistHome({super.key});

  @override
  State<WishlistHome> createState() => _WishlistHomeState();
}

class _WishlistHomeState extends State<WishlistHome> {
  final List<ShoppingItem> _items = [];
  int _selectedTab = 0;
  int _nextId = 1;

  Future<void> _addItem() async {
    final item = await Navigator.push<ShoppingItem>(
      context,
      MaterialPageRoute(builder: (_) => AddItemScreen(id: _nextId)),
    );
    if (item == null || !mounted) return;
    setState(() {
      _items.add(item);
      _nextId++;
    });
    _showMessage('Added "${item.name}" to wishlist');
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );

  Future<void> _openDetail(ShoppingItem item) async {
    final action = await Navigator.push<_ItemAction>(
      context,
      MaterialPageRoute(builder: (_) => ItemDetailScreen(item: item)),
    );
    if (!mounted || action == null) return;
    if (action == _ItemAction.deleted) {
      setState(() => _items.remove(item));
      _showMessage('Item deleted');
    } else if (action == _ItemAction.toggled) {
      setState(() => item.purchased = !item.purchased);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isHome = _selectedTab == 0;
    return Scaffold(
      body: SafeArea(child: isHome ? _homeBody() : _wishlistBody()),
      floatingActionButton: isHome
          ? FloatingActionButton(
              onPressed: _addItem,
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        height: 64,
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        indicatorColor: const Color(0xFFEDE2FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
        ],
      ),
    );
  }

  Widget _homeBody() => Column(
    children: [
      const _HeroHeader(),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        color: const Color(0xFF5B554F),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favorite Shopping Items',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_items.isNotEmpty)
              Text(
                '${_items.length} items',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
      ),
      Expanded(
        child: _items.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (_, index) => _ItemCard(
                  item: _items[index],
                  onTap: () => _openDetail(_items[index]),
                ),
              ),
      ),
    ],
  );

  Widget _wishlistBody() {
    final wished = _items.where((item) => !item.purchased).toList();
    final total = wished.fold<int>(0, (sum, item) => sum + item.price);
    return Column(
      children: [
        Container(height: 3, color: _purple),
        const SizedBox(height: 18),
        const CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFFFFF0D9),
          child: Icon(Icons.favorite, color: _orange, size: 32),
        ),
        const SizedBox(height: 9),
        const Text(
          'Wishlist',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          '${wished.length} items in wishlist',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 15),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            children: [
              ...wished.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _WishlistCard(
                    number: entry.key + 1,
                    item: entry.value,
                    onTap: () => _openDetail(entry.value),
                  ),
                ),
              ),
              _EstimateCard(count: wished.length, total: total),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();
  @override
  Widget build(BuildContext context) => Container(
    height: 104,
    padding: const EdgeInsets.symmetric(horizontal: 22),
    decoration: const BoxDecoration(color: Color(0xFFFFE9D5)),
    child: Stack(
      children: [
        const Positioned(
          left: 4,
          top: 10,
          child: Icon(
            Icons.shopping_cart_outlined,
            size: 68,
            color: Color(0xFF8ED6C2),
          ),
        ),
        Positioned(
          right: 5,
          top: 8,
          child: Text(
            'SHOPPING\nWISHLIST\nAPP',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 29,
              height: .92,
              fontWeight: FontWeight.w900,
              color: Color(0xFF5ABAA9).withValues(alpha: .75),
            ),
          ),
        ),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.shopping_cart_outlined, color: Colors.grey, size: 58),
        SizedBox(height: 11),
        Text('Chưa có sản phẩm nào', style: TextStyle(color: Colors.grey)),
        Text(
          'Nhấn nút "+" để thêm sản phẩm yêu thích',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    ),
  );
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, required this.onTap});
  final ShoppingItem item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFF5EDFF),
        child: Icon(_categoryIcon(item.category), color: _purple),
      ),
      title: Text(
        item.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(item.category),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _money(item.price),
            style: const TextStyle(
              color: _purple,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          _StatusChip(purchased: item.purchased),
        ],
      ),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.purchased});
  final bool purchased;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: purchased ? _green : _orange,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      purchased ? 'Purchased' : 'Wishlist',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 9,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    required this.number,
    required this.item,
    required this.onTap,
  });
  final int number;
  final ShoppingItem item;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 12,
        backgroundColor: _orange,
        child: Text(
          '$number',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        item.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      subtitle: Text(item.category, style: const TextStyle(fontSize: 10)),
      trailing: Text(
        _money(item.price),
        style: const TextStyle(
          color: _orange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ),
  );
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.count, required this.total});
  final int count, total;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 7),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _orange, width: 1.5),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.calculate, color: _purple),
            SizedBox(width: 8),
            Text(
              'Total Estimate',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const Divider(),
        _line('Number of items:', '$count'),
        const SizedBox(height: 8),
        _line('Total cost:', _money(total), highlighted: true),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text(
            'ⓘ  This is the estimated total for items you want to buy',
            style: TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ),
      ],
    ),
  );
  Widget _line(String label, String value, {bool highlighted = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      Text(
        value,
        style: TextStyle(
          color: highlighted ? _orange : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key, required this.id});
  final int id;
  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  String _category = 'Fashion';
  bool _purchased = false;
  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ShoppingItem(
        id: widget.id,
        name: _name.text.trim(),
        category: _category,
        price: int.parse(_price.text.replaceAll(RegExp(r'[^0-9]'), '')),
        purchased: _purchased,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Add Shopping Item'),
      foregroundColor: Colors.white,
      backgroundColor: _purple,
    ),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Item Name *',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Nike Air Force 1',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Please enter item name'
                        : null,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Category *',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField(
                    initialValue: _category,
                    items: const ['Fashion', 'Electronics', 'Home', 'Other']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => _category = value!),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Price (VND) *',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'e.g. 2500000'),
                    validator: (value) {
                      final n = int.tryParse(
                        (value ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
                      );
                      return n == null || n <= 0
                          ? 'Please enter a valid price'
                          : null;
                    },
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField(
                    initialValue: _purchased,
                    items: const [
                      DropdownMenuItem(value: false, child: Text('Wishlist')),
                      DropdownMenuItem(value: true, child: Text('Purchased')),
                    ],
                    onChanged: (value) => setState(() => _purchased = value!),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Save'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.grey,
                            foregroundColor: Colors.white,
                          ),
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
}

enum _ItemAction { toggled, deleted }

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen({super.key, required this.item});
  final ShoppingItem item;
  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      Navigator.pop(context, _ItemAction.deleted);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Item Details'),
      backgroundColor: _purple,
      foregroundColor: Colors.white,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detail Information',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _detail(Icons.key, 'ID', '#${item.id}'),
                  _detail(Icons.grid_view, 'Category', item.category),
                  _detail(
                    Icons.payments_outlined,
                    'Price',
                    _money(item.price),
                    purple: true,
                  ),
                  _detail(
                    Icons.flag_outlined,
                    'Status',
                    item.purchased ? 'Purchased' : 'Wishlist',
                    green: item.purchased,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _actionButton(
                  item.purchased ? 'Move to Wishlist' : 'Mark Purchased',
                  Icons.swap_horiz,
                  _orange,
                  () => Navigator.pop(context, _ItemAction.toggled),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(
                  'Delete',
                  Icons.delete,
                  const Color(0xFFC3002F),
                  () => _delete(context),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _actionButton(
                  'Back',
                  Icons.arrow_back,
                  Colors.grey,
                  () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  Widget _detail(
    IconData icon,
    String label,
    String value, {
    bool purple = false,
    bool green = false,
  }) => Column(
    children: [
      Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: purple
                  ? _purple
                  : green
                  ? _green
                  : Colors.black,
            ),
          ),
        ],
      ),
      const Divider(),
    ],
  );
  Widget _actionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) => SizedBox(
    height: 76,
    child: FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, textAlign: TextAlign.center),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

IconData _categoryIcon(String category) => switch (category) {
  'Electronics' => Icons.phone_android,
  'Home' => Icons.chair_outlined,
  'Fashion' => Icons.checkroom_outlined,
  _ => Icons.shopping_bag_outlined,
};
String _money(int amount) =>
    '${amount.toString().replaceAllMapped(RegExp(r'(?<!^)(?=(\d{3})+$)'), (match) => '.')} đ';
