import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';
import 'app_toast.dart';
import 'inline_entry_field.dart';
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
/// full list. If [selected] is hidden behind that overflow, it shows as an
/// extra selected pill before "...", so the current selection always stays
/// visible and the list stays reachable.
/// An optional trailing "+" pill opens the same sheet in inline-add mode
/// when [onAddItemInline] is provided. [itemLeading] puts a widget (e.g.
/// an avatar) before each label.
///
/// With [singleLine] (the quick-add sheet) it shows the items that fit on
/// one line and, at its end, a "+N" pill; the selection always stays
/// visible. The "+N" pill (and the dashed add pill) expand the row IN PLACE
/// instead of opening [showSelectionBottomSheet]: every item wraps (the
/// area scrolls past [expandedMaxHeight]), followed by a dashed add pill
/// that turns into an [InlineEntryField]. Nothing here unfocuses or
/// refocuses the form's fields, so an open keyboard stays open (a second
/// sheet closed and reopened it). Picking an item or adding one collapses
/// the row again.
class ChipSelectorRow<T> extends StatefulWidget {
  static const int maxVisibleItems = 4;
  static const String _moreLabel = '...';

  /// Tallest the expanded [singleLine] list grows before it scrolls.
  static const double expandedMaxHeight = FormPill.touchTarget * 4;

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

  /// See [showSelectionBottomSheet]'s `addErrorMessage`.
  final String? addErrorMessage;

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
    this.addErrorMessage,
    this.singleLine = false,
  });

  @override
  State<ChipSelectorRow<T>> createState() => _ChipSelectorRowState<T>();
}

class _ChipSelectorRowState<T> extends State<ChipSelectorRow<T>> {
  final _inlineController = TextEditingController();
  final _inlineFocus = FocusNode();
  bool _expanded = false;
  bool _adding = false;

  /// The field that had focus before the name field took it (the amount or
  /// description), to give it back so the keyboard never closes.
  FocusNode? _returnFocus;

  List<T> get items => widget.items;
  T? get selected => widget.selected;
  bool get singleLine => widget.singleLine;
  bool get enabled => widget.enabled;
  String Function(T) get itemLabel => widget.itemLabel;
  Widget Function(T)? get itemLeading => widget.itemLeading;
  Future<void> Function(String)? get onAddItemInline => widget.onAddItemInline;

  bool get _hasOverflow => items.length > ChipSelectorRow.maxVisibleItems + 1;

  @override
  void dispose() {
    _inlineController.dispose();
    _inlineFocus.dispose();
    super.dispose();
  }

  void _expand() => setState(() => _expanded = true);

  /// Shows the name field and moves focus to it: [InlineEntryField]'s
  /// autofocus does nothing while another field (the amount) has focus.
  void _startAdd() {
    final current = FocusManager.instance.primaryFocus;
    if (current != _inlineFocus) _returnFocus = current;
    setState(() {
      _expanded = true;
      _adding = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inlineFocus.requestFocus();
    });
  }

  void _collapse() {
    _inlineController.clear();
    _restoreFocus();
    setState(() {
      _expanded = false;
      _adding = false;
    });
  }

  /// Gives focus back to the field the name field took it from.
  void _restoreFocus() {
    final target = _returnFocus;
    _returnFocus = null;
    if (target == null) return;
    // Submitting with the keyboard's "done" already dropped the name
    // field's focus (to the scope); don't steal it from another field.
    final current = FocusManager.instance.primaryFocus;
    if (current == null ||
        current == _inlineFocus ||
        current is FocusScopeNode) {
      target.requestFocus();
    }
  }

  /// Back from the field to the open list.
  void _cancelAdd() {
    _inlineController.clear();
    _restoreFocus();
    setState(() => _adding = false);
  }

  void _pick(T item) {
    widget.onSelected(item);
    if (_expanded) _collapse();
  }

  String? _duplicate(String val) {
    final lower = val.toLowerCase();
    if (!items.any((i) => itemLabel(i).toLowerCase() == lower)) return null;
    // Without a message, still refused: red border only.
    return widget.alreadyExistsMessage ?? '';
  }

  /// The caller's callback adds (and selects) the item; the row collapses.
  Future<bool> _commitInlineAdd(String val) async {
    try {
      await onAddItemInline!(val);
    } catch (e) {
      LoggerService.warning('Adding "$val" failed: $e', name: 'ui.sheet');
      if (mounted && widget.addErrorMessage != null) {
        AppToast.show(context, widget.addErrorMessage!, type: ToastType.error);
      }
      return false;
    }
    if (mounted) _collapse();
    return true;
  }

