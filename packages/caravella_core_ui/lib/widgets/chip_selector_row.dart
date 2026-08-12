import 'package:flutter/material.dart';
import 'selection_bottom_sheet.dart';
import '../themes/app_spacing.dart';

/// Horizontally scrolling row of selectable chips for compact single-value
/// pickers (e.g. "paid by", "category").
///
/// Shows up to [maxVisibleItems] items in the order given by [items] (the
/// caller decides the order, e.g. last-used-first). When there are more
/// than [maxVisibleItems] + 1 items, the row collapses the remainder behind
/// a trailing "..." chip that opens [showSelectionBottomSheet] to browse the
/// full list. If [selected] is hidden behind that overflow, the "..." chip
/// shows its label instead, so the current selection always stays visible.
/// An optional trailing "add" chip opens the same sheet in inline-add mode
/// when [onAddItemInline] is provided.
class ChipSelectorRow<T> extends StatelessWidget {
  static const int maxVisibleItems = 4;
  static const double _chipRowHeight = 38;
  static const String _moreLabel = '...';

  final List<T> items;
  final T? selected;
  final String Function(T) itemLabel;
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

    final chips = <Widget>[
      for (final item in visible)
        _SelectorChip(
          label: itemLabel(item),
          selected: selected == item,
          enabled: enabled,
          onTap: () => onSelected(item),
        ),
      if (_hasOverflow)
        _SelectorChip(
          label: selectedIsHidden ? itemLabel(selected as T) : _moreLabel,
          selected: selectedIsHidden,
          enabled: enabled,
          onTap: openPicker,
        ),
      if (onAddItemInline != null)
        _AddChip(
          enabled: enabled,
          tooltip: addCategoryLabel,
          onTap: () => openPicker(autoStartAdd: true),
        ),
    ];

    if (chips.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: _chipRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) => chips[index],
      ),
    );
  }
}

class _SelectorChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _SelectorChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Selected: an outline-led tint (colored border + colored label, faint
    // fill) rather than a solid container swatch. Idle: a lighter neutral
    // fill with a softer hairline border than the app's default outline.
    final foreground = selected ? scheme.primary : scheme.onSurfaceVariant;
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: scheme.onSurface.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
      ),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: enabled ? (_) => onTap() : null,
        showCheckmark: false,
        side: BorderSide(
          color: selected
              ? scheme.primary.withValues(alpha: 0.55)
              : scheme.outlineVariant.withValues(alpha: 0.3),
        ),
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primary.withValues(alpha: 0.1),
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: foreground,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  final bool enabled;
  final String? tooltip;
  final VoidCallback onTap;

  const _AddChip({required this.enabled, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chip = InkWell(
      customBorder: const CircleBorder(),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: scheme.surfaceContainerLow,
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Icon(
          Icons.add,
          size: 18,
          color: enabled
              ? scheme.onSurfaceVariant
              : scheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: chip) : chip;
  }
}
