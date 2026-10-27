import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'app_toast.dart';
import '../themes/form_theme.dart';
import '../themes/caravella_themes.dart';
import 'card_outline.dart';
import 'form_pill.dart';

/// Generic modal bottom sheet for selecting an item from a list.
/// Supports inline add-item action shown within the sheet.
Future<T?> showSelectionBottomSheet<T>({
  required BuildContext context,
  required List<T> items,
  required T? selected,
  required String Function(T) itemLabel,
  Widget Function(T)? itemLeading,
  Future<void> Function(String)? onAddItemInline,
  String? addItemHint,
  String? sheetTitle,
  String? addLabel,
  String? cancelLabel,
  String? addCategoryLabel,
  String? alreadyExistsMessage,
  bool autoStartAdd = false,
}) async {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => _SelectionSheet<T>(
      items: items,
      selected: selected,
      itemLabel: itemLabel,
      itemLeading: itemLeading,
      onAddItemInline: onAddItemInline,
      addItemHint: addItemHint,
      sheetTitle: sheetTitle,
      addLabel: addLabel,
      cancelLabel: cancelLabel,
      addCategoryLabel: addCategoryLabel,
      alreadyExistsMessage: alreadyExistsMessage,
      autoStartAdd: autoStartAdd,
    ),
  );
}

