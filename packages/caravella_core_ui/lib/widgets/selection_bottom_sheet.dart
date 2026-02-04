import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'bottom_sheet_scaffold.dart';
import 'app_toast.dart';

/// Generic modal bottom sheet for selecting an item from a list.
/// Supports inline add-item action shown within the sheet.
Future<T?> showSelectionBottomSheet<T>({
  required BuildContext context,
  required List<T> items,
  required T? selected,
  required String Function(T) itemLabel,
  Future<void> Function(String)? onAddItemInline,
  String? addItemHint,
  String? sheetTitle,
  String? addLabel,
  String? cancelLabel,
  String? addCategoryLabel,
  String? alreadyExistsMessage,
}) async {
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
      sheetTitle: sheetTitle,
      addLabel: addLabel,
      cancelLabel: cancelLabel,
      addCategoryLabel: addCategoryLabel,
      alreadyExistsMessage: alreadyExistsMessage,
    ),
  );
}

class _SelectionSheet<T> extends StatefulWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) itemLabel;
  final Future<void> Function(String)? onAddItemInline;
  final String? addItemHint;
  final String? sheetTitle;
  final String? addLabel;
  final String? cancelLabel;
  final String? addCategoryLabel;
  final String? alreadyExistsMessage;
  const _SelectionSheet({
    required this.items,
    required this.selected,
    required this.itemLabel,
    this.onAddItemInline,
    this.addItemHint,
    this.sheetTitle,
    this.addLabel,
    this.cancelLabel,
    this.addCategoryLabel,
    this.alreadyExistsMessage,
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
    // Add focus listener to handle keyboard appearance and auto-scroll
    _inlineFocus.addListener(() {
      if (_inlineFocus.hasFocus) {
        // Immediate scroll attempt
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToInputField();
        });
        // Delayed scroll to account for keyboard animation
        Future.delayed(const Duration(milliseconds: 300), () {
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
    if (!_scrollController.hasClients || !mounted || widget.selected == null)
      return;

    try {
      final selectedIndex = _currentItems.indexOf(widget.selected!);
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

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight == 0) return;

    try {
      // Wait for layout to settle after keyboard animation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!_scrollController.hasClients || !mounted) return;

        // Scroll to bottom to ensure input field is visible above keyboard
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        if (maxScrollExtent > 0) {
          // Add extra offset to ensure input is well above keyboard
          final targetOffset = maxScrollExtent + 50;
          _scrollController.animateTo(
            targetOffset.clamp(0.0, maxScrollExtent),
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
      // Also trigger scroll immediately after focus
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollToInputField();
      });
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
        if (mounted) {
          // Small delay to ensure UI updates are visible
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            Navigator.of(context).pop(val as T);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, 'Error adding item: $e', type: ToastType.error);
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
                  hintText: widget.addItemHint,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _commitInlineAdd(),
              ),
            ),
          ),
          IconButton(
            tooltip: widget.addLabel,
            icon: const Icon(Icons.check_rounded),
            onPressed: _commitInlineAdd,
          ),
          IconButton(
            tooltip: widget.cancelLabel,
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
                  widget.addCategoryLabel ?? '',
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

    // Use current items (may have been updated locally)
    final itemsToShow = _currentItems;

    // Calculate dynamic height: 80% initially, but adjust for keyboard
    final baseMaxHeight = screenHeight * 0.8;
    final availableHeight = screenHeight - keyboardHeight;
    final expandedMaxHeight = availableHeight * 0.95;
    final currentMaxHeight = keyboardHeight > 0 || _inlineAdding
        ? expandedMaxHeight
        : baseMaxHeight;

    // Reserve more space for input field and buttons when keyboard is open
    final reservedSpace = keyboardHeight > 0 ? 250 : 200;
    final listMaxHeight = (currentMaxHeight - reservedSpace).clamp(
      100.0,
      screenHeight * 0.7,
    );

    final list = itemsToShow.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            height: listMaxHeight,
            child: ListView.builder(
              controller: _scrollController,
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
        title: widget.sheetTitle,
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
