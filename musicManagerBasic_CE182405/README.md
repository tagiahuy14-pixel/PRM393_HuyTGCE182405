# LAB 2 — Music Library Manager

Flutter application implementing all twelve tasks in the nine-page `lab2.pdf`.
Project folder: `musicManagerBasic_CE182405`.
Valid Dart package name: `music_manager_basic_ce182405`.

## Run

From the workspace root:

```powershell
cd musicManagerBasic_CE182405
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Use your connected Android device ID if different. The available Pixel 8 emulator
can be started with `flutter emulators --launch Pixel_8`. VS Code's workspace
launch configuration also targets this project. The original root Flutter template
is preserved; run this lab from its named folder.

On macOS with Xcode and an iOS simulator configured:

```sh
flutter pub get
flutter run -d <ios-device-id>
```

The intended targets are Android and iOS. Desktop and web runners are not part of
this lab. SQLite FFI is a development dependency used by the local database tests.

Login account required by the assignment:

```text
Username: admin
Password: 123456
```

Credentials are compared directly in code. SharedPreferences stores only the
`isLogin` boolean; neither username nor password is saved. Logout removes that
session flag without deleting songs.

## All twelve tasks

| Task | Implementation |
| --- | --- |
| 1. Login | Required-field validation, hard-coded account, invalid-credential feedback, Home after successful session write. |
| 2. Session | SharedPreferences restoration on startup with retry for storage errors. |
| 3. Logout | Await session removal, return to Login, show “Logged out successfully”. |
| 4. Home | `ListView.builder`, title/artist/year, Add, Details, Favorites, Logout, empty states. |
| 5. Add | Validated title, artist, release year, genre; auto ID; `isFavorite = 0`; immediate Home update. |
| 6. Details | All song information, ID, favorite state, Edit/Delete/Favorite actions. |
| 7. Edit | All four song fields editable; updates Details, Home, and Favorites while preserving favorite state. |
| 8. Delete | Confirmation/cancel dialog, SQLite deletion, synchronized lists, success SnackBar. |
| 9. Search | Case-insensitive title OR artist matching, updated as the user types. |
| 10. Filters | Pop/Rock/EDM/Ballad, current year/last five years/all; combined with search. |
| 11. Favorite | Toggle the integer `Song.isFavorite` between 0 and 1; persist before updating the UI. |
| 12. Favorites | Favorites-only list, heart action to remove, shared state with Home and Details. |

The six screens are Login, Home, Add Song, Song Details, Edit Song, and Favorite
Songs. Reusable forms, cards, feedback, and layout widgets keep their behavior and
styling consistent. Lists and forms scroll on short screens; content width is
bounded on wide displays. Failed writes preserve current data and form input.
Buttons disable during writes to prevent duplicate submissions.

Search and both filters combine with AND. “Last 5 years” includes the current year
and the previous four calendar years. In 2026 this is 2022–2026, inclusive.
Release years must be four digits from 1000 through the current year. Blank titles
and artists are rejected; both are limited to 120 characters.

## Single-table database

The only application table is exactly `Song`:

```sql
Song(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  artist TEXT,
  year TEXT,
  genre TEXT,
  isFavorite INTEGER DEFAULT 0
)
```

The actual schema adds NOT NULL and CHECK constraints. There are no User or
Favorite tables and no backend, Firebase, or encryption layer. SQLite creates its
own internal `sqlite_sequence` bookkeeping table for AUTOINCREMENT, and Android
adds its internal `android_metadata` locale table. Neither is an application table.
Tests explicitly inspect `sqlite_master` and verify that `Song`
is the sole application table.

`music_library.db` lives in sqflite's platform database directory. It persists
across app restarts. The production library starts empty; sample songs in tests
and screenshots are isolated test fixtures, not automatically inserted app data.

## Verification

```sh
flutter pub get
dart format lib test integration_test test_driver
flutter analyze
flutter test
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5554
flutter build apk --debug
```

The native test uses actual SQLite and SharedPreferences and captures screenshots
of all six screens into `docs/screenshots/`. Its song database is isolated from the
production library and deleted after the test. It also recreates controllers and
database connections to verify session and song persistence, including after logout.

See [VERIFICATION.md](VERIFICATION.md) for executed results and limitations,
[CHANGED_FILES.md](CHANGED_FILES.md) for the file manifest, and
[screenshots](docs/screenshots/README.md) for the six-screen submission.

API references: [sqflite](https://pub.dev/packages/sqflite) and
[SharedPreferences](https://pub.dev/packages/shared_preferences).
