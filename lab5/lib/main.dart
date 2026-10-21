import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'screens/home_screen.dart';
import 'services/shopping_database.dart';
import 'services/shopping_store.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.store});
  final ShoppingStore? store;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final ShoppingStore _store;

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? ShoppingStore(ShoppingDatabase());
    WidgetsBinding.instance.addObserver(this);
    _store.load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _store.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.store == null) {
      _store.dispose();
      _store.database.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Favorite Shopping Items',
    debugShowCheckedModeBanner: false,
    theme: shoppingTheme(),
    home: HomeScreen(store: _store),
  );
}
