import 'package:flutter/material.dart';

import '../widgets/counter_widget.dart';
import '../widgets/profile_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My First Flutter App')),
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [ProfileCard(), SizedBox(height: 20), CounterWidget()],
      ),
    );
  }
}
