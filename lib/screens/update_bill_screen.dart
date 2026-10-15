import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/bill.dart';
import 'bill_form.dart';

class UpdateBillScreen extends StatelessWidget {
  const UpdateBillScreen({super.key, required this.bill});
  final Bill bill;

  Future<void> _showSuccess(BuildContext context, String message) =>
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete bill?'),
        content: Text('Delete ${bill.billName} permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.deleteBill(bill.id!);
      if (context.mounted) {
        await _showSuccess(context, 'Bill deleted');
      }
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: BillForm(
      initialBill: bill,
      submitLabel: 'Update',
      actions: [
        ElevatedButton.icon(
          onPressed: () => _delete(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 36),
            elevation: 2,
            backgroundColor: const Color(0xFFC90024),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          icon: const Icon(Icons.delete_outline, size: 15),
          label: const Text('Delete'),
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(0, 36),
            elevation: 2,
            backgroundColor: const Color(0xFF808080),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          icon: const Icon(Icons.arrow_back, size: 15),
          label: const Text('Back'),
        ),
      ],
      onSubmit: (updated) async {
        await DatabaseHelper.instance.updateBill(updated);
        if (context.mounted) {
          await _showSuccess(context, 'Bill updated successfully');
        }
        if (context.mounted) {
          Navigator.pop(context, true);
        }
      },
    ),
  );
}
