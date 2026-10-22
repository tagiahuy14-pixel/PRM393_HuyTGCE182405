import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../services/category_repository.dart';

class AddEditCategoryDialog extends StatefulWidget {
  final Category? category;
  final CategoryRepository repository;

  const AddEditCategoryDialog({
    super.key,
    this.category,
    required this.repository,
  });

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.category?.categoryName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final name = _nameController.text.trim();

      if (isEditing) {
        final updated = widget.category!.copyWith(categoryName: name);
        await widget.repository.updateCategory(updated);
      } else {
        final created = Category(categoryName: name);
        await widget.repository.insertCategory(created);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(isEditing ? 'Edit Category' : 'Add Category'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name *',
                hintText: 'e.g. Laptop, Desktop, Component',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Category Name is required.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Save Changes' : 'Add Category'),
        ),
      ],
    );
  }
}
