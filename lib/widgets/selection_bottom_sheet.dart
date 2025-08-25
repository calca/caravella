import 'package:flutter/material.dart';
import 'package:org_app_caravella/l10n/app_localizations.dart' as gen;
import 'bottom_sheet_scaffold.dart';

/// Generic modal bottom sheet for selecting an item from a list.
/// Supports inline add-item action shown within the sheet.
/// Supports autocomplete/filtering when searchFunction is provided.
Future<T?> showSelectionBottomSheet<T>({
  required BuildContext context,
  required List<T> items,
  required T? selected,
  required String Function(T) itemLabel,
  gen.AppLocalizations? gloc,
  Future<void> Function(String)? onAddItemInline,
  String? addItemHint,
  Future<List<T>> Function(String)? searchFunction, // New parameter for autocomplete
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
      searchFunction: searchFunction,
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
  final Future<List<T>> Function(String)? searchFunction;
  
  const _SelectionSheet({
    required this.items,
    required this.selected,
    required this.itemLabel,
    required this.gloc,
    this.onAddItemInline,
    this.addItemHint,
    this.searchFunction,
  });

  @override
  State<_SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<_SelectionSheet<T>> {
  bool _inlineAdding = false;
  final TextEditingController _inlineController = TextEditingController();
  final FocusNode _inlineFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  List<T> _filteredItems = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _inlineController.dispose();
    _inlineFocus.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize filtered items with all items
    _filteredItems = List.from(widget.items);
    
    // Add focus listener to handle keyboard appearance and auto-scroll
    _inlineFocus.addListener(() {
      if (_inlineFocus.hasFocus) {
        // Delay to ensure keyboard is starting to appear
        Future.delayed(const Duration(milliseconds: 200), () {
          _scrollToInputField();
        });
      }
    });

    // Add search functionality if search function is provided
    if (widget.searchFunction != null) {
      _searchController.addListener(_onSearchChanged);
    }
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

  /// Handles search text changes
  void _onSearchChanged() async {
    final query = _searchController.text;
    
    if (widget.searchFunction != null) {
      setState(() {
        _isSearching = true;
      });
      
      try {
        final results = await widget.searchFunction!(query);
        if (mounted) {
          setState(() {
            _filteredItems = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _filteredItems = widget.items;
            _isSearching = false;
          });
        }
        debugPrint('Search error: $e');
      }
    } else {
      // Fallback to local filtering
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredItems = widget.items
            .where((item) => widget.itemLabel(item).toLowerCase().contains(lowerQuery))
            .toList();
      });
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
    final isDuplicate = widget.items.any(
      (item) => widget.itemLabel(item).toLowerCase() == lower,
    );

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.gloc.category_name} ${widget.gloc.already_exists}',
          ),
        ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding item: $e')));
      }
    }
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocus,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
        textInputAction: TextInputAction.search,
      ),
    );
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

    // Use filtered items for display
    final itemsToShow = _filteredItems;
    final hasSearchFunction = widget.searchFunction != null;

    // Calculate dynamic height: 80% initially, but expand when keyboard is open or inline adding
    final baseMaxHeight = screenHeight * 0.8;
    final expandedMaxHeight = screenHeight * 0.95;
    final currentMaxHeight = keyboardHeight > 0 || _inlineAdding
        ? expandedMaxHeight
        : baseMaxHeight;

    final listMaxHeight =
        currentMaxHeight -
        (hasSearchFunction ? 260 : 200); // Account for title, search field, padding, and add button space

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
        title: widget.onAddItemInline != null ? widget.gloc.add : null,
        showHandle: true,
        scrollable: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search field for autocomplete (if search function provided)
              if (hasSearchFunction) ...[
                _buildSearchField(),
                const SizedBox(height: 8),
              ],
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
