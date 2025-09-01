import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'bottom_sheet_scaffold.dart';
import 'app_toast.dart';

/// Generic modal bottom sheet for selecting an item from a list.
/// Supports inline add-item action shown within the sheet.
Future<T?> showSelectionBottomSheet<T>({
  required BuildContext context,
  required List<T> items,
  required T? selected,
  required String Function(T) itemLabel,
  gen.AppLocalizations? gloc,
  Future<void> Function(String)? onAddItemInline,
  String? addItemHint,
  String? sheetTitle,
}) async {
  final resolved = gloc ?? gen.AppLocalizations.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _SelectionSheet<T>(
      items: items,
      selected: selected,
      itemLabel: itemLabel,
      onAddItemInline: onAddItemInline,
      addItemHint: addItemHint,
      gloc: resolved,
      sheetTitle: sheetTitle,
    ),
  );
}

class _SelectionSheet<T> extends StatefulWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) itemLabel;
  final Future<void> Function(String)? onAddItemInline;
  final String? addItemHint;
  final gen.AppLocalizations gloc;
  final String? sheetTitle;
  const _SelectionSheet({
    required this.items,
    required this.selected,
    required this.itemLabel,
    required this.gloc,
    this.onAddItemInline,
    this.addItemHint,
    this.sheetTitle,
  });

  @override
  State<_SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<_SelectionSheet<T>> {
  bool _inlineAdding = false;
  final TextEditingController _inlineController = TextEditingController();
  final FocusNode _inlineFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inlineController.dispose();
    _inlineFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Add focus listener to handle keyboard appearance and auto-scroll
    _inlineFocus.addListener(() {
      if (_inlineFocus.hasFocus) {
        // Delay to ensure keyboard is starting to appear
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToInputField();
        });
      }
    });
  }

  /// Scrolls to make the input field visible when keyboard opens
  void _scrollToInputField() {
    if (!_scrollController.hasClients || !mounted) return;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight == 0) return;

    try {
      // Scroll to bottom to ensure input field is visible above keyboard
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      if (maxScrollExtent > 0) {
        _scrollController.animateTo(
          maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      // Gracefully handle any scrolling errors
      debugPrint('Error during scroll-to-input: $e');
    }
  }

  void _startInlineAdd() {
    setState(() {
      _inlineAdding = true;
      _inlineController.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _inlineFocus.requestFocus(),
    );
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

    // Capture messenger before any async gaps
    final messenger = ScaffoldMessenger.of(context);

    // Check for duplicates (case-insensitive)
    final lower = val.toLowerCase();
    final isDuplicate = widget.items.any(
      (item) => widget.itemLabel(item).toLowerCase() == lower,
    );

    if (isDuplicate) {
      AppToast.showFromMessenger(
        messenger,
        '${widget.gloc.category_name} ${widget.gloc.already_exists}',
        type: ToastType.info,
      );
      return;
    }

    try {
      await widget.onAddItemInline!(val);
      // Close the modal after successfully adding the category
      // The parent will handle selecting the newly added category
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AppToast.showFromMessenger(
          messenger,
          'Error adding item: $e',
          type: ToastType.error,
        );
      }
    }
  }

  Widget _buildInlineAddRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              child: TextField(
                controller: _inlineController,
                focusNode: _inlineFocus,
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.addItemHint ?? widget.gloc.category_name,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _commitInlineAdd(),
              ),
            ),
          ),
          IconButton(
            tooltip: widget.gloc.add,
            icon: const Icon(Icons.check_rounded),
            onPressed: _commitInlineAdd,
          ),
          IconButton(
            tooltip: widget.gloc.cancel,
            icon: const Icon(Icons.close_outlined),
            onPressed: _cancelInlineAdd,
          ),
        ],
      ),
    );
  }

  Widget _buildInlineAddButton() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _startInlineAdd,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
          child: Row(
            children: [
              Icon(Icons.add, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.gloc.add_category,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);

    // Use widget.items directly
    final itemsToShow = widget.items;

    // Calculate dynamic height: 80% initially, but expand when keyboard is open or inline adding
    final baseMaxHeight = screenHeight * 0.8;
    final expandedMaxHeight = screenHeight * 0.95;
    final currentMaxHeight = keyboardHeight > 0 || _inlineAdding
        ? expandedMaxHeight
        : baseMaxHeight;

    final listMaxHeight =
        currentMaxHeight -
        200; // Account for title, padding, and add button space

    final list = itemsToShow.isEmpty
        ? const SizedBox.shrink()
        : ConstrainedBox(
            constraints: BoxConstraints(maxHeight: listMaxHeight, minHeight: 0),
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: itemsToShow.length,
              itemBuilder: (ctx, i) {
                final item = itemsToShow[i];
                final isSel = widget.selected == item;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSel
                            ? theme.colorScheme.surfaceContainerHigh
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        widget.itemLabel(item),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSel
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: isSel ? FontWeight.w600 : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: currentMaxHeight,
        minHeight: screenHeight * 0.3, // Minimum 30% height
      ),
      child: GroupBottomSheetScaffold(
        title: widget.sheetTitle ?? (widget.onAddItemInline != null ? widget.gloc.add : null),
        showHandle: true,
        scrollable: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              list,
              // Inline add functionality
              if (widget.onAddItemInline != null) ...[
                const SizedBox(height: 8),
                if (_inlineAdding)
                  _buildInlineAddRow()
                else
                  _buildInlineAddButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
