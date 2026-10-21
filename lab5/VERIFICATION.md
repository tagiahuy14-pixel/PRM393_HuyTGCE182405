# Executed verification

Verified on 21 October 2026 (Asia/Saigon).

Environment: Flutter 3.47.6, Dart 3.13.5, Windows, Android SDK 36.1,
Pixel 8 emulator running Android 15 / API 35 (`emulator-5554`).

| Check | Executed result |
| --- | --- |
| `flutter pub get` | Passed; dependencies resolved and lockfile generated. |
| `dart format lib test integration_test` | Passed. |
| `dart format --output=none --set-exit-if-changed lib test integration_test` | Passed; 17 files, zero changes. |
| `flutter analyze` | Passed; no issues found. |
| `flutter test --reporter expanded` | Passed; all 12 tests. Full local output: `verification-tests.log`. |
| `flutter test integration_test/app_test.dart -d emulator-5554 --reporter expanded` | Passed; one native Android end-to-end test. |
| `flutter build apk --debug` | Passed; normal application APK generated for Android ARM, ARM64, and x64. Full output: `verification-build.log`. |
| Install and launch normal APK with ADB | Passed; app installed and opened on Pixel 8. |
| Runtime visual inspection | Home and Add screenshots captured and inspected; see `docs/screenshots/`. |
| iOS build/run | Not executed: macOS/Xcode unavailable on this Windows host. |
| Windows build/run | Not executed; runner and FFI setup included as an additional development target. |

Local real-SQLite tests verify creation, generated IDs, reads, status updates,
deletion, persistence after closing/reopening the database, status filters, accurate
wishlist totals, invalid-value rejection, missing-record handling, and recovery
after failed initialization. Widget tests verify form defaults, category/status
selection, required and numeric validation, cancel/navigation, both status
transitions, shared Home/Wishlist updates, totals, confirmation/cancel deletion,
duplicate-save prevention, read/write failure feedback, and 320×568 / 800×360 layouts.

The native integration test executes the Add/Details/Wishlist/delete flow against
Android's actual sqflite plugin. It recreates the app state and database connection
and verifies that the saved item and status survive reopening. It uses and removes
an isolated test database, leaving the production database independent.

The supplied Resources folder and original standalone banner were missing. A
banner crop recovered from Figure 1 is bundled, with a functional icon fallback.
This limits banner image sharpness; it does not block app functionality.

The supplied PDF is named `Lab5.pdf`; no separate `Lab5(2).pdf` was present at the
provided path. All three pages and Figures 1–5 of `Lab5.pdf` were inspected.
