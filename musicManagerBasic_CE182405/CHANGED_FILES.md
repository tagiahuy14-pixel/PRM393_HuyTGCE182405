# Changed files and delivery manifest

The complete LAB 2 project was created in `musicManagerBasic_CE182405/`.
The pre-existing root Flutter template and the other lab branches were preserved.

Workspace changes:

- `README.md`: links to the implemented project and run instructions.
- `.gitignore`: ignores generated output in nested Flutter projects.
- `.vscode/launch.json`: launches the completed music-manager app.

Application organization:

- `lib/models/`: immutable Song model and combined search/year/genre filtering.
- `lib/services/`: the single-table SQLite repository and SharedPreferences session.
- `lib/controllers/`: authentication and shared library state.
- `lib/screens/`: Login, Home, Add, Details, Edit, and Favorites.
- `lib/widgets/`: reusable forms, cards, feedback, empty states, and content width.
- `test/`: local SQLite, session, filter, validation, error, and screen tests.
- `integration_test/`, `test_driver/`: real Android end-to-end tests and screenshots.
- `android/`, `ios/`: generated Flutter runners with the Music Manager display name.
- `docs/screenshots/`: actual captures of all six required screens.

Complete application source/documentation manifest (generated build/cache files excluded):

- `musicManagerBasic_CE182405/.gitignore`
- `musicManagerBasic_CE182405/.metadata`
- `musicManagerBasic_CE182405/CHANGED_FILES.md`
- `musicManagerBasic_CE182405/README.md`
- `musicManagerBasic_CE182405/VERIFICATION.md`
- `musicManagerBasic_CE182405/analysis_options.yaml`
- `musicManagerBasic_CE182405/android/.gitignore`
- `musicManagerBasic_CE182405/android/app/build.gradle.kts`
- `musicManagerBasic_CE182405/android/app/src/debug/AndroidManifest.xml`
- `musicManagerBasic_CE182405/android/app/src/main/AndroidManifest.xml`
- `musicManagerBasic_CE182405/android/app/src/main/kotlin/com/example/music_manager_basic_ce182405/MainActivity.kt`
- `musicManagerBasic_CE182405/android/app/src/main/res/drawable-v21/launch_background.xml`
- `musicManagerBasic_CE182405/android/app/src/main/res/drawable/launch_background.xml`
- `musicManagerBasic_CE182405/android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `musicManagerBasic_CE182405/android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `musicManagerBasic_CE182405/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `musicManagerBasic_CE182405/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `musicManagerBasic_CE182405/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- `musicManagerBasic_CE182405/android/app/src/main/res/values-night/styles.xml`
- `musicManagerBasic_CE182405/android/app/src/main/res/values/styles.xml`
- `musicManagerBasic_CE182405/android/app/src/profile/AndroidManifest.xml`
- `musicManagerBasic_CE182405/android/build.gradle.kts`
- `musicManagerBasic_CE182405/android/gradle.properties`
- `musicManagerBasic_CE182405/android/gradle/wrapper/gradle-wrapper.properties`
- `musicManagerBasic_CE182405/android/settings.gradle.kts`
- `musicManagerBasic_CE182405/docs/screenshots/01_login.png`
- `musicManagerBasic_CE182405/docs/screenshots/02_home.png`
- `musicManagerBasic_CE182405/docs/screenshots/03_add_song.png`
- `musicManagerBasic_CE182405/docs/screenshots/04_song_detail.png`
- `musicManagerBasic_CE182405/docs/screenshots/05_edit_song.png`
- `musicManagerBasic_CE182405/docs/screenshots/06_favorites.png`
- `musicManagerBasic_CE182405/docs/screenshots/README.md`
- `musicManagerBasic_CE182405/integration_test/app_test.dart`
- `musicManagerBasic_CE182405/ios/.gitignore`
- `musicManagerBasic_CE182405/ios/Flutter/AppFrameworkInfo.plist`
- `musicManagerBasic_CE182405/ios/Flutter/Debug.xcconfig`
- `musicManagerBasic_CE182405/ios/Flutter/Release.xcconfig`
- `musicManagerBasic_CE182405/ios/Runner.xcodeproj/project.pbxproj`
- `musicManagerBasic_CE182405/ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata`
- `musicManagerBasic_CE182405/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist`
- `musicManagerBasic_CE182405/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings`
- `musicManagerBasic_CE182405/ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`
- `musicManagerBasic_CE182405/ios/Runner.xcworkspace/contents.xcworkspacedata`
- `musicManagerBasic_CE182405/ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist`
- `musicManagerBasic_CE182405/ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings`
- `musicManagerBasic_CE182405/ios/Runner/AppDelegate.swift`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png`
- `musicManagerBasic_CE182405/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md`
- `musicManagerBasic_CE182405/ios/Runner/Base.lproj/LaunchScreen.storyboard`
- `musicManagerBasic_CE182405/ios/Runner/Base.lproj/Main.storyboard`
- `musicManagerBasic_CE182405/ios/Runner/Info.plist`
- `musicManagerBasic_CE182405/ios/Runner/Runner-Bridging-Header.h`
- `musicManagerBasic_CE182405/ios/Runner/SceneDelegate.swift`
- `musicManagerBasic_CE182405/ios/RunnerTests/RunnerTests.swift`
- `musicManagerBasic_CE182405/lib/controllers/auth_controller.dart`
- `musicManagerBasic_CE182405/lib/controllers/library_controller.dart`
- `musicManagerBasic_CE182405/lib/main.dart`
- `musicManagerBasic_CE182405/lib/models/song.dart`
- `musicManagerBasic_CE182405/lib/models/song_filter.dart`
- `musicManagerBasic_CE182405/lib/screens/add_song_screen.dart`
- `musicManagerBasic_CE182405/lib/screens/edit_song_screen.dart`
- `musicManagerBasic_CE182405/lib/screens/favorites_screen.dart`
- `musicManagerBasic_CE182405/lib/screens/home_screen.dart`
- `musicManagerBasic_CE182405/lib/screens/login_screen.dart`
- `musicManagerBasic_CE182405/lib/screens/song_detail_screen.dart`
- `musicManagerBasic_CE182405/lib/services/session_service.dart`
- `musicManagerBasic_CE182405/lib/services/song_database.dart`
- `musicManagerBasic_CE182405/lib/theme.dart`
- `musicManagerBasic_CE182405/lib/utils/validation.dart`
- `musicManagerBasic_CE182405/lib/widgets/app_feedback.dart`
- `musicManagerBasic_CE182405/lib/widgets/content_width.dart`
- `musicManagerBasic_CE182405/lib/widgets/library_empty_state.dart`
- `musicManagerBasic_CE182405/lib/widgets/song_form.dart`
- `musicManagerBasic_CE182405/lib/widgets/song_tile.dart`
- `musicManagerBasic_CE182405/pubspec.lock`
- `musicManagerBasic_CE182405/pubspec.yaml`
- `musicManagerBasic_CE182405/test/database_test.dart`
- `musicManagerBasic_CE182405/test/session_and_filter_test.dart`
- `musicManagerBasic_CE182405/test/support/fakes.dart`
- `musicManagerBasic_CE182405/test/widget_test.dart`
- `musicManagerBasic_CE182405/test_driver/integration_test.dart`

Generated local artifacts:

- `build/app/outputs/flutter-apk/app-debug.apk`: normal Android debug application.
- `build/native-verification.json`: successful native test and screenshot summary.
- `verification-tests.log`, `verification-native.log`, `verification-build.log`:
  executed command output, excluded from Git.

No application source or working code in other labs was replaced. No Git commit,
push, deployment, or publication was performed for this implementation.
