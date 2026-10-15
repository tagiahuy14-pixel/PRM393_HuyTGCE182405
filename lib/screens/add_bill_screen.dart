import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/bill.dart';
import 'bill_form.dart';

class AddBillScreen extends StatelessWidget {
  const AddBillScreen({super.key});

  Future<void> _showSuccess(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Success'),
      content: const Text('Bill added successfully'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BillForm(
      submitLabel: 'Save',
      actions: [
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 36),
            elevation: 2,
            backgroundColor: const Color(0xFF808080),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          icon: const Icon(Icons.cancel, size: 15),
          label: const Text('Back'),
        ),
      ],
      onSubmit: (Bill bill) async {
        await DatabaseHelper.instance.insertBill(bill);
        if (context.mounted) {
          await _showSuccess(context);
        }
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      },
    ),
  );
}
