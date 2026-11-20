import 'package:material_ui/material_ui.dart';

import 'side_panel.dart';

/// The layout of every bottom sheet, in the app's style: a handle, a large
/// [title] with an optional [subtitle] line of context, then the content —
/// usually [SettingsGroup] cards of actions or a [showSelectionBottomSheet]
/// list — on the theme's sheet grey (`bottomSheetTheme`).
class CaravellaBottomSheetScaffold extends StatelessWidget {
  final String? title;

  /// A line of context under the title (e.g. a group's dates and people).
  final String? subtitle;
  final Widget child;
  final EdgeInsets padding;
  final double spacing;
  final bool scrollable;
  final bool showHandle;
  final ScrollController? scrollController;
  const CaravellaBottomSheetScaffold({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 24),
    this.spacing = 12,
    this.scrollable = false,
    this.showHandle = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // In a side panel (wide windows) it is a close button, always.
        if (showHandle || SidePanelScope.isIn(context))
          const SheetHandle(margin: EdgeInsets.only(bottom: 14)),
        // The grid of the pages: title at 20 (4 in), cards at 16.
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: spacing + 4),
        ],
        child,
      ],
    );
    final padded = Padding(padding: padding, child: content);
    return SafeArea(
      top: false,
      child: scrollable
          ? SingleChildScrollView(controller: scrollController, child: padded)
          : padded,
    );
  }
}
