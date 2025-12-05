import 'package:flutter/material.dart';

/// Global key for root scaffold messenger - MUST be set by the app during initialization.
///
/// This key enables AppToast to show messages even when the original BuildContext
/// is no longer mounted (e.g., after navigation or sheet dismissal in async operations).
///
/// Setup example in your app's main widget initState():
/// ```dart
/// import 'package:caravella_core_ui/caravella_core_ui.dart' show rootScaffoldMessengerKey;
///
/// @override
/// void initState() {
///   super.initState();
///   rootScaffoldMessengerKey = _scaffoldMessengerKey;
/// }
/// ```
GlobalKey<ScaffoldMessengerState>? rootScaffoldMessengerKey;

/// Toast type for different message categories
enum ToastType { info, success, error }

/// Toast position on screen
enum ToastPosition { top, bottom }

/// Lightweight toast / inline feedback using Flutter's native SnackBar
/// with Material 3 theming and automatic queue management.
class AppToast {
  AppToast._();

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2400),
    ToastType type = ToastType.info,
    IconData? icon,
    VoidCallback? onUndo,
    String? undoLabel,
    String? semanticLabel,
  }) {
    // If the context is no longer mounted we use the root scaffold messenger.
    // This avoids "Looking up a deactivated widget's ancestor" errors when an
    // async operation finishes after a route/sheet was closed.
    final bool contextMounted = context.mounted;
    final scaffoldMessenger = contextMounted
        ? ScaffoldMessenger.maybeOf(context)
        : rootScaffoldMessengerKey?.currentState;
    if (scaffoldMessenger == null) {
      // Nowhere safe to show the toast; silently ignore.
      return;
    }

    // Delegate to the centralized helper using an appropriate context for
    // localization/theme. If the provided context is no longer mounted we
    // fall back to the root scaffold messenger's context (if any).
    final BuildContext referenceContext = contextMounted
        ? context
        : (rootScaffoldMessengerKey?.currentState?.context ?? context);
    _showUsingMessenger(
      scaffoldMessenger,
      referenceContext,
      message,
      duration: duration,
      type: type,
      icon: icon,
      onUndo: onUndo,
      undoLabel: undoLabel,
      semanticLabel: semanticLabel,
    );
  }

  /// Variant that accepts an already-obtained [ScaffoldMessengerState].
  ///
  /// Useful when the call site needs to capture the messenger before an
  /// async gap to avoid using a `BuildContext` after awaiting.
  static void showFromMessenger(
    ScaffoldMessengerState messenger,
    String message, {
    Duration duration = const Duration(milliseconds: 2400),
    ToastType type = ToastType.info,
    IconData? icon,
    VoidCallback? onUndo,
    String? undoLabel,
    String? semanticLabel,
  }) {
    _showUsingMessenger(
      messenger,
      messenger.context,
      message,
      duration: duration,
      type: type,
      icon: icon,
      onUndo: onUndo,
      undoLabel: undoLabel,
      semanticLabel: semanticLabel,
    );
  }

  /// Centralized helper that builds and shows the SnackBar using the given
  /// [ScaffoldMessengerState] and a [BuildContext] suitable for localization
  /// and theme resolution.
  static void _showUsingMessenger(
    ScaffoldMessengerState messenger,
    BuildContext referenceContext,
    String message, {
    Duration duration = const Duration(milliseconds: 2400),
    ToastType type = ToastType.info,
    IconData? icon,
    VoidCallback? onUndo,
    String? undoLabel,
    String? semanticLabel,
  }) {
    final theme = Theme.of(referenceContext);
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(referenceContext);

    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData effectiveIcon;

    switch (type) {
      case ToastType.success:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        iconColor = colorScheme.tertiary;
        effectiveIcon = icon ?? Icons.check_circle_outline_rounded;
        break;
      case ToastType.error:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        iconColor = colorScheme.error;
        effectiveIcon = icon ?? Icons.error_outline_rounded;
        break;
      case ToastType.info:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        iconColor = colorScheme.primary;
        effectiveIcon = icon ?? Icons.info_outline_rounded;
        break;
    }

    // Always position at top with safe area padding
    final margin = EdgeInsets.only(
      top: mediaQuery.padding.top + 8,
      left: 16,
      right: 16,
      bottom: 16,
    );

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Semantics(
          liveRegion: true,
          label: semanticLabel ?? message,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(effectiveIcon, color: iconColor, size: 18),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        action: onUndo != null && undoLabel != null
            ? SnackBarAction(
                label: undoLabel,
                textColor: iconColor,
                onPressed: onUndo,
              )
            : null,
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        margin: margin,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
