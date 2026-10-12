import 'package:flutter/material.dart';

import '../models/plan.dart';
import '../widgets/primary_button.dart';
import 'create_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Plan> _plans = [];

  Future<void> _goToCreatePlan() async {
    final result = await Navigator.push<Plan>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePlanScreen(),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _plans.insert(0, result);
    });
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Planner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PrimaryButton(
              text: 'Create Plan',
              onPressed: _goToCreatePlan,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _plans.isEmpty
                  ? const Center(
                      child: Text(
                        'No plans yet.\nTap "Create Plan" to add one.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _plans.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final plan = _plans[index];
                        return Card(
                          child: ListTile(
                            title: Text(plan.title),
                            subtitle: Text(
                              '${_formatDate(plan.date)} • '
                              '${_formatTime(plan.time)}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
