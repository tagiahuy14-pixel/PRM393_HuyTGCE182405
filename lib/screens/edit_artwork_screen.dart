import 'package:flutter/material.dart';

import '../models/artwork.dart';
import '../services/database_helper.dart';

class EditArtworkScreen extends StatefulWidget {
  final Artwork artwork;

  const EditArtworkScreen({super.key, required this.artwork});

  @override
  State<EditArtworkScreen> createState() => _EditArtworkScreenState();
}

class _EditArtworkScreenState extends State<EditArtworkScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _yearController;
  late final TextEditingController _descriptionController;

  late String _selectedCategory;
  final List<String> _categories = [
    'Abstract',
    'Realism',
    'Landscape',
    'Portrait',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.artwork.title);
    _artistController = TextEditingController(text: widget.artwork.artist);
    _yearController = TextEditingController(text: widget.artwork.year);
    _descriptionController = TextEditingController(
      text: widget.artwork.description,
    );

    _selectedCategory = _categories.contains(widget.artwork.category)
        ? widget.artwork.category
        : _categories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedArtwork = widget.artwork.copyWith(
        title: _titleController.text.trim(),
        artist: _artistController.text.trim(),
        year: _yearController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
      );

      await DatabaseHelper.instance.updateArtwork(updatedArtwork);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Artwork updated successfully'),
          backgroundColor: Color(0xFF00796B),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update artwork: $e'),
          backgroundColor: const Color(0xFFC62828),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF00796B);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Artwork',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Update Artwork',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                _buildFieldLabel('Title'),
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration(
                    hint: 'Enter title',
                    icon: Icons.title,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'This is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Artist
                _buildFieldLabel('Artist'),
                TextFormField(
                  controller: _artistController,
                  decoration: _buildInputDecoration(
                    hint: 'Enter artist name',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Artist is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Year
                _buildFieldLabel('Year'),
                TextFormField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  decoration: _buildInputDecoration(
                    hint: 'e.g. 2026',
                    icon: Icons.calendar_today_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Year is required';
                    }
                    final year = int.tryParse(value.trim());
                    if (year == null || year <= 0 || year > 2100) {
                      return 'Please enter a valid year';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                _buildFieldLabel('Category'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: _buildInputDecoration(
                    hint: 'Select category',
                    icon: Icons.category_outlined,
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Description
                _buildFieldLabel('Description'),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: _buildInputDecoration(
                    hint: 'Enter artwork description',
                    icon: Icons.notes_outlined,
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Save Changes Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF4B5563)),
      filled: true,
      fillColor: Colors.white,
      alignLabelWithHint: alignLabelWithHint,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00796B), width: 1.8),
      ),
    );
  }
}
