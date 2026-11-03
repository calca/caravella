import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:zentoast/zentoast.dart';
import '../themes/caravella_themes.dart';

/// Toast type for different message categories
enum ToastType { info, success, error }

/// Centralized toast system using zentoast for smooth animations and gestures.
///
/// For what has no place on screen: an action with Undo, something that
/// arrived from elsewhere, the result of leaving a screen. Problems with
/// what's on screen belong there (a field's error, a row's subtitle).
///
/// A pill above the floating navigation; the type shows in the round mark
/// at the start: info a neutral icon, success a check on the primary
/// color, error a "!" on the error color with the pill in the error
/// container color.
class AppToast {
  AppToast._();

  /// How long each type stays when no [show] `duration` is given.
  static const infoDuration = Duration(seconds: 3);
  static const errorDuration = Duration(seconds: 5);

  /// A toast with an action, so there's time to reach it.
  static const actionDuration = Duration(seconds: 6);

  static void show(
    BuildContext context,
    String message, {
    Duration? duration,
    ToastType type = ToastType.info,
    IconData? icon,
    String? semanticLabel,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (!context.mounted) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasAction = actionLabel != null && onAction != null;

    final Color backgroundColor;
    final Color borderColor;
    final Color textColor;
    final Color markColor;
    final Color markIconColor;
    final IconData markIcon;

    switch (type) {
      case ToastType.success:
        backgroundColor = colorScheme.raisedSurface;
        borderColor = colorScheme.outlineVariant;
        textColor = colorScheme.onSurface;
        markColor = colorScheme.primary;
        markIconColor = colorScheme.onPrimary;
        markIcon = icon ?? Icons.check_rounded;
      case ToastType.error:
        backgroundColor = colorScheme.errorContainer;
        borderColor = colorScheme.error.withValues(alpha: 0.3);
        textColor = colorScheme.onErrorContainer;
        markColor = colorScheme.error;
        markIconColor = colorScheme.onError;
        markIcon = icon ?? Icons.priority_high_rounded;
      case ToastType.info:
        backgroundColor = colorScheme.raisedSurface;
        borderColor = colorScheme.outlineVariant;
        textColor = colorScheme.onSurface;
        markColor = colorScheme.onSurface.withValues(alpha: 0.06);
        markIconColor = colorScheme.onSurface;
        markIcon = icon ?? Icons.info_outline_rounded;
    }
    final actionColor = type == ToastType.error
        ? colorScheme.onErrorContainer
        : colorScheme.primary;

    // With TalkBack on, a toast with an action stays until it's used or
    // swiped away: there's no telling how long reaching it takes.
    final Duration? stay =
        hasAction && MediaQuery.maybeAccessibleNavigationOf(context) == true
        ? null
        : duration ??
              (hasAction
                  ? actionDuration
                  : type == ToastType.error
                  ? errorDuration
                  : infoDuration);
    final provider = ToastProvider.of(context);

    final toast = Toast(
      height: 56,
      builder: (toast) => _AutoHide(
        after: stay,
        onTimeout: () => provider.hide(toast),
        child: Builder(
          builder: (toastContext) => Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: EdgeInsets.fromLTRB(12, 8, hasAction ? 8 : 18, 8),
              decoration: BoxDecoration(
                color: backgroundColor,
                // A pill, like the app's buttons and chips.
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: borderColor),
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
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: markColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(markIcon, color: markIconColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      // Read once, from the Semantics label above.
                      child: ExcludeSemantics(
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
                    ),
                    // Optional action (e.g. "Undo"): hides the toast, then runs.
                    if (hasAction)
                      TextButton(
                        onPressed: () {
                          toast.hide(toastContext);
                          onAction();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: actionColor,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          minimumSize: const Size(64, 44),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          actionLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    provider.show(toast);
  }
}

/// Hides its toast [after] a while (never when null). The timer lives with
/// the toast's widget, so it goes with it.
class _AutoHide extends StatefulWidget {
  final Duration? after;
  final VoidCallback onTimeout;
  final Widget child;

  const _AutoHide({
    required this.after,
    required this.onTimeout,
    required this.child,
  });

  @override
  State<_AutoHide> createState() => _AutoHideState();
}

class _AutoHideState extends State<_AutoHide> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final after = widget.after;
    if (after != null) _timer = Timer(after, widget.onTimeout);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
