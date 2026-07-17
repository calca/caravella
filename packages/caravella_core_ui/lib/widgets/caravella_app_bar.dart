import 'package:flutter/material.dart';

/// Flat, borderless app bar with no title slot — for pages whose heading
/// lives in the body below (home-like screens, settings pages) rather than
/// in the app bar itself. `title` is intentionally not a parameter here.
///
/// If the page needs a visible title, use a plain `AppBar(title: ...)`
/// instead. For an inline search field, use [SearchAppBar].
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
