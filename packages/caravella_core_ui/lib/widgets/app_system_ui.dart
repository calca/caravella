import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized widget for managing system UI overlay styles (status bar and navigation bar).
///
/// This widget provides a consistent way to set system UI colors across the app
/// with automatic dark/light mode adaptation.
///
/// Example usage:
/// ```dart
/// AppSystemUI(
///   child: Scaffold(...),
/// )
///
/// // Custom navigation bar color
/// AppSystemUI(
///   navigationBarColor: theme.colorScheme.surfaceContainer,
///   child: Scaffold(...),
/// )
/// ```
class AppSystemUI extends StatelessWidget {
  /// The child widget to wrap with system UI styling
  final Widget child;

  /// Custom color for the navigation bar. If null, uses [ColorScheme.surface]
  final Color? navigationBarColor;

  /// Custom color for the status bar. If null, uses transparent
  final Color? statusBarColor;

  /// Whether to force light status bar icons regardless of theme
  final bool? forceStatusBarLight;

  /// Whether to force light navigation bar icons regardless of theme
  final bool? forceNavigationBarLight;

  const AppSystemUI({
    super.key,
    required this.child,
    this.navigationBarColor,
    this.statusBarColor,
    this.forceStatusBarLight,
    this.forceNavigationBarLight,
  });

  /// Creates an AppSystemUI with surface navigation bar (default for most screens)
  factory AppSystemUI.surface({Key? key, required Widget child}) {
    return AppSystemUI(key: key, child: child);
  }

  /// Creates an AppSystemUI with surfaceContainer navigation bar (for home screen)
  factory AppSystemUI.surfaceContainer({
    Key? key,
    required Widget child,
    required BuildContext context,
  }) {
    return AppSystemUI(
      key: key,
      navigationBarColor: Theme.of(context).colorScheme.surfaceContainer,
      child: child,
    );
  }

  /// Creates an AppSystemUI with custom gradient navigation bar
  factory AppSystemUI.custom({
    Key? key,
    required Widget child,
    required Color navigationBarColor,
    bool? forceNavigationBarLight,
  }) {
    return AppSystemUI(
      key: key,
      navigationBarColor: navigationBarColor,
      forceNavigationBarLight: forceNavigationBarLight,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Determine navigation bar color
    final effectiveNavBarColor =
        navigationBarColor ?? theme.colorScheme.surface;

    // Determine icon brightness
    final statusBarIconBrightness = forceStatusBarLight ?? false
        ? Brightness.light
        : (isDarkMode ? Brightness.light : Brightness.dark);

    final navBarIconBrightness = forceNavigationBarLight ?? false
        ? Brightness.light
        : (isDarkMode ? Brightness.light : Brightness.dark);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: statusBarColor ?? Colors.transparent,
        statusBarIconBrightness: statusBarIconBrightness,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: effectiveNavBarColor,
        systemNavigationBarIconBrightness: navBarIconBrightness,
      ),
      child: child,
    );
  }
}
