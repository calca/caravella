import 'package:flutter/material.dart';

/// A Material 3 search bar implementation that provides enhanced search
/// functionality with proper styling according to M3 design specifications.
class Material3SearchBar extends StatefulWidget {
  /// The controller for the search field
  final TextEditingController? controller;
  
  /// Hint text to display when the search is empty
  final String? hintText;
  
  /// Leading widget (typically an icon)
  final Widget? leading;
  
  /// Trailing widgets (typically action buttons)
  final List<Widget>? trailing;
  
  /// Called when the search text changes
  final ValueChanged<String>? onChanged;
  
  /// Called when the search is submitted
  final ValueChanged<String>? onSubmitted;
  
  /// Whether the search bar should automatically focus
  final bool autoFocus;
  
  /// The text input action for the keyboard
  final TextInputAction textInputAction;
  
  /// Constraints for the search bar
  final BoxConstraints? constraints;
  
  /// Elevation of the search bar
  final double? elevation;
  
  /// Background color of the search bar
  final Color? backgroundColor;
  
  /// Border radius of the search bar
  final BorderRadius? borderRadius;
  
  /// Padding for the search bar content
  final EdgeInsetsGeometry? padding;
  
  /// Text style for the search input
  final TextStyle? textStyle;
  
  /// Text style for the hint text
  final TextStyle? hintStyle;

  const Material3SearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.leading,
    this.trailing,
    this.onChanged,
    this.onSubmitted,
    this.autoFocus = false,
    this.textInputAction = TextInputAction.search,
    this.constraints,
    this.elevation,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.hintStyle,
  });

  @override
  State<Material3SearchBar> createState() => _Material3SearchBarState();
}

class _Material3SearchBarState extends State<Material3SearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Default Material 3 search bar styling
    final defaultBackgroundColor = widget.backgroundColor ?? colorScheme.surfaceContainerHigh;
    final defaultElevation = widget.elevation ?? 6.0;
    final defaultBorderRadius = widget.borderRadius ?? BorderRadius.circular(28);
    final defaultPadding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 16);
    
    final defaultConstraints = widget.constraints ?? const BoxConstraints(
      minHeight: 56,
      maxHeight: 56,
    );

    final defaultTextStyle = widget.textStyle ?? theme.textTheme.bodyLarge?.copyWith(
      color: colorScheme.onSurface,
    );

    final defaultHintStyle = widget.hintStyle ?? theme.textTheme.bodyLarge?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );

    return Material(
      elevation: defaultElevation,
      color: defaultBackgroundColor,
      borderRadius: defaultBorderRadius,
      child: Container(
        constraints: defaultConstraints,
        padding: defaultPadding,
        child: Row(
          children: [
            // Leading widget
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 8),
            ],
            
            // Search text field
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                textInputAction: widget.textInputAction,
                style: defaultTextStyle,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: defaultHintStyle,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            
            // Trailing widgets
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              ...widget.trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A search bar that can expand and collapse
class Material3ExpandableSearchBar extends StatefulWidget {
  /// The controller for the search field
  final TextEditingController? controller;
  
  /// Hint text to display when the search is empty
  final String? hintText;
  
  /// Whether the search bar is expanded
  final bool isExpanded;
  
  /// Called when the expand/collapse state should change
  final VoidCallback? onToggle;
  
  /// Called when the search text changes
  final ValueChanged<String>? onChanged;
  
  /// Called when the search is submitted
  final ValueChanged<String>? onSubmitted;
  
  /// The collapsed width of the search bar
  final double collapsedWidth;
  
  /// The expanded width of the search bar
  final double? expandedWidth;
  
  /// Duration of the expand/collapse animation
  final Duration animationDuration;
  
  /// Animation curve for expand/collapse
  final Curve animationCurve;

  const Material3ExpandableSearchBar({
    super.key,
    this.controller,
    this.hintText,
    required this.isExpanded,
    this.onToggle,
    this.onChanged,
    this.onSubmitted,
    this.collapsedWidth = 56,
    this.expandedWidth,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  State<Material3ExpandableSearchBar> createState() => _Material3ExpandableSearchBarState();
}

class _Material3ExpandableSearchBarState extends State<Material3ExpandableSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve,
    );

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(Material3ExpandableSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = widget.expandedWidth ?? screenWidth - 32;
        final currentWidth = widget.collapsedWidth + 
            (maxWidth - widget.collapsedWidth) * _animation.value;

        return SizedBox(
          width: currentWidth,
          child: widget.isExpanded
              ? Material3SearchBar(
                  controller: widget.controller,
                  hintText: widget.hintText,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  autoFocus: true,
                  leading: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: widget.onToggle,
                  ),
                  trailing: [
                    if (widget.controller?.text.isNotEmpty == true)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.controller?.clear();
                          widget.onChanged?.call('');
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onToggle,
                    ),
                  ],
                )
              : IconButton.filledTonal(
                  onPressed: widget.onToggle,
                  icon: const Icon(Icons.search),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainerHigh,
                    foregroundColor: colorScheme.onSurface,
                    minimumSize: Size(widget.collapsedWidth, widget.collapsedWidth),
                  ),
                ),
        );
      },
    );
  }
}