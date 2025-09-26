import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CaravellaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;

  const CaravellaAppBar({
    super.key,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Semantics(
      header: true,
      label: localizations.accessibility_navigation_bar,
      child: AppBar(
        backgroundColor:
            backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
        elevation: elevation,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: centerTitle,
        title: null,
        leading: leading != null 
            ? Semantics(
                button: true,
                label: localizations.accessibility_back_button,
                child: leading,
              )
            : null,
        actions: actions?.map((action) => Semantics(
          button: true,
          child: action,
        )).toList(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
