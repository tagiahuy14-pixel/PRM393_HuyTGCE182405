import 'package:flutter/material.dart';

import '../../models/brand.dart';
import '../../models/category.dart';
import '../../services/computer_repository.dart';

class FilterSheet extends StatefulWidget {
  final ComputerFilterCriteria criteria;
  final List<Brand> brands;
  final List<Category> categories;

  const FilterSheet({
    super.key,
    required this.criteria,
    required this.brands,
    required this.categories,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  int? _brandId;
  int? _categoryId;
  late bool _featuredOnly;
  late StockFilter _stockFilter;
  late RamFilter _ramFilter;
  late StorageFilter _storageFilter;
  late PriceFilter _priceFilter;

  @override
  void initState() {
    super.initState();
    _brandId = widget.criteria.brandId;
    _categoryId = widget.criteria.categoryId;
    _featuredOnly = widget.criteria.featuredOnly;
    _stockFilter = widget.criteria.stockFilter;
    _ramFilter = widget.criteria.ramFilter;
    _storageFilter = widget.criteria.storageFilter;
    _priceFilter = widget.criteria.priceFilter;
  }

  void _reset() {
    setState(() {
      _brandId = null;
      _categoryId = null;
      _featuredOnly = false;
      _stockFilter = StockFilter.all;
      _ramFilter = RamFilter.all;
      _storageFilter = StorageFilter.all;
      _priceFilter = PriceFilter.all;
    });
  }

  void _apply() {
    final updatedCriteria = widget.criteria.copyWith(
      brandId: _brandId,
      clearBrand: _brandId == null,
      categoryId: _categoryId,
      clearCategory: _categoryId == null,
      featuredOnly: _featuredOnly,
      stockFilter: _stockFilter,
      ramFilter: _ramFilter,
      storageFilter: _storageFilter,
      priceFilter: _priceFilter,
    );
    Navigator.of(context).pop(updatedCriteria);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.filter_list, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Filter Products',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
              ),
            ],
          ),
          const Divider(),

          // Scrollable Filter Options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Brand Filter
                  const Text(
                    'Brand',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int?>(
                    initialValue: _brandId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Brands'),
                      ),
                      ...widget.brands.map(
                        (b) => DropdownMenuItem<int?>(
                          value: b.id,
                          child: Text(b.brandName),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _brandId = val),
                  ),
                  const SizedBox(height: 16),

                  // 2. Category Filter
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<int?>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...widget.categories.map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text(c.categoryName),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _categoryId = val),
                  ),
                  const SizedBox(height: 16),

                  // 3. Featured Only Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Featured Only',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Show only featured products'),
                    value: _featuredOnly,
                    onChanged: (val) => setState(() => _featuredOnly = val),
                  ),
                  const Divider(),

                  // 4. Stock Status
                  const Text(
                    'Stock Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _stockFilter == StockFilter.all,
                        onSelected: (_) =>
                            setState(() => _stockFilter = StockFilter.all),
                      ),
                      ChoiceChip(
                        label: const Text('In Stock (>0)'),
                        selected: _stockFilter == StockFilter.inStock,
                        onSelected: (_) =>
                            setState(() => _stockFilter = StockFilter.inStock),
                      ),
                      ChoiceChip(
                        label: const Text('Low Stock (<5)'),
                        selected: _stockFilter == StockFilter.lowStock,
                        onSelected: (_) =>
                            setState(() => _stockFilter = StockFilter.lowStock),
                      ),
                      ChoiceChip(
                        label: const Text('Out of Stock (0)'),
                        selected: _stockFilter == StockFilter.outOfStock,
                        onSelected: (_) => setState(
                          () => _stockFilter = StockFilter.outOfStock,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. RAM
                  const Text(
                    'RAM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _ramFilter == RamFilter.all,
                        onSelected: (_) =>
                            setState(() => _ramFilter = RamFilter.all),
                      ),
                      ChoiceChip(
                        label: const Text('8 GB'),
                        selected: _ramFilter == RamFilter.ram8,
                        onSelected: (_) =>
                            setState(() => _ramFilter = RamFilter.ram8),
                      ),
                      ChoiceChip(
                        label: const Text('16 GB'),
                        selected: _ramFilter == RamFilter.ram16,
                        onSelected: (_) =>
                            setState(() => _ramFilter = RamFilter.ram16),
                      ),
                      ChoiceChip(
                        label: const Text('32 GB or above'),
                        selected: _ramFilter == RamFilter.ram32Plus,
                        onSelected: (_) =>
                            setState(() => _ramFilter = RamFilter.ram32Plus),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 6. Storage
                  const Text(
                    'Storage',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _storageFilter == StorageFilter.all,
                        onSelected: (_) =>
                            setState(() => _storageFilter = StorageFilter.all),
                      ),
                      ChoiceChip(
                        label: const Text('256 GB'),
                        selected: _storageFilter == StorageFilter.storage256,
                        onSelected: (_) => setState(
                          () => _storageFilter = StorageFilter.storage256,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('512 GB'),
                        selected: _storageFilter == StorageFilter.storage512,
                        onSelected: (_) => setState(
                          () => _storageFilter = StorageFilter.storage512,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('1 TB'),
                        selected: _storageFilter == StorageFilter.storage1TB,
                        onSelected: (_) => setState(
                          () => _storageFilter = StorageFilter.storage1TB,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('2 TB+'),
                        selected:
                            _storageFilter == StorageFilter.storage2TBPlus,
                        onSelected: (_) => setState(
                          () => _storageFilter = StorageFilter.storage2TBPlus,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 7. Price
                  const Text(
                    'Price',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _priceFilter == PriceFilter.all,
                        onSelected: (_) =>
                            setState(() => _priceFilter = PriceFilter.all),
                      ),
                      ChoiceChip(
                        label: const Text('Less than \$500'),
                        selected: _priceFilter == PriceFilter.under500,
                        onSelected: (_) =>
                            setState(() => _priceFilter = PriceFilter.under500),
                      ),
                      ChoiceChip(
                        label: const Text('\$500 – \$1000'),
                        selected: _priceFilter == PriceFilter.between500And1000,
                        onSelected: (_) => setState(
                          () => _priceFilter = PriceFilter.between500And1000,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Greater than \$1000'),
                        selected: _priceFilter == PriceFilter.over1000,
                        onSelected: (_) =>
                            setState(() => _priceFilter = PriceFilter.over1000),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Action: Apply
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _apply,
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
