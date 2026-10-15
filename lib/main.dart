import 'package:flutter/material.dart';

import 'database/platform_database.dart';
import 'screens/main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabaseForPlatform();
  runApp(const RecurringBillsApp());
}

class RecurringBillsApp extends StatelessWidget {
  const RecurringBillsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Recurring Bills',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6200EE)),
      scaffoldBackgroundColor: const Color(0xFFF8F8F8),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFF4B4747),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF6200EE),
        unselectedItemColor: Color(0xFF9A9A9A),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE1E1E1)),
        ),
      ),
      useMaterial3: true,
    ),
    home: const MainScreen(),
  );
}
