import 'platform_database_stub.dart'
    if (dart.library.io) 'platform_database_io.dart';

Future<void> initializeDatabaseForPlatform() => initializeDatabase();
