import 'package:flutter/material.dart';

import '../../services/computer_repository.dart';

class SortDialog extends StatelessWidget {
  final SortOption currentSort;

  const SortDialog({super.key, required this.currentSort});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.sort),
          SizedBox(width: 8),
          Text('Sort Computers'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSortOption(
              context,
              'Product Name: A → Z',
              SortOption.nameAsc,
            ),
            _buildSortOption(
              context,
              'Product Name: Z → A',
              SortOption.nameDesc,
            ),
            const Divider(height: 1),
            _buildSortOption(context, 'Price: Low → High', SortOption.priceAsc),
            _buildSortOption(
              context,
              'Price: High → Low',
              SortOption.priceDesc,
            ),
            const Divider(height: 1),
            _buildSortOption(
              context,
              'Sold Quantity: Low → High',
              SortOption.soldAsc,
            ),
            _buildSortOption(
              context,
              'Sold Quantity: High → Low',
              SortOption.soldDesc,
            ),
            const Divider(height: 1),
            _buildSortOption(context, 'Brand Name: A → Z', SortOption.brandAsc),
            _buildSortOption(
              context,
              'Brand Name: Z → A',
              SortOption.brandDesc,
            ),
            const Divider(height: 1),
            _buildSortOption(context, 'Stock: Low → High', SortOption.stockAsc),
            _buildSortOption(
              context,
              'Stock: High → Low',
              SortOption.stockDesc,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    SortOption option,
  ) {
    final isSelected = currentSort == option;
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.primary : null,
        ),
      ),
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? theme.colorScheme.primary : Colors.grey,
        size: 20,
      ),
      onTap: () => Navigator.of(context).pop(option),
      dense: true,
    );
  }
}
