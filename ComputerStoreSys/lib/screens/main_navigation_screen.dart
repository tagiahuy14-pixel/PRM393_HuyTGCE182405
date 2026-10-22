import 'package:flutter/material.dart';

import '../services/brand_repository.dart';
import '../services/category_repository.dart';
import '../services/computer_repository.dart';
import '../services/statistics_repository.dart';
import 'brand/brand_list_screen.dart';
import 'category/category_list_screen.dart';
import 'computer/add_computer_screen.dart';
import 'featured/featured_screen.dart';
import 'statistics/statistics_screen.dart';
import 'store/store_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final ComputerRepository computerRepository;
  final BrandRepository brandRepository;
  final CategoryRepository categoryRepository;

  const MainNavigationScreen({
    super.key,
    required this.computerRepository,
    required this.brandRepository,
    required this.categoryRepository,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // GlobalKeys to trigger refresh on tab switch
  final _storeKey = GlobalKey<StoreScreenState>();
  final _addKey = GlobalKey<AddComputerScreenState>();
  final _brandKey = GlobalKey<BrandListScreenState>();
  final _categoryKey = GlobalKey<CategoryListScreenState>();
  final _statsKey = GlobalKey<StatisticsScreenState>();
  final _featuredKey = GlobalKey<FeaturedScreenState>();

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Refresh the target screen when navigated to
    switch (index) {
      case 0:
        _storeKey.currentState?.refresh();
        break;
      case 1:
        _addKey.currentState?.loadDropdownData();
        break;
      case 2:
        _brandKey.currentState?.refresh();
        break;
      case 3:
        _categoryKey.currentState?.refresh();
        break;
      case 4:
        _statsKey.currentState?.loadStatistics();
        break;
      case 5:
        _featuredKey.currentState?.loadFeatured();
        break;
    }
  }

  void _onComputerAdded() {
    // Switch to Store tab and refresh products
    setState(() {
      _currentIndex = 0;
    });
    _storeKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final screens = [
      StoreScreen(
        key: _storeKey,
        computerRepository: widget.computerRepository,
        brandRepository: widget.brandRepository,
        categoryRepository: widget.categoryRepository,
      ),
      AddComputerScreen(
        key: _addKey,
        computerRepository: widget.computerRepository,
        brandRepository: widget.brandRepository,
        categoryRepository: widget.categoryRepository,
        onComputerAdded: _onComputerAdded,
      ),
      BrandListScreen(key: _brandKey, repository: widget.brandRepository),
      CategoryListScreen(
        key: _categoryKey,
        repository: widget.categoryRepository,
      ),
      StatisticsScreen(
        key: _statsKey,
        repository: StatisticsRepository(
          helper: widget.computerRepository.dbHelper,
        ),
      ),
      FeaturedScreen(
        key: _featuredKey,
        computerRepository: widget.computerRepository,
        brandRepository: widget.brandRepository,
        categoryRepository: widget.categoryRepository,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType
            .fixed, // Essential for 6 items without shifting/overflow
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        showUnselectedLabels: true,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business_outlined),
            activeIcon: Icon(Icons.business),
            label: 'Brands',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            activeIcon: Icon(Icons.star),
            label: 'Featured',
          ),
        ],
      ),
    );
  }
}
