import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart' show rootScaffoldMessenger; // for fallback usage

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
  }) {
    // If the context is no longer mounted we use the root scaffold messenger.
    // This avoids "Looking up a deactivated widget's ancestor" errors when an
    // async operation finishes after a route/sheet was closed.
    final bool contextMounted = context.mounted;
    final scaffoldMessenger = contextMounted
        ? ScaffoldMessenger.maybeOf(context)
        : rootScaffoldMessenger;
    if (scaffoldMessenger == null) {
      // Nowhere safe to show the toast; silently ignore.
      return;
    }

    // Delegate to the centralized helper using an appropriate context for
    // localization/theme. If the provided context is no longer mounted we
    // fall back to the root scaffold messenger's context (if any).
    final BuildContext referenceContext = contextMounted
        ? context
        : (rootScaffoldMessenger?.context ?? context);
    _showUsingMessenger(
      scaffoldMessenger,
      referenceContext,
      message,
      duration: duration,
      type: type,
      icon: icon,
    );
  }

  static String _getTypeDescription(BuildContext context, ToastType type) {
    final localizations = AppLocalizations.of(context);
    switch (type) {
      case ToastType.success:
        return localizations.accessibility_toast_success;
      case ToastType.error:
        return localizations.accessibility_toast_error;
      case ToastType.info:
        return localizations.accessibility_toast_info;
    }
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
  }) {
    _showUsingMessenger(
      messenger,
      messenger.context,
      message,
      duration: duration,
      type: type,
      icon: icon,
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
  }) {
    final theme = Theme.of(referenceContext);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData effectiveIcon;

    switch (type) {
      case ToastType.success:
        backgroundColor = colorScheme.primaryFixedDim;
        textColor = colorScheme.onPrimaryFixed;
        effectiveIcon = icon ?? Icons.check_circle_outline_rounded;
        break;
      case ToastType.error:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        effectiveIcon = icon ?? Icons.error_outline;
        break;
      case ToastType.info:
        backgroundColor = colorScheme.primaryFixed;
        textColor = colorScheme.onPrimaryFixed;
        effectiveIcon = icon ?? Icons.info_outline;
        break;
    }

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Semantics(
          liveRegion: true,
          label: '${_getTypeDescription(referenceContext, type)}: $message',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                effectiveIcon,
                color: textColor,
                size: 20,
                semanticLabel: _getTypeDescription(referenceContext, type),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

enum ToastType { info, success, error }
