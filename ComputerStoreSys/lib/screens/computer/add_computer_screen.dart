import 'package:flutter/material.dart';

import '../../models/brand.dart';
import '../../models/category.dart';
import '../../models/computer.dart';
import '../../services/brand_repository.dart';
import '../../services/category_repository.dart';
import '../../services/computer_repository.dart';

class AddComputerScreen extends StatefulWidget {
  final ComputerRepository computerRepository;
  final BrandRepository brandRepository;
  final CategoryRepository categoryRepository;
  final VoidCallback? onComputerAdded;

  const AddComputerScreen({
    super.key,
    required this.computerRepository,
    required this.brandRepository,
    required this.categoryRepository,
    this.onComputerAdded,
  });

  @override
  State<AddComputerScreen> createState() => AddComputerScreenState();
}

class AddComputerScreenState extends State<AddComputerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cpuController = TextEditingController();
  final _ramController = TextEditingController();
  final _storageController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _soldController = TextEditingController();

  int? _selectedBrandId;
  int? _selectedCategoryId;
  bool _isFeatured = false;

  List<Brand> _brands = [];
  List<Category> _categories = [];
  bool _isLoadingDropdowns = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadDropdownData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpuController.dispose();
    _ramController.dispose();
    _storageController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _soldController.dispose();
    super.dispose();
  }

  Future<void> loadDropdownData() async {
    setState(() {
      _isLoadingDropdowns = true;
    });

    try {
      final brands = await widget.brandRepository.getAllBrands();
      final categories = await widget.categoryRepository.getAllCategories();

      if (mounted) {
        setState(() {
          _brands = brands;
          _categories = categories;
          if (brands.isNotEmpty && _selectedBrandId == null) {
            _selectedBrandId = brands.first.id;
          }
          if (categories.isNotEmpty && _selectedCategoryId == null) {
            _selectedCategoryId = categories.first.id;
          }
          _isLoadingDropdowns = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load brands or categories: $e';
          _isLoadingDropdowns = false;
        });
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _cpuController.clear();
    _ramController.clear();
    _storageController.clear();
    _priceController.clear();
    _stockController.clear();
    _soldController.clear();
    setState(() {
      _isFeatured = false;
      _errorMessage = null;
      if (_brands.isNotEmpty) _selectedBrandId = _brands.first.id;
      if (_categories.isNotEmpty) _selectedCategoryId = _categories.first.id;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBrandId == null) {
      setState(() => _errorMessage = 'Please select a Brand.');
      return;
    }
    if (_selectedCategoryId == null) {
      setState(() => _errorMessage = 'Please select a Category.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final computer = Computer(
        productName: _nameController.text.trim(),
        brandId: _selectedBrandId!,
        categoryId: _selectedCategoryId!,
        cpu: _cpuController.text.trim(),
        ram: int.parse(_ramController.text.trim()),
        storage: int.parse(_storageController.text.trim()),
        price: double.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        soldQuantity: int.parse(_soldController.text.trim()),
        isFeatured: _isFeatured ? 1 : 0,
      );

      await widget.computerRepository.insertComputer(computer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Computer added successfully.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        _resetForm();

        // If a callback is provided (e.g. from tab navigation), notify parent
        if (widget.onComputerAdded != null) {
          widget.onComputerAdded!();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Computer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload brands and categories',
            onPressed: loadDropdownData,
          ),
        ],
      ),
      body: _isLoadingDropdowns
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: theme.colorScheme.error,
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

                    // 1. Product Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                        hintText: 'e.g. ROG Strix G16',
                        prefixIcon: Icon(Icons.laptop),
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product Name is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. Brand Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: _selectedBrandId,
                      decoration: const InputDecoration(
                        labelText: 'Brand *',
                        prefixIcon: Icon(Icons.business),
                        border: OutlineInputBorder(),
                      ),
                      items: _brands.map((b) {
                        return DropdownMenuItem<int>(
                          value: b.id,
                          child: Text(b.brandName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedBrandId = val;
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'Brand is required.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 3. Category Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((c) {
                        return DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.categoryName),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'Category is required.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. CPU
                    TextFormField(
                      controller: _cpuController,
                      decoration: const InputDecoration(
                        labelText: 'CPU *',
                        hintText: 'e.g. Intel Core i7-13650HX',
                        prefixIcon: Icon(Icons.memory),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'CPU is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 5 & 6. RAM and Storage in a Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ramController,
                            decoration: const InputDecoration(
                              labelText: 'RAM (GB) *',
                              hintText: '4 – 128',
                              prefixIcon: Icon(Icons.developer_board),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'RAM is required.';
                              }
                              final ram = int.tryParse(value.trim());
                              if (ram == null) return 'Enter a number.';
                              if (ram < 4 || ram > 128) {
                                return 'Range: 4 – 128 GB';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _storageController,
                            decoration: const InputDecoration(
                              labelText: 'Storage (GB) *',
                              hintText: '128 – 4096',
                              prefixIcon: Icon(Icons.storage),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Storage is required.';
                              }
                              final storage = int.tryParse(value.trim());
                              if (storage == null) return 'Enter a number.';
                              if (storage < 128 || storage > 4096) {
                                return 'Range: 128 – 4096 GB';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 7. Price
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (\$) *',
                        hintText: 'e.g. 1250.00',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Price is required.';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null) return 'Enter a valid price.';
                        if (price <= 0) {
                          return 'Price must be greater than 0.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 8 & 9. Stock & Sold Quantity in a Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                              labelText: 'Stock *',
                              hintText: '>= 0',
                              prefixIcon: Icon(Icons.inventory_2),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Stock is required.';
                              }
                              final stock = int.tryParse(value.trim());
                              if (stock == null) return 'Enter a number.';
                              if (stock < 0) {
                                return 'Stock must be >= 0.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _soldController,
                            decoration: const InputDecoration(
                              labelText: 'Sold Quantity *',
                              hintText: '>= 0',
                              prefixIcon: Icon(Icons.sell),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Sold is required.';
                              }
                              final sold = int.tryParse(value.trim());
                              if (sold == null) return 'Enter a number.';
                              if (sold < 0) {
                                return 'Sold must be >= 0.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 10. Featured Switch
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Featured Product',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Highlight this product on the Featured tab and store',
                        ),
                        secondary: Icon(
                          _isFeatured ? Icons.star : Icons.star_border,
                          color: _isFeatured ? Colors.amber : Colors.grey,
                        ),
                        value: _isFeatured,
                        onChanged: (val) {
                          setState(() {
                            _isFeatured = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: Text(
                        _isSubmitting ? 'Saving...' : 'Add Computer',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
