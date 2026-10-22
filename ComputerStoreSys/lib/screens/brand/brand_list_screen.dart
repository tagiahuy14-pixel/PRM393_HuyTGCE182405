import 'package:flutter/material.dart';

import '../../models/brand.dart';
import '../../services/brand_repository.dart';
import 'add_edit_brand_dialog.dart';

class BrandListScreen extends StatefulWidget {
  final BrandRepository repository;

  const BrandListScreen({super.key, required this.repository});

  @override
  State<BrandListScreen> createState() => BrandListScreenState();
}

class BrandListScreenState extends State<BrandListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Brand> _brands = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _loadBrands(_searchController.text);
  }

  Future<void> _loadBrands([String? query]) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = query != null && query.trim().isNotEmpty
          ? await widget.repository.searchBrands(query.trim())
          : await widget.repository.getAllBrands();

      if (mounted) {
        setState(() {
          _brands = results;
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

  // Public refresh method for parent widgets / tabs
  void refresh() {
    _loadBrands(_searchController.text);
  }

  Future<void> _showAddBrandDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditBrandDialog(repository: widget.repository),
    );

    if (result == true && mounted) {
      _loadBrands(_searchController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brand added successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showEditBrandDialog(Brand brand) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AddEditBrandDialog(brand: brand, repository: widget.repository),
    );

    if (result == true && mounted) {
      _loadBrands(_searchController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Brand updated successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDeleteBrand(Brand brand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Brand'),
        content: const Text('Are you sure you want to delete this brand?'),
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

    if (confirmed != true) return;

    try {
      await widget.repository.deleteBrand(brand.id!);
      if (mounted) {
        _loadBrands(_searchController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brand deleted successfully.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final message = e.toString().replaceAll('Exception: ', '');
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 8),
                Text('Cannot Delete Brand'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Management'),
        actions: [
          IconButton(
            tooltip: 'Add Brand',
            icon: const Icon(Icons.add),
            onPressed: _showAddBrandDialog,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadBrands(_searchController.text),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Brand',
        onPressed: _showAddBrandDialog,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Brand Name or Country...',
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

          // Content List
          Expanded(
            child: _isLoading
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
                          Text(
                            'Error loading brands: $_error',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                _loadBrands(_searchController.text),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _brands.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No brands found.'
                              : 'No matching brands found.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadBrands(_searchController.text),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _brands.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final brand = _brands[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Brand Icon Avatar
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child: Text(
                                    brand.brandName.isNotEmpty
                                        ? brand.brandName[0].toUpperCase()
                                        : 'B',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color:
                                          theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Brand Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        brand.brandName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.public,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Country : ${brand.country}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Founded : ${brand.foundedYear}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: brand.productCount > 0
                                              ? theme
                                                    .colorScheme
                                                    .primaryContainer
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Products : ${brand.productCount}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: brand.productCount > 0
                                                ? theme
                                                      .colorScheme
                                                      .onPrimaryContainer
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Action Buttons
                                Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Colors.blue,
                                      ),
                                      tooltip: 'Edit Brand',
                                      onPressed: () =>
                                          _showEditBrandDialog(brand),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Delete Brand',
                                      onPressed: () =>
                                          _confirmDeleteBrand(brand),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
