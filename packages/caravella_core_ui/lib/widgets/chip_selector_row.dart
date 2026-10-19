import 'package:material_ui/material_ui.dart';
import 'selection_bottom_sheet.dart';
import '../themes/app_spacing.dart';
import '../themes/caravella_themes.dart';
import 'form_pill.dart';

/// Pills for compact single-value pickers (e.g. "paid by", "category"),
/// wrapping onto more lines instead of scrolling off screen.
///
/// Shows up to [maxVisibleItems] items in the order given by [items] (the
/// caller decides the order, e.g. last-used-first). When there are more
/// than [maxVisibleItems] + 1 items, the remainder is collapsed behind a
/// trailing "..." pill that opens [showSelectionBottomSheet] to browse the
/// full list. If [selected] is hidden behind that overflow, the "..." pill
/// shows its label instead, so the current selection always stays visible.
/// An optional trailing "+" pill opens the same sheet in inline-add mode
/// when [onAddItemInline] is provided. [itemLeading] puts a widget (e.g.
/// an avatar) before each label.
class ChipSelectorRow<T> extends StatelessWidget {
  static const int maxVisibleItems = 4;
  static const String _moreLabel = '...';

  final List<T> items;
  final T? selected;
  final String Function(T) itemLabel;
  final Widget Function(T)? itemLeading;
  final ValueChanged<T> onSelected;
  final bool enabled;

  final Future<void> Function(String)? onAddItemInline;
  final String? addItemHint;
  final String? sheetTitle;
  final String? addLabel;
  final String? cancelLabel;
  final String? addCategoryLabel;
  final String? alreadyExistsMessage;

  const ChipSelectorRow({
    super.key,
    required this.items,
    required this.selected,
    required this.itemLabel,
    required this.onSelected,
    this.itemLeading,
    this.enabled = true,
    this.onAddItemInline,
    this.addItemHint,
    this.sheetTitle,
    this.addLabel,
    this.cancelLabel,
    this.addCategoryLabel,
    this.alreadyExistsMessage,
  });

  bool get _hasOverflow => items.length > maxVisibleItems + 1;

  @override
  Widget build(BuildContext context) {
    final visible = _hasOverflow ? items.take(maxVisibleItems).toList() : items;
    final selectedIsHidden =
        _hasOverflow && selected != null && !visible.contains(selected);

    Future<void> openPicker({bool autoStartAdd = false}) async {
      final picked = await showSelectionBottomSheet<T>(
        context: context,
        items: items,
        selected: selected,
        sheetTitle: sheetTitle,
        itemLabel: itemLabel,
        onAddItemInline: onAddItemInline,
        addItemHint: addItemHint,
        addLabel: addLabel,
        cancelLabel: cancelLabel,
        addCategoryLabel: addCategoryLabel,
        alreadyExistsMessage: alreadyExistsMessage,
        autoStartAdd: autoStartAdd,
      );
      if (picked != null) onSelected(picked);
    }

    final pills = <Widget>[
      for (final item in visible)
        FormPill(
          label: itemLabel(item),
          leading: itemLeading?.call(item),
          style: selected == item
              ? FormPillStyle.selected
              : FormPillStyle.normal,
          onTap: enabled ? () => onSelected(item) : null,
        ),
      if (_hasOverflow)
        FormPill(
          label: selectedIsHidden ? itemLabel(selected as T) : _moreLabel,
          leading: selectedIsHidden ? itemLeading?.call(selected as T) : null,
          style: selectedIsHidden
              ? FormPillStyle.selected
              : FormPillStyle.normal,
          semanticsLabel: selectedIsHidden ? null : sheetTitle,
          onTap: enabled ? openPicker : null,
        ),
      if (onAddItemInline != null)
        _AddPill(
          tooltip: addCategoryLabel,
          onTap: enabled ? () => openPicker(autoStartAdd: true) : null,
        ),
    ];

    if (pills.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.xs,
      // FormPill's own touch margin already spaces the rows.
      runSpacing: 0,
      children: pills,
    );
  }
}

/// Round dashed "+" pill.
class _AddPill extends StatelessWidget {
  final String? tooltip;
  final VoidCallback? onTap;

  const _AddPill({required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    Widget pill = Semantics(
      button: true,
      enabled: onTap != null,
      label: tooltip,
      excludeSemantics: true,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FormPill.touchMargin),
        child: SizedBox.square(
          dimension: FormPill.height,
          child: Material(
            color: s.raisedSurface,
            shape: CircleBorder(
              side: BorderSide(color: s.outlineVariant.withValues(alpha: 0.6)),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Icon(
                Icons.add_rounded,
                size: 20,
                color: onTap != null
                    ? s.onSurfaceVariant
                    : s.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
        ),
      ),
    );
    if (tooltip != null) pill = Tooltip(message: tooltip!, child: pill);
    return pill;
  }
}
