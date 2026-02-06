import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
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
    backgroundColor: Colors.transparent,
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
      Future.delayed(const Duration(milliseconds: 150), () {
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
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);

    // Use current items (may have been updated locally)
    final itemsToShow = _currentItems;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: keyboardHeight > 0 ? 0.9 : 0.8,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              if (widget.sheetTitle != null) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    widget.sheetTitle!,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              // List
              Expanded(
                child: itemsToShow.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: itemsToShow.length,
                        itemBuilder: (ctx, i) {
                          final item = itemsToShow[i];
                          final isSel = widget.selected == item;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
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
              ),
              // Inline add functionality
              if (widget.onAddItemInline != null) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    16 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: _inlineAdding
                      ? _buildInlineAddRow()
                      : _buildInlineAddButton(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
