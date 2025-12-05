import 'package:flutter/material.dart';
import 'package:zentoast/zentoast.dart';

/// Toast type for different message categories
enum ToastType { info, success, error }

/// Centralized toast system using zentoast for smooth animations and gestures.
/// Provides Material 3-styled toasts with consistent design across the app.
class AppToast {
  AppToast._();

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 2400),
    ToastType type = ToastType.info,
    IconData? icon,
    String? semanticLabel,
  }) {
    if (!context.mounted) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    Color iconColor;
    IconData effectiveIcon;

    switch (type) {
      case ToastType.success:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        iconColor = colorScheme.primary;
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

    Toast(
      height: 56,
      builder: (toast) => Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Semantics(
            liveRegion: true,
            label: semanticLabel ?? message,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(effectiveIcon, color: iconColor, size: 18),
                const SizedBox(width: 12),
                Expanded(
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
        ),
      ),
    ).show(context);
  }
}
