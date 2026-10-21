import 'dart:async';

import 'package:flutter/material.dart';

import 'controllers/auth_controller.dart';
import 'controllers/library_controller.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/session_service.dart';
import 'services/song_database.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MusicManagerApp());
}

class MusicManagerApp extends StatefulWidget {
  const MusicManagerApp({super.key, this.auth, this.library});
  final AuthController? auth;
  final LibraryController? library;
  @override
  State<MusicManagerApp> createState() => _MusicManagerAppState();
}

class _MusicManagerAppState extends State<MusicManagerApp>
    with WidgetsBindingObserver {
  late final AuthController _auth;
  late final LibraryController _library;

  @override
  void initState() {
    super.initState();
    _auth = widget.auth ?? AuthController(SessionService());
    _library = widget.library ?? LibraryController(SongDatabase());
    WidgetsBinding.instance.addObserver(this);
    unawaited(_auth.restore());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _auth.authenticated) {
      unawaited(_library.refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.auth == null) _auth.dispose();
    if (widget.library == null) {
      _library.dispose();
      unawaited(
        _library.repository.close().catchError((Object error) {
          debugPrint('Closing music database failed: $error');
        }),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Music Manager',
    debugShowCheckedModeBanner: false,
    theme: musicTheme(),
    home: ListenableBuilder(
      listenable: _auth,
      builder: (context, child) {
        if (_auth.initializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (_auth.startupError != null) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 16),
                    Text(_auth.startupError!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _auth.restore,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return _auth.authenticated
            ? HomeScreen(auth: _auth, library: _library)
            : LoginScreen(auth: _auth);
      },
    ),
  );
}
