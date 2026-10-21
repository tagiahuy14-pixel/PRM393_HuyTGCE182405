import 'package:flutter/material.dart';

import '../models/shopping_item.dart';
import '../services/shopping_store.dart';
import '../theme.dart';
import '../utils/item_validation.dart';
import '../widgets/feedback_dialog.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key, required this.store});
  final ShoppingStore store;

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  String _category = ShoppingItem.categories.first;
  String _status = ShoppingItem.wishlist;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_form.currentState!.validate()) {
      final message =
          ItemValidation.requiredText(_name.text, 'item name') ??
          ItemValidation.price(_price.text) ??
          'Please check the form';
      await showFeedback(context, message, error: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      final saved = await widget.store.add(
        ShoppingItem(
          itemName: _name.text.trim(),
          category: _category,
          price: double.parse(_price.text.trim()),
          status: _status,
        ),
      );
      if (mounted) Navigator.pop(context, saved);
    } catch (error, stack) {
      debugPrint('Saving shopping item failed: $error\n$stack');
      if (mounted) {
        setState(() => _saving = false);
        await showFeedback(
          context,
          'Could not save the item. Your input is preserved. Please try again.',
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Add Shopping Item'),
        automaticallyImplyLeading: !_saving,
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _form,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Item Name *'),
                        TextFormField(
                          key: const Key('item-name'),
                          controller: _name,
                          enabled: !_saving,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          maxLength: 120,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Nike Air Force 1',
                            counterText: '',
                            semanticCounterText: 'Maximum 120 characters',
                          ),
                          validator: (value) =>
                              ItemValidation.requiredText(value, 'item name'),
                        ),
                        _label('Category *'),
                        DropdownButtonFormField<String>(
                          key: const Key('item-category'),
                          initialValue: _category,
                          items: ShoppingItem.categories
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: _saving
                              ? null
                              : (value) => setState(() => _category = value!),
                          validator: (value) =>
                              ItemValidation.requiredText(value, 'category'),
                        ),
                        _label('Price (VND) *'),
                        TextFormField(
                          key: const Key('item-price'),
                          controller: _price,
                          enabled: !_saving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'e.g. 2500000',
                            helperText: 'VND, no thousands separators; up to 2 decimal places',
                            helperMaxLines: 2,
                          ),
                          validator: ItemValidation.price,
                          onFieldSubmitted: (_) => _save(),
                        ),
                        _label('Status'),
                        DropdownButtonFormField<String>(
                          key: const Key('item-status'),
                          initialValue: _status,
                          items: ShoppingItem.statuses
                              .map(
                                (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ),
                              )
                              .toList(),
                          onChanged: _saving
                              ? null
                              : (value) => setState(() => _status = value!),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                key: const Key('save-item'),
                                onPressed: _saving ? null : _save,
                                style: FilledButton.styleFrom(
                                  backgroundColor: appGreen,
                                  foregroundColor: Colors.white,
                                ),
                                icon: _saving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.check_circle, size: 18),
                                label: Text(_saving ? 'Saving…' : 'Save'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _saving
                                    ? null
                                    : () => Navigator.pop(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.grey,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.cancel, size: 18),
                                label: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _label(String label) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 8),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}
