import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../services/category_repository.dart';
import 'add_edit_category_dialog.dart';

class CategoryListScreen extends StatefulWidget {
  final CategoryRepository repository;

  const CategoryListScreen({super.key, required this.repository});

  @override
  State<CategoryListScreen> createState() => CategoryListScreenState();
}

class CategoryListScreenState extends State<CategoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _loadCategories(_searchController.text);
  }

  Future<void> _loadCategories([String? query]) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = query != null && query.trim().isNotEmpty
          ? await widget.repository.searchCategories(query.trim())
          : await widget.repository.getAllCategories();

      if (mounted) {
        setState(() {
          _categories = results;
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

  // Public refresh for tab synchronization
  void refresh() {
    _loadCategories(_searchController.text);
  }

  Future<void> _showAddCategoryDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AddEditCategoryDialog(repository: widget.repository),
    );

    if (result == true && mounted) {
      _loadCategories(_searchController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category added successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showEditCategoryDialog(Category category) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddEditCategoryDialog(
        category: category,
        repository: widget.repository,
      ),
    );

    if (result == true && mounted) {
      _loadCategories(_searchController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category updated successfully.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDeleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
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
      await widget.repository.deleteCategory(category.id!);
      if (mounted) {
        _loadCategories(_searchController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted successfully.'),
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
                Text('Cannot Delete Category'),
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
        title: const Text('Category Management'),
        actions: [
          IconButton(
            tooltip: 'Add Category',
            icon: const Icon(Icons.add),
            onPressed: _showAddCategoryDialog,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadCategories(_searchController.text),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Category',
        onPressed: _showAddCategoryDialog,
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
                hintText: 'Search by category name...',
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

          // Category List
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
                            'Error loading categories: $_error',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                _loadCategories(_searchController.text),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _categories.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No categories found.'
                              : 'No matching categories found.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => _loadCategories(_searchController.text),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              child: Icon(
                                Icons.devices,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            title: Text(
                              category.categoryName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'Products : ${category.productCount}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.blue,
                                  ),
                                  tooltip: 'Edit Category',
                                  onPressed: () =>
                                      _showEditCategoryDialog(category),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'Delete Category',
                                  onPressed: () =>
                                      _confirmDeleteCategory(category),
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
