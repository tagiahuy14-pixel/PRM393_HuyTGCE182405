import 'package:flutter/material.dart';

import '../models/bill.dart';

const _categories = ['Utilities', 'Subscription', 'Rent', 'Finance', 'Health'];
const _statuses = ['Unpaid', 'Paid'];

class BillForm extends StatefulWidget {
  const BillForm({
    super.key,
    this.initialBill,
    required this.submitLabel,
    required this.onSubmit,
    required this.actions,
  });
  final Bill? initialBill;
  final String submitLabel;
  final Future<void> Function(Bill bill) onSubmit;
  final List<Widget> actions;
  @override
  State<BillForm> createState() => _BillFormState();
}

class _BillFormState extends State<BillForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  String? _category;
  String _status = 'Unpaid';
  DateTime? _date;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    final b = widget.initialBill;
    _name = TextEditingController(text: b?.billName ?? '');
    _amount = TextEditingController(text: b?.amount.toStringAsFixed(0) ?? '');
    _category = b?.category;
    _status = b?.status ?? 'Unpaid';
    _date = b == null ? null : DateTime.tryParse(b.dueDate);
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(
        Bill(
          id: widget.initialBill?.id,
          billName: _name.text.trim(),
          category: _category!,
          amount: double.parse(_amount.text.trim()),
          status: _status,
          dueDate: _date!.toIso8601String().substring(0, 10),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: _formKey,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _FormLabel('Bill Name *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                hintText: 'e.g. Electricity - October',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Bill name cannot be empty.'
                  : null,
            ),
            const SizedBox(height: 18),
            const _FormLabel('Category *'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(),
              items: _categories
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v),
              validator: (v) => v == null ? 'Please select a category.' : null,
            ),
            const SizedBox(height: 18),
            const _FormLabel('Amount (VND) *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(hintText: 'e.g. 850000'),
              validator: (v) {
                final value = double.tryParse(v?.trim() ?? '');
                return value == null || value <= 0
                    ? 'Enter a valid positive amount.'
                    : null;
              },
            ),
            const SizedBox(height: 18),
            const _FormLabel('Due Date (YYYY-MM-DD) *'),
            const SizedBox(height: 6),
            FormField<DateTime>(
              validator: (_) =>
                  _date == null ? 'Please select a due date.' : null,
              builder: (state) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _date == null
                                  ? 'e.g. 2025-10-30'
                                  : _date!.toIso8601String().substring(0, 10),
                              style: TextStyle(
                                color: _date == null
                                    ? Colors.black38
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_today_outlined, size: 18),
                        ],
                      ),
                    ),
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        state.errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _FormLabel('Status *'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(),
              items: _statuses
                  .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                  .toList(),
              onChanged: (v) => setState(() => _status = v!),
              validator: (v) =>
                  _statuses.contains(v) ? null : 'Select Paid or Unpaid.',
            ),
            const SizedBox(height: 24),
            _ActionRow(
              label: widget.submitLabel,
              saving: _saving,
              onSave: _save,
              actions: widget.actions,
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.saving,
    required this.onSave,
    required this.actions,
  });

  final String label;
  final bool saving;
  final VoidCallback onSave;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: saving ? null : onSave,
          style: _buttonStyle(const Color(0xFF49B450)),
          icon: Icon(
            label == 'Save' ? Icons.check_circle : Icons.save_outlined,
            size: 15,
          ),
          label: saving
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
        ),
      ),
      for (final action in actions) ...[
        const SizedBox(width: 8),
        Expanded(child: action),
      ],
    ],
  );

  static ButtonStyle _buttonStyle(Color color) => ElevatedButton.styleFrom(
    minimumSize: const Size(0, 36),
    elevation: 2,
    backgroundColor: color,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
  );
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );
}
