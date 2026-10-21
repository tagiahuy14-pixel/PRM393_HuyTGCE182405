# LAB 5 — Favorite Shopping Items

Complete Flutter application based on the supplied three-page `Lab5.pdf`, including
Figures 1–5. The package and project folder are named `lab5`. The pre-existing root
project is preserved; **run all commands from this folder**.

## Run

Flutter 3.47.6 / Dart 3.13.5 were used for implementation and verification.

```powershell
cd lab5
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Select your own Android device ID if different. Launch the configured emulator
with `flutter emulators --launch Pixel_8` if needed.

On macOS with Xcode and an iOS simulator/device configured:

```sh
flutter pub get
flutter run -d <ios-device-id>
```

The iOS runner and native sqflite plugin are included. An iOS build requires macOS
and Xcode; it cannot be executed on the Windows development host. A Windows runner
is also included and uses SQLite through sqflite_common_ffi (`flutter run -d windows`).
Web is not a target for this local SQLite lab.

## Behavior

- Home: recovered reference banner, empty state, lazy item list with all fields,
  Add Item floating button, pull to refresh, Home/Wishlist BottomNavigationBar.
- Add: name, category, numeric VND price, status defaulting to Wishlist, automatic
  ID, inline validation plus error dialog, Save/Cancel, duplicate-save prevention.
- Details: name, ID, category, price, status and one row of Toggle Status, Delete,
  Back actions. Status changes persist immediately; delete requires confirmation;
  Back returns to Home. Successful operations display dialogs as in Figure 2.
- Wishlist: only Wishlist items, lazy list, item count, accurate VND price sum and
  total at the bottom. Short screens and enlarged text use a scrollable summary.
- Errors: failed writes retain the prior item/input; failed initialization and
  loading show a retry action. All screens share one notifying store and refresh
  on app resume. SQLite commits before the in-memory view updates.

Data is stored in `favorite_shopping_items.db` under sqflite's platform database
directory. The schema uses `INTEGER PRIMARY KEY AUTOINCREMENT`, text name/category,
REAL price, and Wishlist/Purchased status with SQL constraints. There is no backend
or Firebase. Prices must be positive, use no grouping separators, and may have up
to two decimal places. Totals sum integer hundredths to avoid floating-point noise.
The database persists across app restarts and is removed only if app data is cleared
or the app is uninstalled.

## Verification commands

```sh
flutter pub get
dart format lib test integration_test
flutter analyze
flutter test
flutter test integration_test/app_test.dart -d emulator-5554
flutter build apk --debug
```

`test/database_test.dart` uses real SQLite files through FFI and checks CRUD,
generated IDs, persistence on reopening, status filters, totals, invalid values,
and recovery after initialization failure. `test/widget_test.dart` checks forms,
navigation, dialogs, status synchronization, deletion, duplicate submissions,
write/read failures, and small/landscape layouts. The native integration test uses
the actual Android sqflite plugin with an isolated test database and covers the
complete UI flow plus reopening persisted data.

See [VERIFICATION.md](VERIFICATION.md) for executed results, and
[CHANGED_FILES.md](CHANGED_FILES.md) for the delivery manifest.

## Reference assets

The Resources folder was absent. The included banner was recovered from Figure 1
in the PDF; details and replacement instructions are in [assets/README.md](assets/README.md).
The app starts empty and does not add invented sample data to the production database.
