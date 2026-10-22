import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/statistics_models.dart';
import '../../services/statistics_repository.dart';

class StatisticsScreen extends StatefulWidget {
  final StatisticsRepository repository;

  const StatisticsScreen({super.key, required this.repository});

  @override
  State<StatisticsScreen> createState() => StatisticsScreenState();
}

class StatisticsScreenState extends State<StatisticsScreen> {
  bool _isLoading = true;
  String? _error;

  GeneralStatistics? _generalStats;
  List<BrandStatistic> _brandStats = [];
  List<CategoryStatistic> _categoryStats = [];
  BestSellingProduct? _bestSelling;
  MostExpensiveProduct? _mostExpensive;
  List<LowStockProduct> _lowStock = [];
  TopBrand? _topBrand;
  FeaturedStatistics? _featuredStats;

  final currencyFormatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );
  final intFormatter = NumberFormat.decimalPattern('en_US');

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  // Public method for tab switching live refresh
  Future<void> loadStatistics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final general = await widget.repository.getStatistics();
      final brands = await widget.repository.getBrandStatistics();
      final categories = await widget.repository.getCategoryStatistics();
      final best = await widget.repository.getBestSellingProduct();
      final expensive = await widget.repository.getMostExpensiveProduct();
      final low = await widget.repository.getLowStockProducts();
      final top = await widget.repository.getTopBrand();
      final feat = await widget.repository.getFeaturedStatistics();

      if (mounted) {
        setState(() {
          _generalStats = general;
          _brandStats = brands;
          _categoryStats = categories;
          _bestSelling = best;
          _mostExpensive = expensive;
          _lowStock = low;
          _topBrand = top;
          _featuredStats = feat;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Statistics',
            onPressed: loadStatistics,
          ),
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
                      onPressed: loadStatistics,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: loadStatistics,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. General Statistics (6.1)
                    _buildSectionHeader(
                      context,
                      title: 'General Statistics',
                      icon: Icons.analytics,
                    ),
                    const SizedBox(height: 8),
                    _buildGeneralStatsGrid(theme),
                    const SizedBox(height: 20),

                    // Highlights row: Best Selling & Most Expensive & Top Brand
                    _buildSectionHeader(
                      context,
                      title: 'Store Highlights',
                      icon: Icons.star_border,
                    ),
                    const SizedBox(height: 8),
                    _buildHighlightsCards(theme),
                    const SizedBox(height: 20),

                    // 2. Low Stock Alerts (6.6)
                    _buildSectionHeader(
                      context,
                      title: 'Low Stock Products (< 5)',
                      icon: Icons.warning_amber_rounded,
                      actionText: '${_lowStock.length} items',
                      actionColor: _lowStock.isNotEmpty
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildLowStockList(theme),
                    const SizedBox(height: 20),

                    // 3. Featured Statistics (6.8)
                    _buildSectionHeader(
                      context,
                      title: 'Featured Products Overview',
                      icon: Icons.auto_awesome,
                    ),
                    const SizedBox(height: 8),
                    _buildFeaturedStatsCard(theme),
                    const SizedBox(height: 20),

                    // 4. Statistics by Brand (6.2)
                    _buildSectionHeader(
                      context,
                      title: 'Statistics by Brand',
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 8),
                    _buildBrandStatsTable(theme),
                    const SizedBox(height: 20),

                    // 5. Statistics by Category (6.3)
                    _buildSectionHeader(
                      context,
                      title: 'Statistics by Category',
                      icon: Icons.category,
                    ),
                    const SizedBox(height: 8),
                    _buildCategoryStatsCards(theme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? actionText,
    Color? actionColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (actionText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: (actionColor ?? Colors.grey).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: actionColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGeneralStatsGrid(ThemeData theme) {
    final stats = _generalStats ?? GeneralStatistics.empty();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                theme,
                title: 'Total Products',
                value: intFormatter.format(stats.totalProducts),
                icon: Icons.computer,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                theme,
                title: 'Total Sold',
                value: '${intFormatter.format(stats.totalSoldQuantity)} units',
                icon: Icons.shopping_bag,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                theme,
                title: 'Total Revenue',
                value: currencyFormatter.format(stats.totalRevenue),
                icon: Icons.attach_money,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildMetricTile(
                theme,
                title: 'Inventory Value',
                value: currencyFormatter.format(stats.totalInventoryValue),
                icon: Icons.warehouse,
                color: Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildMetricTile(
          theme,
          title: 'Average Product Price',
          value: currencyFormatter.format(stats.averagePrice),
          icon: Icons.price_check,
          color: Colors.teal,
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    ThemeData theme, {
    required String title,
    required String value,
    required IconData icon,
    required MaterialColor color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color.shade700, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsCards(ThemeData theme) {
    return Column(
      children: [
        if (_bestSelling != null)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.amber.shade300),
            ),
            color: Colors.amber.shade50,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.amber,
                child: Icon(Icons.emoji_events, color: Colors.white),
              ),
              title: const Text(
                'Best Selling Product',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _bestSelling!.productName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              trailing: Text(
                '${_bestSelling!.soldQuantity} sold',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
          ),
        if (_mostExpensive != null)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.purple.shade200),
            ),
            color: Colors.purple.shade50,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.diamond, color: Colors.white),
              ),
              title: const Text(
                'Most Expensive Product',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _mostExpensive!.productName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              trailing: Text(
                currencyFormatter.format(_mostExpensive!.price),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade900,
                ),
              ),
            ),
          ),
        if (_topBrand != null)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.blue.shade200),
            ),
            color: Colors.blue.shade50,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.military_tech, color: Colors.white),
              ),
              title: const Text(
                'Top Brand (By Units Sold)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _topBrand!.brandName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              trailing: Text(
                '${_topBrand!.totalSold} units',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLowStockList(ThemeData theme) {
    if (_lowStock.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('All products have adequate stock (>= 5).'),
            ],
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _lowStock.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _lowStock[index];
          return ListTile(
            leading: Icon(
              item.stock == 0 ? Icons.error : Icons.warning,
              color: item.stock == 0 ? Colors.red : Colors.orange,
            ),
            title: Text(
              item.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Brand: ${item.brandName}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: item.stock == 0
                    ? Colors.red.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.stock == 0 ? 'Out of Stock' : 'Stock: ${item.stock}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: item.stock == 0
                      ? Colors.red.shade900
                      : Colors.orange.shade900,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedStatsCard(ThemeData theme) {
    final feat = _featuredStats ?? FeaturedStatistics.empty();
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.amber.shade50.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text(
                  'Featured Products',
                  style: TextStyle(fontSize: 12, color: Colors.brown),
                ),
                const SizedBox(height: 4),
                Text(
                  '${feat.totalFeaturedProducts}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Container(width: 1, height: 35, color: Colors.grey.shade300),
            Column(
              children: [
                const Text(
                  'Featured Revenue',
                  style: TextStyle(fontSize: 12, color: Colors.brown),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter.format(feat.totalFeaturedRevenue),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            Container(width: 1, height: 35, color: Colors.grey.shade300),
            Column(
              children: [
                const Text(
                  'Featured Sold',
                  style: TextStyle(fontSize: 12, color: Colors.brown),
                ),
                const SizedBox(height: 4),
                Text(
                  '${feat.totalFeaturedSoldQuantity} units',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandStatsTable(ThemeData theme) {
    if (_brandStats.isEmpty) {
      return const Text('No brand statistics available.');
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 18,
          columns: const [
            DataColumn(
              label: Text(
                'Brand',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Products',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Sold',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Revenue',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Inventory Value',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              numeric: true,
            ),
          ],
          rows: _brandStats.map((b) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    b.brandName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataCell(Text('${b.totalProducts}')),
                DataCell(Text('${b.totalSold}')),
                DataCell(Text(currencyFormatter.format(b.revenue))),
                DataCell(Text(currencyFormatter.format(b.inventoryValue))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryStatsCards(ThemeData theme) {
    if (_categoryStats.isEmpty) {
      return const Text('No category statistics available.');
    }

    return Column(
      children: _categoryStats.map((cat) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Text(
                    cat.categoryName.isNotEmpty ? cat.categoryName[0] : 'C',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat.categoryName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('Products: ${cat.totalProducts}'),
                          const Text(' • '),
                          Text('Sold: ${cat.totalSold}'),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  currencyFormatter.format(cat.totalRevenue),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
