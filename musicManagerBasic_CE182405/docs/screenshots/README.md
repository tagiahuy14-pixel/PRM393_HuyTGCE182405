# Six-screen submission

These are actual Android screenshots captured by the native integration test on
the Pixel 8 emulator (Android 15 / API 35), at 1080 × 2400 pixels. All six captures
were visually inspected. The test's sample song is a fictional fixture in an
isolated test database; the production library starts empty.

| Required screen | Screenshot |
| --- | --- |
| Login | [01_login.png](01_login.png) |
| Home / Song List | [02_home.png](02_home.png) |
| Add Song | [03_add_song.png](03_add_song.png) |
| Song Detail | [04_song_detail.png](04_song_detail.png) |
| Edit Song | [05_edit_song.png](05_edit_song.png) |
| Favorite Songs | [06_favorites.png](06_favorites.png) |

To regenerate all screenshots, run from the project directory:

```sh
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5554
```