class _SelectionSheet<T> extends StatefulWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) itemLabel;
  final Widget Function(T)? itemLeading;
  final Future<void> Function(String)? onAddItemInline;
  final String? addItemHint;
  final String? sheetTitle;
  final String? addLabel;
  final String? cancelLabel;
  final String? addCategoryLabel;
  final String? alreadyExistsMessage;
  final bool autoStartAdd;
  const _SelectionSheet({
    required this.items,
    required this.selected,
    required this.itemLabel,
    this.itemLeading,
    this.onAddItemInline,
    this.addItemHint,
    this.sheetTitle,
    this.addLabel,
    this.cancelLabel,
    this.addCategoryLabel,
    this.alreadyExistsMessage,
    this.autoStartAdd = false,
  });

  @override
  State<_SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<_SelectionSheet<T>> {
  bool _inlineAdding = false;
  final TextEditingController _inlineController = TextEditingController();
  final FocusNode _inlineFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  late List<T> _currentItems;
  String _query = '';
  Timer? _focusDelayedScrollTimer;
  Timer? _inputFieldScrollTimer;

  @override
  void didUpdateWidget(covariant _SelectionSheet<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync local items with updated widget items if they've changed
    if (widget.items != oldWidget.items) {
      _currentItems = List<T>.from(widget.items);
    }
  }

  @override
  void dispose() {
    _focusDelayedScrollTimer?.cancel();
    _inputFieldScrollTimer?.cancel();
    _inlineController.dispose();
    _inlineFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize local items list
    _currentItems = List<T>.from(widget.items);
    if (widget.autoStartAdd && widget.onAddItemInline != null) {
      _inlineAdding = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _inlineFocus.requestFocus();
      });
    }
    // Add focus listener to handle keyboard appearance and auto-scroll
    _inlineFocus.addListener(() {
      if (_inlineFocus.hasFocus) {
        // Immediate scroll attempt
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToInputField();
        });
        // Delayed scroll to account for keyboard animation
        _focusDelayedScrollTimer?.cancel();
        _focusDelayedScrollTimer = Timer(const Duration(milliseconds: 300), () {
          _scrollToInputField();
        });
      }
    });

    // Auto-scroll to selected item when modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedItem();
    });
  }

  /// Scrolls to the selected item when modal opens
  void _scrollToSelectedItem() {
    if (!_scrollController.hasClients || !mounted || widget.selected == null) {
      return;
    }

    try {
      final selectedIndex = _currentItems.indexOf(widget.selected as T);
      if (selectedIndex != -1) {
        // Calculate the offset to center the selected item
        final itemHeight = 50.0; // Approximate height of each list item
        final targetOffset =
            (selectedIndex * itemHeight) -
            (MediaQuery.of(context).size.height * 0.4 * 0.5);
        final clampedOffset = targetOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        );

        _scrollController.animateTo(
          clampedOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      // Gracefully handle any scrolling errors
      LoggerService.debug(
        'Error during initial scroll-to-selected',
        name: 'ui.sheet',
      );
    }
  }

  /// Scrolls to make the input field visible when keyboard opens
  void _scrollToInputField() {
    if (!_scrollController.hasClients || !mounted) return;

    try {
      // Wait for layout to settle after keyboard animation
      _inputFieldScrollTimer?.cancel();
      _inputFieldScrollTimer = Timer(const Duration(milliseconds: 150), () {
        if (!_scrollController.hasClients || !mounted) return;

        // Scroll to bottom to ensure input field is visible above keyboard
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        if (maxScrollExtent > 0) {
          _scrollController.animateTo(
            maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    } catch (e) {
      // Gracefully handle any scrolling errors
      LoggerService.warning('Error during scroll-to-input', name: 'ui.sheet');
    }
  }

  void _startInlineAdd() {
    setState(() {
      _inlineAdding = true;
      _inlineController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inlineFocus.requestFocus();
    });
  }

  void _cancelInlineAdd() {
    setState(() {
      _inlineAdding = false;
      _inlineController.clear();
    });
  }

  Future<void> _commitInlineAdd() async {
    final val = _inlineController.text.trim();
    if (val.isEmpty || widget.onAddItemInline == null) return;

    // Check for duplicates (case-insensitive)
    final lower = val.toLowerCase();
    final isDuplicate = _currentItems.any(
      (item) => widget.itemLabel(item).toLowerCase() == lower,
    );

    if (isDuplicate) {
      if (widget.alreadyExistsMessage != null) {
        AppToast.show(
          context,
          widget.alreadyExistsMessage!,
          type: ToastType.info,
        );
      }
      return;
    }

    try {
      await widget.onAddItemInline!(val);

      // Add the new item to local list for immediate UI update
      // For String items (participants), cast the value directly
      if (T == String) {
        setState(() {
          _currentItems.add(val as T);
          _inlineAdding = false;
          _inlineController.clear();
        });

        // Auto-select the newly added participant and close modal
        // This provides immediate feedback and allows the user to see their selection
        await _closeSheetSafely(result: val as T);
      } else {
        // For non-String items (e.g., ExpenseCategory), close the sheet after adding.
        // Selection is handled by the onAddItemInline callback chain.
        await _closeSheetSafely();
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Error adding item: $e', type: ToastType.error);
      }
    }
  }

  /// Waits briefly for UI updates to settle, then closes the sheet.
  /// Passes [result] to Navigator.pop when provided (e.g. for auto-selection).
  Future<void> _closeSheetSafely({T? result}) async {
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      Navigator.of(context).pop(result);
    }
  }

  /// From this many items a search field shows above the list.
  static const int searchFrom = 9;

  Widget _buildInlineAddRow() {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    // Same field as the expense description: a raised rounded field with a
    // hairline that turns into the primary color while typing.
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: _inlineController,
        focusNode: _inlineFocus,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        style: FormTheme.getFieldTextStyle(context),
        decoration:
            FormTheme.getCardDecoration(
              fillColor: s.raisedSurface,
              borderColor: CardOutline.colorFor(theme.brightness),
              focusColor: s.primary,
              errorColor: s.error,
              hintText: widget.addItemHint,
            ).copyWith(
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: widget.cancelLabel,
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _cancelInlineAdd,
                    ),
                    IconButton.filled(
                      tooltip: widget.addLabel,
                      style: IconButton.styleFrom(
                        backgroundColor: s.primary,
                        foregroundColor: s.onPrimary,
                      ),
                      icon: const Icon(Icons.check_rounded),
                      onPressed: _commitInlineAdd,
                    ),
                  ],
                ),
              ),
            ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _commitInlineAdd(),
      ),
    );
  }

  Widget _buildInlineAddButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FormPill(
          icon: Icons.add_rounded,
          label: widget.addCategoryLabel ?? widget.addLabel ?? '',
          style: FormPillStyle.add,
          onTap: _startInlineAdd,
        ),
      ),
    );
  }

  Widget _buildSearch() {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
        textInputAction: TextInputAction.search,
        // The same search pill as the currency list.
        decoration: FormTheme.getSearchPillDecoration(
          backgroundColor: s.raisedSurface,
          hintText: MaterialLocalizations.of(context).searchFieldLabel,
          prefixIcon: const Icon(Icons.search_rounded),
        ),
      ),
    );
  }

  Widget _buildRow(T item, bool first) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final isSel = widget.selected == item;
    final leading = widget.itemLeading?.call(item);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!first)
          Divider(
            height: 1,
            indent: leading != null ? 60 : 16,
            endIndent: 16,
            color: s.outlineVariant.withValues(alpha: 0.5),
          ),
        Semantics(
          selected: isSel,
          button: true,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(item),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 52),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      SizedBox.square(dimension: 32, child: leading),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        widget.itemLabel(item),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSel)
                      Icon(Icons.check_rounded, color: s.primary, size: 22),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Room under the last row (the "Add …" pill in long lists): above the
    // keyboard when it's open, otherwise above the system navigation bar —
    // the sheet is edge to edge, and the pill used to end under the bar.
    final bottomInset = math.max(
      keyboardHeight,
      MediaQuery.viewPaddingOf(context).bottom,
    );
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final showSearch = _currentItems.length >= searchFrom;
    final itemsToShow = _query.isEmpty
        ? _currentItems
        : _currentItems
              .where((i) => widget.itemLabel(i).toLowerCase().contains(_query))
              .toList();
    final radius = BorderRadius.circular(20);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: keyboardHeight > 0 || showSearch ? 0.9 : 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 14),
                decoration: BoxDecoration(
                  color: s.outlineVariant.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (widget.sheetTitle != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Semantics(
                  header: true,
                  child: Text(
                    widget.sheetTitle!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(16, 0, 16, 24 + bottomInset),
                children: [
                  if (showSearch) _buildSearch(),
                  if (itemsToShow.isNotEmpty)
                    CardOutline(
                      borderRadius: radius,
                      child: Material(
                        color: s.raisedSurface,
                        borderRadius: radius,
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            for (final (i, item) in itemsToShow.indexed)
                              _buildRow(item, i == 0),
                          ],
                        ),
                      ),
                    ),
                  if (widget.onAddItemInline != null)
                    _inlineAdding
                        ? _buildInlineAddRow()
                        : _buildInlineAddButton(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
