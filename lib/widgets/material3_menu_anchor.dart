import 'package:flutter/material.dart';

/// A Material 3 menu anchor implementation that provides contextual menus
/// with proper styling and behavior according to M3 design specifications.
class Material3MenuAnchor extends StatefulWidget {
  /// The child widget that serves as the anchor for the menu
  final Widget child;
  
  /// The menu items to display
  final List<Widget> menuItems;
  
  /// Whether the menu is initially open
  final bool initiallyOpen;
  
  /// The controller for programmatic control of the menu
  final MenuController? controller;
  
  /// Style for the menu
  final MenuStyle? style;
  
  /// Alignment of the menu relative to the anchor
  final AlignmentGeometry? alignmentOffset;
  
  /// Called when the menu is opened or closed
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  const Material3MenuAnchor({
    super.key,
    required this.child,
    required this.menuItems,
    this.initiallyOpen = false,
    this.controller,
    this.style,
    this.alignmentOffset,
    this.onOpen,
    this.onClose,
  });

  @override
  State<Material3MenuAnchor> createState() => _Material3MenuAnchorState();
}

class _Material3MenuAnchorState extends State<Material3MenuAnchor> {
  late MenuController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? MenuController();
    
    if (widget.initiallyOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.open();
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleMenuOpen() {
    widget.onOpen?.call();
  }

  void _handleMenuClose() {
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Create Material 3 compliant menu style
    final menuStyle = widget.style ?? MenuStyle(
      backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
      surfaceTintColor: WidgetStateProperty.all(colorScheme.surfaceTint),
      elevation: WidgetStateProperty.all(3),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(vertical: 8),
      ),
    );

    return MenuAnchor(
      controller: _controller,
      style: menuStyle,
      alignmentOffset: widget.alignmentOffset,
      onOpen: _handleMenuOpen,
      onClose: _handleMenuClose,
      menuChildren: widget.menuItems,
      builder: (context, controller, child) {
        return widget.child;
      },
    );
  }
}

/// Material 3 styled menu items
class Material3MenuItem extends StatelessWidget {
  /// The text to display
  final String text;
  
  /// Optional leading icon
  final IconData? leadingIcon;
  
  /// Optional trailing icon
  final IconData? trailingIcon;
  
  /// Called when the item is selected
  final VoidCallback? onPressed;
  
  /// Whether the item is enabled
  final bool enabled;
  
  /// Style for the menu item
  final ButtonStyle? style;

  const Material3MenuItem({
    super.key,
    required this.text,
    this.leadingIcon,
    this.trailingIcon,
    this.onPressed,
    this.enabled = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final menuItemStyle = style ?? MenuItemButton.styleFrom(
      foregroundColor: enabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      minimumSize: const Size(112, 48),
      textStyle: theme.textTheme.bodyLarge,
    );

    return MenuItemButton(
      style: menuItemStyle,
      onPressed: enabled ? onPressed : null,
      leadingIcon: leadingIcon != null ? Icon(leadingIcon) : null,
      trailingIcon: trailingIcon != null ? Icon(trailingIcon) : null,
      child: Text(text),
    );
  }
}

/// Material 3 styled submenu
class Material3SubmenuButton extends StatelessWidget {
  /// The text to display
  final String text;
  
  /// Optional leading icon
  final IconData? leadingIcon;
  
  /// The submenu items
  final List<Widget> menuItems;
  
  /// Whether the submenu is enabled
  final bool enabled;
  
  /// Style for the submenu button
  final ButtonStyle? style;

  const Material3SubmenuButton({
    super.key,
    required this.text,
    required this.menuItems,
    this.leadingIcon,
    this.enabled = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final submenuStyle = style ?? SubmenuButton.styleFrom(
      foregroundColor: enabled ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.38),
      backgroundColor: Colors.transparent,
      disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      minimumSize: const Size(112, 48),
      textStyle: theme.textTheme.bodyLarge,
    );

    return SubmenuButton(
      style: submenuStyle,
      leadingIcon: leadingIcon != null ? Icon(leadingIcon) : null,
      menuChildren: menuItems,
      child: Text(text),
    );
  }
}

/// A divider for menu items
class Material3MenuDivider extends StatelessWidget {
  const Material3MenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outlineVariant,
      ),
    );
  }
}