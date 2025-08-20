import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Determine colors and icon based on type
    Color backgroundColor;
    Color textColor;
    IconData effectiveIcon;
    
    switch (type) {
      case ToastType.success:
        backgroundColor = colorScheme.surfaceContainerHigh;
        textColor = colorScheme.onSurfaceVariant;
        effectiveIcon = icon ?? Icons.check_circle_outline_rounded;
        break;
      case ToastType.error:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        effectiveIcon = icon ?? Icons.error_outline_outlined;
        break;
      case ToastType.info:
        backgroundColor = colorScheme.surfaceContainerHigh;
        textColor = colorScheme.onSurfaceVariant;
        effectiveIcon = icon ?? Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Semantics(
          liveRegion: true,
          label: '${_getTypeDescription(type)}: $message',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                effectiveIcon,
                color: textColor,
                size: 20,
                semanticLabel: _getTypeDescription(type),
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

  static String _getTypeDescription(ToastType type) {
    switch (type) {
      case ToastType.success:
        return 'Success';
      case ToastType.error:
        return 'Error';
      case ToastType.info:
        return 'Information';
    }
  }
}

enum ToastType { info, success, error }
