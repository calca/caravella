import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'bottom_sheet_scaffold.dart';

/// Generic modal bottom sheet for selecting an item from a list.
/// Supports an optional add-item action shown within the sheet.
Future<T?> showSelectionBottomSheet<T>({
  required BuildContext context,
  required List<T> items,
  required T? selected,
  required String Function(T) itemLabel,
  gen.AppLocalizations? gloc,
  Future<void> Function()? onAddItem,
  String? addItemTooltip,
  Future<void> Function(String)? onAddItemInline,
  String? addItemHint,
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
      onAddItem: onAddItem,
      addItemTooltip: addItemTooltip,
      onAddItemInline: onAddItemInline,
      addItemHint: addItemHint,
      gloc: resolved,
    ),
  );
}

class _SelectionSheet<T> extends StatefulWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) itemLabel;
  final Future<void> Function()? onAddItem;
  final String? addItemTooltip;
  final Future<void> Function(String)? onAddItemInline;
  final String? addItemHint;
  final gen.AppLocalizations gloc;
  const _SelectionSheet({
    required this.items,
    required this.selected,
    required this.itemLabel,
    required this.gloc,
    this.onAddItem,
    this.addItemTooltip,
    this.onAddItemInline,
    this.addItemHint,
  });

  @override
  State<_SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<_SelectionSheet<T>> {
  bool _adding = false;
  bool _inlineAdding = false;
  final TextEditingController _inlineController = TextEditingController();
  final FocusNode _inlineFocus = FocusNode();
  List<T> _currentItems = [];

  @override
  void initState() {
    super.initState();
    _currentItems = List<T>.from(widget.items);
  }

  @override
  void didUpdateWidget(_SelectionSheet<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the current items when the widget's items list changes
    if (widget.items != oldWidget.items) {
      setState(() {
        _currentItems = List<T>.from(widget.items);
      });
    }
  }

  @override
  void dispose() {
    _inlineController.dispose();
    _inlineFocus.dispose();
    super.dispose();
  }

  Future<void> _handleAdd() async {
    if (widget.onAddItem == null) return;
    setState(() => _adding = true);
    try {
      await widget.onAddItem!();
    } finally {
      if (mounted) setState(() => _adding = false);
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

    // Check for duplicates (case-insensitive)
    final lower = val.toLowerCase();
    final isDuplicate = widget.items.any((item) => 
      widget.itemLabel(item).toLowerCase() == lower);
    
    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.gloc.category_name} ${widget.gloc.already_exists}')),
      );
      return;
    }

    try {
      await widget.onAddItemInline!(val);
      setState(() {
        _inlineAdding = false;
        _inlineController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding item: $e')),
        );
      }
    }
  }

  Widget _buildInlineAddRow() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
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
          padding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 14.0,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.addItemTooltip ?? widget.gloc.add_category,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    
    // Use widget.items directly to get the most up-to-date list
    final itemsToShow = widget.items;
    
    final list = ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: itemsToShow.length,
        itemBuilder: (ctx, i) {
          final item = itemsToShow[i];
          final isSel = widget.selected == item;
          return ListTile(
            title: Text(widget.itemLabel(item)),
            trailing: isSel
                ? Icon(Icons.check, color: theme.colorScheme.primary)
                : null,
            onTap: () => Navigator.of(context).pop(item),
          );
        },
      ),
    );
    
    return GroupBottomSheetScaffold(
      title: widget.onAddItem != null || widget.onAddItemInline != null
          ? (widget.addItemTooltip ?? widget.gloc.add)
          : null,
      showHandle: true,
      scrollable: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Legacy add button (keep for backward compatibility)
            if (widget.onAddItem != null)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.addItemTooltip ?? widget.gloc.add,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: _adding ? null : _handleAdd,
                    icon: _adding
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                theme.colorScheme.primary,
                              ),
                            ),
                          )
                        : const Icon(Icons.add),
                    tooltip: widget.addItemTooltip ?? widget.gloc.add,
                  ),
                ],
              ),
            if (widget.onAddItem != null) const SizedBox(height: 8),
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
    );
  }
}
