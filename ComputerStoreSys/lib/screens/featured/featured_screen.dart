import 'package:flutter/material.dart';

import '../../models/computer.dart';
import '../../services/brand_repository.dart';
import '../../services/category_repository.dart';
import '../../services/computer_repository.dart';
import '../../widgets/computer_card.dart';
import '../computer/computer_detail_screen.dart';

class FeaturedScreen extends StatefulWidget {
  final ComputerRepository computerRepository;
  final BrandRepository brandRepository;
  final CategoryRepository categoryRepository;

  const FeaturedScreen({
    super.key,
    required this.computerRepository,
    required this.brandRepository,
    required this.categoryRepository,
  });

  @override
  State<FeaturedScreen> createState() => FeaturedScreenState();
}

class FeaturedScreenState extends State<FeaturedScreen> {
  List<Computer> _featuredComputers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    loadFeatured();
  }

  // Public method for tab switching live reload
  Future<void> loadFeatured() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await widget.computerRepository.getFeaturedComputers();
      if (mounted) {
        setState(() {
          _featuredComputers = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 26),
            SizedBox(width: 8),
            Text(
              'Featured Products',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Featured Products',
            onPressed: loadFeatured,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text('Error: $_error', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: loadFeatured,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : _featuredComputers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No featured products currently.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadFeatured,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _featuredComputers.length,
                itemBuilder: (context, index) {
                  final computer = _featuredComputers[index];
                  return ComputerCard(
                    computer: computer,
                    onTap: () async {
                      final shouldRefresh = await Navigator.of(context)
                          .push<bool>(
                            MaterialPageRoute(
                              builder: (context) => ComputerDetailScreen(
                                computerId: computer.id!,
                                computerRepository: widget.computerRepository,
                                brandRepository: widget.brandRepository,
                                categoryRepository: widget.categoryRepository,
                              ),
                            ),
                          );

                      if (shouldRefresh == true && mounted) {
                        loadFeatured();
                      }
                    },
                  );
                },
              ),
            ),
    );
  }
}
