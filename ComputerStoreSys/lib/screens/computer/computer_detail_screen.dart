import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/computer.dart';
import '../../services/brand_repository.dart';
import '../../services/category_repository.dart';
import '../../services/computer_repository.dart';
import 'edit_computer_screen.dart';

class ComputerDetailScreen extends StatefulWidget {
  final int computerId;
  final ComputerRepository computerRepository;
  final BrandRepository brandRepository;
  final CategoryRepository categoryRepository;

  const ComputerDetailScreen({
    super.key,
    required this.computerId,
    required this.computerRepository,
    required this.brandRepository,
    required this.categoryRepository,
  });

  @override
  State<ComputerDetailScreen> createState() => _ComputerDetailScreenState();
}

class _ComputerDetailScreenState extends State<ComputerDetailScreen> {
  Computer? _computer;
  bool _isLoading = true;
  String? _error;

  final currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );
  final numberFormatter = NumberFormat.decimalPattern('en_US');

  @override
  void initState() {
    super.initState();
    _loadComputer();
  }

  Future<void> _loadComputer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final comp = await widget.computerRepository.getComputerById(
        widget.computerId,
      );
      if (mounted) {
        setState(() {
          _computer = comp;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToEdit() async {
    if (_computer == null) return;

    final updated = await Navigator.of(context).push<Computer>(
      MaterialPageRoute(
        builder: (context) => EditComputerScreen(
          computer: _computer!,
          computerRepository: widget.computerRepository,
          brandRepository: widget.brandRepository,
          categoryRepository: widget.categoryRepository,
        ),
      ),
    );

    if (updated != null && mounted) {
      _loadComputer();
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Computer'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await widget.computerRepository.deleteComputer(widget.computerId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Computer deleted successfully.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.of(context)
              .pop(true); // Return to Store Screen with refresh
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Delete failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Computer Detail'),
        actions: [
          if (_computer != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Computer',
              onPressed: _navigateToEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Computer',
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text('Error: $_error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadComputer,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _computer == null
          ? const Center(child: Text('Product not found.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  _computer!.productName,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (_computer!.isFeaturedBool)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Featured',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.brown,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currencyFormatter.format(_computer!.price),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildChip(
                                icon: Icons.business,
                                label:
                                    'Brand: ${_computer!.brandName ?? "ID ${_computer!.brandId}"}',
                                color: theme.colorScheme.primaryContainer,
                              ),
                              const SizedBox(width: 8),
                              _buildChip(
                                icon: Icons.category,
                                label:
                                    'Category: ${_computer!.categoryName ?? "ID ${_computer!.categoryId}"}',
                                color: theme.colorScheme.secondaryContainer,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Hardware Specifications
                  Text(
                    'Hardware Specifications',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSpecTile(
                          icon: Icons.memory,
                          title: 'CPU',
                          value: _computer!.cpu,
                        ),
                        const Divider(height: 1),
                        _buildSpecTile(
                          icon: Icons.developer_board,
                          title: 'RAM',
                          value: '${_computer!.ram} GB',
                        ),
                        const Divider(height: 1),
                        _buildSpecTile(
                          icon: Icons.storage,
                          title: 'Storage',
                          value: '${_computer!.storage} GB',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Inventory & Sales
                  Text(
                    'Inventory & Sales',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSpecTile(
                          icon: Icons.inventory_2,
                          title: 'Stock in Store',
                          value: '${_computer!.stock} units',
                          valueColor: _computer!.stock == 0
                              ? Colors.red
                              : _computer!.stock < 5
                              ? Colors.orange
                              : Colors.green,
                        ),
                        const Divider(height: 1),
                        _buildSpecTile(
                          icon: Icons.sell,
                          title: 'Sold Quantity',
                          value: '${_computer!.soldQuantity} units',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Business Calculations (Task 4.5)
                  Text(
                    'Business Calculations (Real-time)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Calculated in Flutter without redundant DB storage',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Revenue',
                          formula: 'Price × Sold',
                          value: currencyFormatter.format(_computer!.revenue),
                          color: Colors.indigo.shade50,
                          textColor: Colors.indigo.shade900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Inventory Value',
                          formula: 'Price × Stock',
                          value: currencyFormatter.format(
                            _computer!.inventoryValue,
                          ),
                          color: Colors.teal.shade50,
                          textColor: Colors.teal.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildStatCard(
                    title: 'Total Units (Stock + Sold)',
                    formula: 'Stock + Sold Quantity',
                    value:
                        '${numberFormatter.format(_computer!.totalUnits)} units',
                    color: Colors.amber.shade50,
                    textColor: Colors.brown.shade900,
                  ),
                  const SizedBox(height: 24),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          onPressed: _confirmDelete,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _navigateToEdit,
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Computer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTile({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Text(
        value,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: valueColor,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String formula,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          Text(
            formula,
            style: TextStyle(
              fontSize: 11,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
