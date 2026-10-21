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
///
/// With [singleLine] (the quick-add sheet) it never wraps: it shows the
/// items that fit on one line and, at its end on the same line, a "+N" pill
/// opening the full list (with add); the selection always stays visible.
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

  /// One line only, the rest behind a trailing "+N" pill.
  final bool singleLine;

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
    this.singleLine = false,
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
        itemLeading: itemLeading,
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

    if (singleLine) {
      return LayoutBuilder(
        builder: (context, constraints) =>
            _singleLine(context, constraints.maxWidth, openPicker),
      );
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

extension<T> on ChipSelectorRow<T> {
  /// Width of a pill with [label] (and a leading widget or not).
  double _pillWidth(BuildContext context, String label, bool hasLeading) {
    final theme = Theme.of(context);
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    // Padding, leading slot, borders: see FormPill.
    return painter.width + (hasLeading ? 6 + 28 + 6 : 14) + 14 + 2;
  }

  Widget _singleLine(
    BuildContext context,
    double maxWidth,
    Future<void> Function({bool autoStartAdd}) openPicker,
  ) {
    const gap = AppSpacing.xs;
    final widths = [
      for (final item in items)
        _pillWidth(context, itemLabel(item), itemLeading != null),
    ];
    final addWidth = onAddItemInline != null ? FormPill.height + gap : 0.0;
    final allWidth =
        widths.fold<double>(0, (a, w) => a + w) +
        gap * (items.length - 1).clamp(0, items.length) +
        addWidth;

    var visible = List<T>.of(items);
    var hidden = 0;
    if (allWidth > maxWidth) {
      // Room for the "+N" pill at the end.
      final moreWidth = _pillWidth(context, '+${items.length}', false);
      var used = moreWidth;
      var count = 0;
      for (final w in widths) {
        if (used + w + gap > maxWidth) break;
        used += w + gap;
        count++;
      }
      visible = items.take(count).toList();
      hidden = items.length - count;
      // The current choice always shows (in place of the last one).
      if (selected != null &&
          !visible.contains(selected) &&
          visible.isNotEmpty) {
        visible[visible.length - 1] = selected as T;
      }
    }

    return Row(
      children: [
        for (final (i, item) in visible.indexed) ...[
          if (i > 0) const SizedBox(width: gap),
          Flexible(
            child: FormPill(
              label: itemLabel(item),
              leading: itemLeading?.call(item),
              style: selected == item
                  ? FormPillStyle.selected
                  : FormPillStyle.normal,
              onTap: enabled ? () => onSelected(item) : null,
            ),
          ),
        ],
        if (hidden > 0) ...[
          if (visible.isNotEmpty) const SizedBox(width: gap),
          FormPill(
            label: '+$hidden',
            style: FormPillStyle.add,
            semanticsLabel: sheetTitle,
            tooltip: sheetTitle,
            onTap: enabled ? openPicker : null,
          ),
        ] else if (onAddItemInline != null) ...[
          const SizedBox(width: gap),
          _AddPill(
            tooltip: addCategoryLabel,
            onTap: enabled ? () => openPicker(autoStartAdd: true) : null,
          ),
        ],
      ],
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
