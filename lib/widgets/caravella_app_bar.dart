import 'package:flutter/material.dart';

class CaravellaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;

  const CaravellaAppBar({
    super.key,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: elevation,
      iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      centerTitle: centerTitle,
      title: null,
      leading: leading,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
