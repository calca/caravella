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
  final gen.AppLocalizations gloc;
  const _SelectionSheet({
    required this.items,
    required this.selected,
    required this.itemLabel,
    required this.gloc,
    this.onAddItem,
    this.addItemTooltip,
  });

  @override
  State<_SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<_SelectionSheet<T>> {
  bool _adding = false;

  Future<void> _handleAdd() async {
    if (widget.onAddItem == null) return;
    setState(() => _adding = true);
    try {
      await widget.onAddItem!();
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final theme = Theme.of(context);
    final list = ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.items.length,
        itemBuilder: (ctx, i) {
          final item = widget.items[i];
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
      title: widget.onAddItem != null
          ? (widget.addItemTooltip ?? widget.gloc.add)
          : null,
      showHandle: true,
      scrollable: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          ],
        ),
      ),
    );
  }
}
