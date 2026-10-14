import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'screens/home_screen.dart';
import 'screens/student_detail_screen.dart';
import 'screens/student_list_screen.dart';

void main() {
  runApp(const StudentManagerApp());
}

class StudentManagerApp extends StatelessWidget {
  const StudentManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Manager',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.studentList: (context) => const StudentListScreen(),
        AppRoutes.studentDetail: (context) => const StudentDetailScreen(),
      },
      onGenerateRoute: (settings) {
        debugPrint('Unexpected route requested: ${settings.name}');
        return null;
      },
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
