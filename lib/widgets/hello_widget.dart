import 'package:flutter/material.dart';

class HelloWidget extends StatelessWidget {
  const HelloWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Hello Flutter', style: TextStyle(fontSize: 24));
  }
}
