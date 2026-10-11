import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/fake_api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<Item>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = FakeApiService.fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Async Product Loader'),
            Text(
              'S\u1ea3n ph\u1ea9m h\u00f4m nay',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingView();
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 56,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'C\u00f3 l\u1ed7i x\u1ea3y ra: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data ?? const <Item>[];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              const Text(
                'DANH S\u00c1CH S\u1ea2N PH\u1ea8M',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),
              ...items.map((item) => _ProductCard(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF2563EB)),
          SizedBox(height: 16),
          Text('\u0110ang t\u1ea3i s\u1ea3n ph\u1ea9m...'),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: Color(0xFF2563EB),
          ),
        ),
        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('S\u1ea3n ph\u1ea9m t\u01b0\u01a1i ngon'),
        ),
        trailing: Text(
          '${item.price.toStringAsFixed(0)} VND',
          style: const TextStyle(
            color: Color(0xFF16A34A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
