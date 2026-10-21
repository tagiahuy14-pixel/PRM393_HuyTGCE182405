# Delivery manifest

The complete application is in `lab5/`. The original root Dart application and
platform runners were preserved. Existing Android, iOS, and Windows runner files
were copied into the new project, with mobile display names updated.

Workspace changes:

- `README.md`: points to the completed project and run instructions.
- `.gitignore`: excludes temporary PDF-inspection tooling.
- `.vscode/launch.json`: launches `lab5/lib/main.dart` from the workspace.

New application source files (excluding ignored generated files):

- `lab5/.gitignore`
- `lab5/.metadata`
- `lab5/CHANGED_FILES.md`
- `lab5/README.md`
- `lab5/VERIFICATION.md`
- `lab5/analysis_options.yaml`
- `lab5/android/.gitignore`
- `lab5/android/app/build.gradle.kts`
- `lab5/android/app/src/debug/AndroidManifest.xml`
- `lab5/android/app/src/main/AndroidManifest.xml`
- `lab5/android/app/src/main/kotlin/com/example/lab5/MainActivity.kt`
- `lab5/android/app/src/main/res/drawable-v21/launch_background.xml`
- `lab5/android/app/src/main/res/drawable/launch_background.xml`
- `lab5/android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
- `lab5/android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
- `lab5/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
- `lab5/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
- `lab5/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
- `lab5/android/app/src/main/res/values-night/styles.xml`
- `lab5/android/app/src/main/res/values/styles.xml`
- `lab5/android/app/src/profile/AndroidManifest.xml`
- `lab5/android/build.gradle.kts`
- `lab5/android/gradle.properties`
- `lab5/android/gradle/wrapper/gradle-wrapper.properties`
- `lab5/android/settings.gradle.kts`
- `lab5/assets/README.md`
- `lab5/assets/images/shopping_banner.png`
- `lab5/docs/screenshots/README.md`
- `lab5/docs/screenshots/add_item.png`
- `lab5/docs/screenshots/home_empty.png`
- `lab5/integration_test/app_test.dart`
- `lab5/ios/.gitignore`
- `lab5/ios/Flutter/AppFrameworkInfo.plist`
- `lab5/ios/Flutter/Debug.xcconfig`
- `lab5/ios/Flutter/Release.xcconfig`
- `lab5/ios/Runner.xcodeproj/project.pbxproj`
- `lab5/ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata`
- `lab5/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist`
- `lab5/ios/Runner.xcodeproj/project.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings`
- `lab5/ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`
- `lab5/ios/Runner.xcworkspace/contents.xcworkspacedata`
- `lab5/ios/Runner.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist`
- `lab5/ios/Runner.xcworkspace/xcshareddata/WorkspaceSettings.xcsettings`
- `lab5/ios/Runner/AppDelegate.swift`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png`
- `lab5/ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png`
- `lab5/ios/Runner/Assets.xcassets/LaunchImage.imageset/Contents.json`
- `lab5/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png`
- `lab5/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png`
- `lab5/ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png`
- `lab5/ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md`
- `lab5/ios/Runner/Base.lproj/LaunchScreen.storyboard`
- `lab5/ios/Runner/Base.lproj/Main.storyboard`
- `lab5/ios/Runner/Info.plist`
- `lab5/ios/Runner/Runner-Bridging-Header.h`
- `lab5/ios/Runner/SceneDelegate.swift`
- `lab5/ios/RunnerTests/RunnerTests.swift`
- `lab5/lib/main.dart`
- `lab5/lib/models/shopping_item.dart`
- `lab5/lib/screens/add_item_screen.dart`
- `lab5/lib/screens/home_screen.dart`
- `lab5/lib/screens/item_detail_screen.dart`
- `lab5/lib/screens/wishlist_screen.dart`
- `lab5/lib/services/shopping_database.dart`
- `lab5/lib/services/shopping_store.dart`
- `lab5/lib/theme.dart`
- `lab5/lib/utils/currency.dart`
- `lab5/lib/utils/item_validation.dart`
- `lab5/lib/widgets/empty_state.dart`
- `lab5/lib/widgets/feedback_dialog.dart`
- `lab5/lib/widgets/shopping_item_card.dart`
- `lab5/pubspec.lock`
- `lab5/pubspec.yaml`
- `lab5/test/database_test.dart`
- `lab5/test/widget_test.dart`
- `lab5/windows/.gitignore`
- `lab5/windows/CMakeLists.txt`
- `lab5/windows/flutter/CMakeLists.txt`
- `lab5/windows/flutter/generated_plugin_registrant.cc`
- `lab5/windows/flutter/generated_plugin_registrant.h`
- `lab5/windows/flutter/generated_plugins.cmake`
- `lab5/windows/runner/CMakeLists.txt`
- `lab5/windows/runner/Runner.rc`
- `lab5/windows/runner/flutter_window.cpp`
- `lab5/windows/runner/flutter_window.h`
- `lab5/windows/runner/main.cpp`
- `lab5/windows/runner/resource.h`
- `lab5/windows/runner/resources/app_icon.ico`
- `lab5/windows/runner/runner.exe.manifest`
- `lab5/windows/runner/utils.cpp`
- `lab5/windows/runner/utils.h`
- `lab5/windows/runner/win32_window.cpp`
- `lab5/windows/runner/win32_window.h`

Generated verification artifacts (not source): `lab5/verification-tests.log`,
`lab5/verification-build.log`, and the normal app APK at
`lab5/build/app/outputs/flutter-apk/app-debug.apk`.
Build output, local SDK paths, package caches, and generated plugin metadata are
ignored by the project's .gitignore.
