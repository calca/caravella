import 'package:flutter/material.dart';

/// A Material 3 styled dialog wrapper that provides consistent styling
/// for all AlertDialogs in the app according to M3 design specifications.
class Material3Dialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? icon;
  final MainAxisAlignment actionsAlignment;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? titlePadding;
  final EdgeInsetsGeometry? actionsPadding;

  const Material3Dialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.icon,
    this.actionsAlignment = MainAxisAlignment.end,
    this.contentPadding,
    this.titlePadding,
    this.actionsPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AlertDialog(
      // Material 3 dialog shape with 28dp radius
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      // Use M3 surface container high for elevation
      backgroundColor: colorScheme.surfaceContainerHigh,
      // Material 3 elevation for dialogs
      elevation: 6,
      // Standard M3 content padding
      contentPadding: contentPadding ?? const EdgeInsets.fromLTRB(24, 20, 24, 24),
      titlePadding: titlePadding ?? const EdgeInsets.fromLTRB(24, 24, 24, 0),
      actionsPadding: actionsPadding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actionsAlignment: actionsAlignment,
      icon: icon,
      title: title != null ? DefaultTextStyle(
        style: theme.textTheme.titleLarge!.copyWith(
          color: colorScheme.onSurface,
        ),
        child: title!,
      ) : null,
      content: content != null ? DefaultTextStyle(
        style: theme.textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        child: content!,
      ) : null,
      actions: actions,
    );
  }
}

/// Helper class for creating common Material 3 dialog action buttons
class Material3DialogActions {
  /// Creates a standard cancel button (TextButton)
  static Widget cancel(
    BuildContext context, 
    String text, {
    VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed ?? () => Navigator.of(context).pop(false),
      child: Text(text),
    );
  }

  /// Creates a primary action button (FilledButton)
  static Widget primary(
    BuildContext context,
    String text, {
    VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return FilledButton(
      onPressed: onPressed,
      style: isDestructive ? FilledButton.styleFrom(
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
      ) : null,
      child: Text(text),
    );
  }

  /// Creates a secondary action button (OutlinedButton) 
  static Widget secondary(
    BuildContext context,
    String text, {
    VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  /// Creates a destructive text button for dangerous actions
  static Widget destructive(
    BuildContext context,
    String text, {
    VoidCallback? onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.error,
      ),
      child: Text(text),
    );
  }
}

/// Helper functions for common dialog patterns
class Material3Dialogs {
  /// Shows a confirmation dialog with Material 3 styling
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    bool isDestructive = false,
    Widget? icon,
  }) {
    final localizations = MaterialLocalizations.of(context);
    
    return showDialog<bool>(
      context: context,
      builder: (context) => Material3Dialog(
        icon: icon,
        title: Text(title),
        content: Text(content),
        actions: [
          Material3DialogActions.cancel(
            context,
            cancelText ?? localizations.cancelButtonLabel,
          ),
          Material3DialogActions.primary(
            context,
            confirmText ?? localizations.okButtonLabel,
            isDestructive: isDestructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  /// Shows an information dialog with Material 3 styling
  static Future<void> showInfo(
    BuildContext context, {
    required String title,
    required String content,
    String? buttonText,
    Widget? icon,
  }) {
    final localizations = MaterialLocalizations.of(context);
    
    return showDialog<void>(
      context: context,
      builder: (context) => Material3Dialog(
        icon: icon,
        title: Text(title),
        content: Text(content),
        actions: [
          Material3DialogActions.primary(
            context,
            buttonText ?? localizations.okButtonLabel,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}