  Widget _expandedList(BuildContext context) {
    final addLabel = widget.addCategoryLabel ?? widget.addLabel ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: ChipSelectorRow.expandedMaxHeight,
          ),
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: AppSpacing.xs,
                // FormPill's own touch margin already spaces the rows.
                runSpacing: 0,
                children: [
                  for (final item in items)
                    FormPill(
                      label: itemLabel(item),
                      leading: itemLeading?.call(item),
                      style: selected == item
                          ? FormPillStyle.selected
                          : FormPillStyle.normal,
                      onTap: enabled ? () => _pick(item) : null,
                    ),
                  if (onAddItemInline != null && !_adding)
                    FormPill(
                      label: addLabel,
                      icon: Icons.add_rounded,
                      style: FormPillStyle.add,
                      onTap: enabled ? () => _startAdd() : null,
                    ),
                ],
              ),
            ),
          ),
        ),
        if (onAddItemInline != null && _adding)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: InlineEntryField(
              controller: _inlineController,
              focusNode: _inlineFocus,
              // "done" must not drop focus (and the keyboard) before the
              // row collapses and hands focus back.
              keepOpen: true,
              hintText: widget.addItemHint ?? '',
              commitTooltip: widget.addLabel ?? '',
              cancelTooltip:
                  widget.cancelLabel ??
                  MaterialLocalizations.of(context).cancelButtonLabel,
              validator: _duplicate,
              onCommit: _commitInlineAdd,
              onCancel: _cancelAdd,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const maxVisibleItems = ChipSelectorRow.maxVisibleItems;
    const moreLabel = ChipSelectorRow._moreLabel;
    final sheetTitle = widget.sheetTitle;
    final addCategoryLabel = widget.addCategoryLabel;
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
        addItemHint: widget.addItemHint,
        addLabel: widget.addLabel,
        cancelLabel: widget.cancelLabel,
        addCategoryLabel: addCategoryLabel,
        alreadyExistsMessage: widget.alreadyExistsMessage,
        addErrorMessage: widget.addErrorMessage,
        autoStartAdd: autoStartAdd,
      );
      if (picked != null) widget.onSelected(picked);
    }

    if (singleLine) {
      if (_expanded) return _expandedList(context);
      return LayoutBuilder(
        builder: (context, constraints) =>
            _singleLine(context, constraints.maxWidth),
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
          onTap: enabled ? () => _pick(item) : null,
        ),
      // A choice from the full list shows as its own pill, and "..." stays
      // after it: it used to take the choice's label, so the way back to
      // the list disappeared.
      if (selectedIsHidden)
        FormPill(
          label: itemLabel(selected as T),
          leading: itemLeading?.call(selected as T),
          style: FormPillStyle.selected,
          onTap: enabled ? () => _pick(selected as T) : null,
        ),
      if (_hasOverflow)
        FormPill(
          label: moreLabel,
          semanticsLabel: sheetTitle,
          tooltip: sheetTitle,
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

extension<T> on _ChipSelectorRowState<T> {
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

  Widget _singleLine(BuildContext context, double maxWidth) {
    const gap = AppSpacing.xs;
    final widths = [
      for (final item in items)
        _pillWidth(context, itemLabel(item), itemLeading != null),
    ];
    final addWidth = onAddItemInline != null
        ? FormPill.height + 2 * FormPill.touchMargin + gap
        : 0.0;
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
              onTap: enabled ? () => _pick(item) : null,
            ),
          ),
        ],
        if (hidden > 0) ...[
          if (visible.isNotEmpty) const SizedBox(width: gap),
          FormPill(
            label: '+$hidden',
            style: FormPillStyle.add,
            semanticsLabel: widget.sheetTitle,
            tooltip: widget.sheetTitle,
            onTap: enabled ? _expand : null,
          ),
        ] else if (onAddItemInline != null) ...[
          const SizedBox(width: gap),
          _AddPill(
            tooltip: widget.addCategoryLabel,
            onTap: enabled ? () => _startAdd() : null,
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
      // The 40 dp circle with a touch margin all round: a 48 x 48 target.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(FormPill.touchMargin),
          child: SizedBox.square(
            dimension: FormPill.height,
            child: Material(
              color: s.raisedSurface,
              shape: CircleBorder(
                side: BorderSide(
                  color: s.outlineVariant.withValues(alpha: 0.6),
                ),
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
      ),
    );
    if (tooltip != null) pill = Tooltip(message: tooltip!, child: pill);
    return pill;
  }
}
