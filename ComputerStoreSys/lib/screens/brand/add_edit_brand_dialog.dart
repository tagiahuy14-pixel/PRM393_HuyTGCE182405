import 'package:flutter/material.dart';

import '../../models/brand.dart';
import '../../services/brand_repository.dart';

class AddEditBrandDialog extends StatefulWidget {
  final Brand? brand;
  final BrandRepository repository;

  const AddEditBrandDialog({super.key, this.brand, required this.repository});

  @override
  State<AddEditBrandDialog> createState() => _AddEditBrandDialogState();
}

class _AddEditBrandDialogState extends State<AddEditBrandDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _yearController;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isEditing => widget.brand != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.brand?.brandName ?? '',
    );
    _countryController = TextEditingController(
      text: widget.brand?.country ?? '',
    );
    _yearController = TextEditingController(
      text: widget.brand != null ? widget.brand!.foundedYear.toString() : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _yearController.dispose();
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
      final country = _countryController.text.trim();
      final year = int.parse(_yearController.text.trim());

      if (isEditing) {
        final updatedBrand = widget.brand!.copyWith(
          brandName: name,
          country: country,
          foundedYear: year,
        );
        await widget.repository.updateBrand(updatedBrand);
      } else {
        final newBrand = Brand(
          brandName: name,
          country: country,
          foundedYear: year,
        );
        await widget.repository.insertBrand(newBrand);
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
      title: Text(isEditing ? 'Edit Brand' : 'Add Brand'),
      content: SingleChildScrollView(
        child: Form(
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
                  labelText: 'Brand Name *',
                  hintText: 'e.g. ASUS',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Brand Name cannot be empty.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country *',
                  hintText: 'e.g. Taiwan',
                  prefixIcon: Icon(Icons.public),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Country cannot be empty.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Founded Year *',
                  hintText: 'e.g. 1989',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Founded Year cannot be empty.';
                  }
                  final year = int.tryParse(value.trim());
                  if (year == null) {
                    return 'Please enter a valid number.';
                  }
                  if (year <= 1900) {
                    return 'Founded Year must be greater than 1900.';
                  }
                  final currentYear = DateTime.now().year;
                  if (year > currentYear) {
                    return 'Founded Year cannot be in the future.';
                  }
                  return null;
                },
              ),
            ],
          ),
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
              : Text(isEditing ? 'Save Changes' : 'Add Brand'),
        ),
      ],
    );
  }
}
