# Android 15+ System Bar Handling

Android 15 (API 35) deprecated the theme-XML approach to opting out of edge-to-edge display (`android:windowOptOut`/forcing non-edge-to-edge via manifest/theme flags triggers deprecation warnings and stops working in a future API level). Caravella handles system bars entirely from Flutter instead of theme XML.

## Where it's implemented

`AppInitialization.configureSystemUI()` (`lib/main/app_initialization.dart`), called once during startup (see [Architecture Overview § startup sequence](ARCHITECTURE.md#app-startup-sequence)):

```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
SystemChrome.setSystemUIOverlayStyle(
  const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ),
);
```

This puts the app in edge-to-edge mode with fully transparent system bars up front. Icon brightness (light vs. dark status/nav bar icons) is **not** set here — it's managed dynamically per-screen based on the active theme by `AppSystemUI` (`caravella_core_ui`, see [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md)), which wraps screens in an `AnnotatedRegion<SystemUiOverlayStyle>` and recomputes light/dark icon style from the current `ColorScheme`.

## What NOT to do

Do not add `android:statusBarColor`/`android:navigationBarColor`/`windowLightStatusBar` overrides to `android/app/src/main/res/values*/styles.xml` to control system bar appearance — `windowLightStatusBar` is still present there today only to set the **initial** (pre-Flutter-frame) launch-screen icon contrast for light vs. dark mode (`values/styles.xml` vs `values-night/styles.xml`), not as an ongoing system-bar control mechanism. Any dynamic system-bar color/contrast behavior belongs in `AppSystemUI`/`configureSystemUI`, not in native theme resources.

## See also

- [Architecture Overview § app startup sequence](ARCHITECTURE.md#app-startup-sequence)
- [caravella_core_ui reference § AppSystemUI](PACKAGE_CARAVELLA_CORE_UI.md#widgets-libwidgets)
