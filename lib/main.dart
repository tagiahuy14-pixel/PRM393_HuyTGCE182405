import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'screens/product_grid_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Product Dashboard',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/products': (context) => const ProductGridScreen(),
      },
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
