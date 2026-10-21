import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final names = <String>[];
  await integrationDriver(
    onScreenshot: (name, bytes, [arguments]) async {
      final file = File('docs/screenshots/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      names.add(name);
      return bytes.isNotEmpty;
    },
    responseDataCallback: (data) async {
      final file = File('build/native-verification.json');
      await file.parent.create(recursive: true);
      await file.writeAsString(
        jsonEncode({'passed': true, 'screenshots': names}),
      );
    },
  );
}
