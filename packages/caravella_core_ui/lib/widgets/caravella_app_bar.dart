import 'package:flutter/material.dart';

class CaravellaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final String? headerSemanticLabel;
  final String? backButtonSemanticLabel;

  const CaravellaAppBar({
    super.key,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.headerSemanticLabel,
    this.backButtonSemanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: headerSemanticLabel,
      child: AppBar(
        backgroundColor:
            backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: elevation,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: centerTitle,
        title: null,
        leading: leading != null
            ? Semantics(
                button: true,
                label: backButtonSemanticLabel,
                child: leading,
              )
            : null,
        actions: actions
            ?.map((action) => Semantics(button: true, child: action))
            .toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
