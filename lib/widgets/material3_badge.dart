import 'package:flutter/material.dart';

/// A Material 3 badge implementation that provides notification indicators
/// with proper styling according to M3 design specifications.
class Material3Badge extends StatelessWidget {
  /// The child widget to badge
  final Widget child;
  
  /// The label to display in the badge
  final Widget? label;
  
  /// Whether the badge is a small dot (no label)
  final bool isLabelVisible;
  
  /// Background color of the badge
  final Color? backgroundColor;
  
  /// Text color of the badge
  final Color? textColor;
  
  /// Offset for the badge position
  final Offset? offset;
  
  /// Alignment of the badge relative to the child
  final AlignmentGeometry alignment;
  
  /// Shape of the badge
  final ShapeBorder? shape;
  
  /// Padding for the badge content
  final EdgeInsetsGeometry? padding;
  
  /// Whether the badge should be shown
  final bool showBadge;

  const Material3Badge({
    super.key,
    required this.child,
    this.label,
    this.isLabelVisible = true,
    this.backgroundColor,
    this.textColor,
    this.offset,
    this.alignment = AlignmentDirectional.topEnd,
    this.shape,
    this.padding,
    this.showBadge = true,
  });

  /// Creates a badge with a count
  const Material3Badge.count({
    super.key,
    required this.child,
    required int count,
    this.backgroundColor,
    this.textColor,
    this.offset,
    this.alignment = AlignmentDirectional.topEnd,
    this.shape,
    this.padding,
    this.showBadge = true,
  }) : label = null,
       isLabelVisible = count > 0;

  /// Creates a small dot badge without text
  const Material3Badge.dot({
    super.key,
    required this.child,
    this.backgroundColor,
    this.offset,
    this.alignment = AlignmentDirectional.topEnd,
    this.showBadge = true,
  }) : label = null,
       isLabelVisible = false,
       textColor = null,
       shape = null,
       padding = null;

  @override
  Widget build(BuildContext context) {
    if (!showBadge) {
      return child;
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Default Material 3 badge colors
    final defaultBackgroundColor = backgroundColor ?? colorScheme.error;
    final defaultTextColor = textColor ?? colorScheme.onError;

    return Badge(
      label: isLabelVisible ? label : null,
      backgroundColor: defaultBackgroundColor,
      textColor: defaultTextColor,
      offset: offset,
      alignment: alignment,
      textStyle: theme.textTheme.labelSmall?.copyWith(
        color: defaultTextColor,
        fontWeight: FontWeight.w500,
      ),
      padding: padding,
      child: child,
    );
  }
}

/// A specialized badge for notification counts
class Material3NotificationBadge extends StatelessWidget {
  /// The child widget to badge
  final Widget child;
  
  /// The notification count
  final int count;
  
  /// Maximum count to display before showing "99+"
  final int maxCount;
  
  /// Whether to show the badge when count is 0
  final bool showZero;
  
  /// Background color of the badge
  final Color? backgroundColor;
  
  /// Text color of the badge
  final Color? textColor;
  
  /// Offset for the badge position
  final Offset? offset;
  
  /// Alignment of the badge relative to the child
  final AlignmentGeometry alignment;

  const Material3NotificationBadge({
    super.key,
    required this.child,
    required this.count,
    this.maxCount = 99,
    this.showZero = false,
    this.backgroundColor,
    this.textColor,
    this.offset,
    this.alignment = AlignmentDirectional.topEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shouldShow = count > 0 || showZero;
    
    if (!shouldShow) {
      return child;
    }

    final displayText = count > maxCount ? '${maxCount}+' : count.toString();

    return Material3Badge(
      showBadge: shouldShow,
      backgroundColor: backgroundColor,
      textColor: textColor,
      offset: offset,
      alignment: alignment,
      label: Text(displayText),
      child: child,
    );
  }
}

/// A badge that shows status indicators
class Material3StatusBadge extends StatelessWidget {
  /// The child widget to badge
  final Widget child;
  
  /// The status to display
  final BadgeStatus status;
  
  /// Custom text for the badge
  final String? customText;
  
  /// Offset for the badge position
  final Offset? offset;
  
  /// Alignment of the badge relative to the child
  final AlignmentGeometry alignment;

  const Material3StatusBadge({
    super.key,
    required this.child,
    required this.status,
    this.customText,
    this.offset,
    this.alignment = AlignmentDirectional.topEnd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final badgeConfig = _getBadgeConfig(status, colorScheme);
    
    return Material3Badge(
      backgroundColor: badgeConfig.backgroundColor,
      textColor: badgeConfig.textColor,
      offset: offset,
      alignment: alignment,
      label: Text(customText ?? badgeConfig.text),
      child: child,
    );
  }

  _BadgeConfig _getBadgeConfig(BadgeStatus status, ColorScheme colorScheme) {
    switch (status) {
      case BadgeStatus.error:
        return _BadgeConfig(
          backgroundColor: colorScheme.error,
          textColor: colorScheme.onError,
          text: '!',
        );
      case BadgeStatus.warning:
        return _BadgeConfig(
          backgroundColor: colorScheme.tertiary,
          textColor: colorScheme.onTertiary,
          text: '!',
        );
      case BadgeStatus.success:
        return _BadgeConfig(
          backgroundColor: colorScheme.primary,
          textColor: colorScheme.onPrimary,
          text: '✓',
        );
      case BadgeStatus.info:
        return _BadgeConfig(
          backgroundColor: colorScheme.secondary,
          textColor: colorScheme.onSecondary,
          text: 'i',
        );
      case BadgeStatus.new_:
        return _BadgeConfig(
          backgroundColor: colorScheme.tertiary,
          textColor: colorScheme.onTertiary,
          text: 'NEW',
        );
    }
  }
}

/// Predefined badge statuses
enum BadgeStatus {
  error,
  warning,
  success,
  info,
  new_,
}

class _BadgeConfig {
  final Color backgroundColor;
  final Color textColor;
  final String text;

  const _BadgeConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.text,
  });
}

/// A badge that can be animated
class Material3AnimatedBadge extends StatefulWidget {
  /// The child widget to badge
  final Widget child;
  
  /// The label to display in the badge
  final Widget? label;
  
  /// Whether the badge should be shown
  final bool showBadge;
  
  /// Animation duration
  final Duration duration;
  
  /// Animation curve
  final Curve curve;
  
  /// Background color of the badge
  final Color? backgroundColor;
  
  /// Text color of the badge
  final Color? textColor;
  
  /// Offset for the badge position
  final Offset? offset;
  
  /// Alignment of the badge relative to the child
  final AlignmentGeometry alignment;

  const Material3AnimatedBadge({
    super.key,
    required this.child,
    this.label,
    required this.showBadge,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.backgroundColor,
    this.textColor,
    this.offset,
    this.alignment = AlignmentDirectional.topEnd,
  });

  @override
  State<Material3AnimatedBadge> createState() => _Material3AnimatedBadgeState();
}

class _Material3AnimatedBadgeState extends State<Material3AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.showBadge) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(Material3AnimatedBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showBadge != oldWidget.showBadge) {
      if (widget.showBadge) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Material3Badge(
          showBadge: _animation.value > 0,
          backgroundColor: widget.backgroundColor,
          textColor: widget.textColor,
          offset: widget.offset,
          alignment: widget.alignment,
          label: widget.label != null 
              ? Transform.scale(
                  scale: _animation.value,
                  child: widget.label,
                )
              : null,
          child: widget.child,
        );
      },
    );
  }
}