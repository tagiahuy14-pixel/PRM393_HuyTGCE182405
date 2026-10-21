# Executed verification

Date: 21 October 2026, Asia/Saigon.
Environment: Flutter 3.47.6, Dart 3.13.5, Windows, Pixel 8 emulator running
Android 15 / API 35 (`emulator-5554`).

| Check | Result |
| --- | --- |
| Read the supplied PDF | All nine pages and all twelve tasks inspected. |
| `flutter pub get` | Passed; SQLite, SharedPreferences, and test dependencies resolved. |
| `dart format lib test integration_test test_driver` | Passed. |
| Format check with `--output=none --set-exit-if-changed` | Passed; 26 Dart files, zero changes. |
| `flutter analyze` | Passed; no issues found. |
| `flutter test --reporter expanded` | Passed; all 20 local tests. |
| Native `flutter drive` end-to-end test | Passed; all twelve task flows, real Android SQLite and SharedPreferences. |
| Six screen captures | Captured and visually inspected; `docs/screenshots/`. |
| `flutter build apk --debug` | Passed; normal app APK built for Android ARM, ARM64, and x64. |
| Normal APK install and cold launch | Passed on Pixel 8 via ADB; `Status: ok`, `LaunchState: COLD`; application process remained running. |

Local tests cover:

- A single `Song` application table and the exact required column names/types.
- SQLite create/read/update/delete, automatic IDs, default `isFavorite = 0`,
  both favorite transitions, favorites query, and disk persistence on reopening.
- Edits preserve favorite state; all shared views reflect updates and deletion.
- Required fields, valid release years, SQL constraints, missing-record errors,
  and initialization failure followed by successful retry.
- Hard-coded login using both username and password, invalid credentials,
  SharedPreferences session restoration, and logout persistence.
- Only `isLogin` is stored for the session; passwords are not persisted.
- Failed session writes never grant login or falsely complete logout.
- Duplicate login and duplicate song submissions are prevented.
- Case-insensitive title OR artist search combined with genre and year filters,
  including exact five-year boundaries and reset behavior.
- All six screens, dialogs, empty states, feedback, read/write errors, small phones,
  landscape, and enlarged text (320×568 at 1.5× text and 800×360 landscape).

The native test repeats login, session restoration, logout, add, edit, favorite
toggle/removal, search, filters, deletion confirmation/cancel, and deletion using
the real mobile plugins. It reconstructs application state and reopens the database
to check persisted songs, favorite status, and session flags. It uses an isolated
`lab2_integration_test.db` and removes it after success. A separate operating-system
kill/restart persistence test was not executed.

The app creates only one application table: `Song`. SQLite's `sqlite_sequence`
and Android's `android_metadata` are automatically managed internal tables.
There is no User or Favorite table, Firebase, backend, password database, or
encryption dependency.

Local command output is preserved in `verification-tests.log`,
`verification-native.log`, and `verification-build.log` (ignored by Git).
The native driver also writes `build/native-verification.json` with the pass result
and six captured screenshot names.

The normal debug APK is at `build/app/outputs/flutter-apk/app-debug.apk`.
Build output and machine-specific caches are ignored by Git.

## Remaining verification limits

- iOS source and runner are included, but iOS build/run was not executed because
  this Windows host has no macOS/Xcode toolchain.
- Verification used an Android emulator; no physical Android or iOS device was tested.
- The delivered APK is a debug build. Store release signing and publication were
  not requested or performed.
