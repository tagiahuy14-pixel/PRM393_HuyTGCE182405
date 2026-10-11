import 'package:flutter/material.dart';

import '../services/counter_stream_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CounterStreamService _counterStreamService = CounterStreamService();

  @override
  void initState() {
    super.initState();
    _counterStreamService.start();
  }

  @override
  void dispose() {
    _counterStreamService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Counter Stream'),
      ),
      body: Center(
        child: StreamBuilder<int>(
          stream: _counterStreamService.counterStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return const Text('Có lỗi xảy ra');
            }

            if (!snapshot.hasData) {
              return const Text('Chưa có dữ liệu');
            }

            return Text(
              'Counter: ${snapshot.data}',
              style: const TextStyle(fontSize: 32),
            );
          },
        ),
      ),
    );
  }
}
