import 'package:flutter/material.dart';

import '../../models/brand.dart';
import '../../models/category.dart';
import '../../models/computer.dart';
import '../../services/brand_repository.dart';
import '../../services/category_repository.dart';
import '../../services/computer_repository.dart';
import '../../widgets/computer_card.dart';
import '../../widgets/promotional_banner.dart';
import '../computer/computer_detail_screen.dart';
import 'filter_sheet.dart';
import 'sort_dialog.dart';

class StoreScreen extends StatefulWidget {
  final ComputerRepository computerRepository;
  final BrandRepository brandRepository;
  final CategoryRepository categoryRepository;

  const StoreScreen({
    super.key,
    required this.computerRepository,
    required this.brandRepository,
    required this.categoryRepository,
  });

  @override
  State<StoreScreen> createState() => StoreScreenState();
}

class StoreScreenState extends State<StoreScreen> {
  final TextEditingController _searchController = TextEditingController();

  ComputerFilterCriteria _criteria = ComputerFilterCriteria.defaultCriteria;
  List<Computer> _computers = [];
  List<Brand> _brands = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  bool get _hasActiveFilters =>
      _criteria.brandId != null ||
      _criteria.categoryId != null ||
      _criteria.featuredOnly ||
      _criteria.stockFilter != StockFilter.all ||
      _criteria.ramFilter != RamFilter.all ||
      _storageFilterActive ||
      _criteria.priceFilter != PriceFilter.all ||
      _criteria.sortOption != SortOption.nameAsc ||
      (_criteria.keyword != null && _criteria.keyword!.trim().isNotEmpty);

  bool get _storageFilterActive => _criteria.storageFilter != StorageFilter.all;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final kw = _searchController.text;
    setState(() {
      _criteria = _criteria.copyWith(keyword: kw);
    });
    _fetchProducts();
  }

  Future<void> _loadInitialData() async {
    try {
      final brands = await widget.brandRepository.getAllBrands();
      final categories = await widget.categoryRepository.getAllCategories();
      if (mounted) {
        setState(() {
          _brands = brands;
          _categories = categories;
        });
      }
    } catch (_) {}
    await _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await widget.computerRepository.queryComputers(_criteria);
      if (mounted) {
        setState(() {
          _computers = results;
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

  // Public refresh method for parent navigation / tabs
  void refresh() {
    _loadInitialData();
  }

  void _resetAllFilters() {
    _searchController.clear();
    setState(() {
      _criteria = ComputerFilterCriteria.defaultCriteria;
    });
    _fetchProducts();
  }

  Future<void> _openFilterSheet() async {
    // Refresh brands & categories list first to keep synced
    try {
      final brands = await widget.brandRepository.getAllBrands();
      final categories = await widget.categoryRepository.getAllCategories();
      _brands = brands;
      _categories = categories;
    } catch (_) {}

    if (!mounted) return;

    final updated = await showModalBottomSheet<ComputerFilterCriteria>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FilterSheet(
        criteria: _criteria,
        brands: _brands,
        categories: _categories,
      ),
    );

    if (updated != null && mounted) {
      setState(() {
        _criteria = updated;
      });
      _fetchProducts();
    }
  }

  Future<void> _openSortDialog() async {
    final selectedSort = await showDialog<SortOption>(
      context: context,
      builder: (context) => SortDialog(currentSort: _criteria.sortOption),
    );

    if (selectedSort != null && mounted) {
      setState(() {
        _criteria = _criteria.copyWith(sortOption: selectedSort);
      });
      _fetchProducts();
    }
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        return 'Name: A→Z';
      case SortOption.nameDesc:
        return 'Name: Z→A';
      case SortOption.priceAsc:
        return 'Price: Low→High';
      case SortOption.priceDesc:
        return 'Price: High→Low';
      case SortOption.soldAsc:
        return 'Sold: Low→High';
      case SortOption.soldDesc:
        return 'Sold: High→Low';
      case SortOption.brandAsc:
        return 'Brand: A→Z';
      case SortOption.brandDesc:
        return 'Brand: Z→A';
      case SortOption.stockAsc:
        return 'Stock: Low→High';
      case SortOption.stockDesc:
        return 'Stock: High→Low';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // 1. AppBar
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.desktop_windows, size: 26),
            SizedBox(width: 8),
            Text('Tech Store', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Store',
            onPressed: () => _fetchProducts(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchProducts(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 2. Promotional Banner
            const SliverToBoxAdapter(child: PromotionalBanner()),

            // 3. Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Product Name, Brand, or CPU...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
            ),

            // 4 & 5. Filter Button & Sort Button & Reset Button Controls
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Filter Button
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor:
                                  (_hasActiveFilters &&
                                      _criteria.sortOption ==
                                          SortOption.nameAsc)
                                  ? theme.colorScheme.primaryContainer
                                  : null,
                            ),
                            onPressed: _openFilterSheet,
                            icon: const Icon(Icons.filter_list, size: 20),
                            label: const Text('Filter'),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Sort Button
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor:
                                  _criteria.sortOption != SortOption.nameAsc
                                  ? theme.colorScheme.secondaryContainer
                                  : null,
                            ),
                            onPressed: _openSortDialog,
                            icon: const Icon(Icons.sort, size: 20),
                            label: Text(
                              _getSortLabel(_criteria.sortOption),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Reset Filters Bar when active
                    if (_hasActiveFilters) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active filters applied (${_computers.length} results)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: Colors.red,
                            ),
                            onPressed: _resetAllFilters,
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Reset Filters'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // 6. Computer Product List
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
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
                          onPressed: _fetchProducts,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_computers.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No computer products found.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (_hasActiveFilters) ...[
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _resetAllFilters,
                          child: const Text('Reset All Filters'),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final computer = _computers[index];
                    return ComputerCard(
                      computer: computer,
                      onTap: () async {
                        final shouldRefresh = await Navigator.of(context)
                            .push<bool>(
                              MaterialPageRoute(
                                builder: (context) => ComputerDetailScreen(
                                  computerId: computer.id!,
                                  computerRepository: widget.computerRepository,
                                  brandRepository: widget.brandRepository,
                                  categoryRepository: widget.categoryRepository,
                                ),
                              ),
                            );

                        if (shouldRefresh == true && mounted) {
                          _fetchProducts();
                        }
                      },
                    );
                  }, childCount: _computers.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
