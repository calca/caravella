import 'package:material_ui/material_ui.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';

/// Generic inline editable list for simple name-based items (participants, categories, etc.).
/// Supports add, edit (inline), delete. Parent owns the source of truth list; this widget
/// keeps only transient UI state (editing index / add mode / controllers).
class EditableNameList extends StatefulWidget {
  final String title;
  final bool requiredMark;
  final List<String> items;
  final String addLabel; // e.g. "Add participant"
  final String hintLabel; // e.g. "Name"
  final String editTooltip;
  final String deleteTooltip;
  final String saveTooltip;
  final String cancelTooltip;
  final String addTooltip;
  final String duplicateError; // message when trying to add/edit duplicate
  final void Function(String) onAdd;
  final void Function(int, String) onEdit;
  final void Function(int) onDelete;
  final IconData itemIcon;
  final Color? borderColor;
  final String? description;
  final bool showEmptyHint;

  /// Show [title] / [description] above the list (off when the page title
  /// already says it).
  final bool showHeader;

  const EditableNameList({
    super.key,
    required this.title,
    required this.items,
    required this.addLabel,
    required this.hintLabel,
    required this.editTooltip,
    required this.deleteTooltip,
    required this.saveTooltip,
    required this.cancelTooltip,
    required this.addTooltip,
    required this.duplicateError,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    this.requiredMark = false,
    this.itemIcon = Icons.label_outline,
    this.borderColor,
    this.description,
    this.showEmptyHint = false,
    this.showHeader = true,
  });

  @override
  State<EditableNameList> createState() => _EditableNameListState();
}

class _EditableNameListState extends State<EditableNameList> {
  int? _editingIndex;
  bool _adding = false;

  void _startEdit(int index) {
    setState(() {
      _adding = false;
      _editingIndex = index;
    });
  }

  void _cancelEdit() {
    setState(() => _editingIndex = null);
    FocusScope.of(context).unfocus();
  }

  bool _saveEdit(String val) {
    if (_editingIndex == null) return false;
    // Prevent duplicates (case-insensitive) against other items, excluding
    // the item being edited itself (so re-saving with just a case change,
    // e.g. "Mario" -> "mario", isn't flagged as colliding with itself).
    final lower = val.toLowerCase();
    final duplicate = widget.items.asMap().entries.any(
      (entry) =>
          entry.key != _editingIndex && entry.value.toLowerCase() == lower,
    );
    if (duplicate) {
      AppToast.show(context, widget.duplicateError, type: ToastType.info);
      return false;
    }
    widget.onEdit(_editingIndex!, val);
    setState(() => _editingIndex = null);
    FocusScope.of(context).unfocus();
    return true;
  }

  void _startAdd() {
    setState(() {
      _editingIndex = null;
      _adding = true;
    });
  }

  void _cancelAdd() {
    setState(() => _adding = false);
    FocusScope.of(context).unfocus();
  }

  /// Adds [val]; the field stays open for the next name.
  bool _commitAdd(String val) {
    final lower = val.toLowerCase();
    if (widget.items.any((e) => e.toLowerCase() == lower)) {
      AppToast.show(context, widget.duplicateError, type: ToastType.info);
      return false;
    }
    widget.onAdd(val);
    return true;
  }

  Widget _buildStaticRow(int index, String name) {
    final s = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      child: Row(
        children: [
          _iconCircle(widget.itemIcon),
          const SizedBox(width: 12),
          Expanded(child: _nameText(context, name)),
          IconButton(
            tooltip: widget.editTooltip,
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: s.onSurfaceVariant,
            ),
            onPressed: () => _startEdit(index),
          ),
          IconButton(
            tooltip: widget.deleteTooltip,
            icon: Icon(Icons.delete_outline, size: 20, color: s.error),
            onPressed: () => widget.onDelete(index),
          ),
        ],
      ),
    );
  }

  /// Monochrome icon in a neutral circle, as in the settings rows.
  Widget _iconCircle(IconData icon) {
    final s = Theme.of(context).colorScheme;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: s.onSurface.withValues(alpha: 0.06),
      ),
      child: Icon(icon, size: 20, color: s.onSurface),
    );
  }

  Widget _buildEditRow(int index) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    child: InlineEntryField(
      key: ValueKey('edit-$index'),
      initialText: widget.items[index],
      hintText: widget.hintLabel,
      commitTooltip: widget.saveTooltip,
      cancelTooltip: widget.cancelTooltip,
      onCommit: _saveEdit,
      onCancel: _cancelEdit,
    ),
  );

  Widget _buildAddRow() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
    child: InlineEntryField(
      key: const ValueKey('add'),
      hintText: widget.hintLabel,
      commitTooltip: widget.addTooltip,
      cancelTooltip: widget.cancelTooltip,
      keepOpen: true,
      onCommit: _commitAdd,
      onCancel: _cancelAdd,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final rows = <Widget>[
      ...List.generate(widget.items.length, (index) {
        if (_editingIndex == index) return _buildEditRow(index);
        return _buildStaticRow(index, widget.items[index]);
      }),
      if (_adding)
        _buildAddRow()
      else
        InkWell(
          onTap: _startAdd,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Row(
              children: [
                _iconCircle(Icons.add),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.addLabel,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: s.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
    final radius = BorderRadius.circular(20);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showHeader) ...[
          SectionHeader(
            title: widget.title,
            description: widget.description,
            requiredMark: widget.requiredMark,
            showRequiredHint: widget.showEmptyHint && widget.items.isEmpty,
            padding: EdgeInsets.zero,
            spacing: 4,
          ),
          const SizedBox(height: 12),
        ],
        // Rows in a card, like the settings pages.
        CardOutline(
          borderRadius: radius,
          child: Material(
            color: s.raisedSurface,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 64,
                      endIndent: 16,
                      color: s.outlineVariant.withValues(alpha: 0.5),
                    ),
                  rows[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// The item's name: wraps on spaces; a single word too long for the row
  /// (large text: "Accommodation") shrinks instead of breaking mid-word.
  Widget _nameText(BuildContext context, String name) {
    final style = Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600);
    if (name.trim().contains(' ')) return Text(name, style: style);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(name, maxLines: 1, style: style),
    );
  }
}
