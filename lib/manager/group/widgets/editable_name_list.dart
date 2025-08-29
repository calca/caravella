import 'package:flutter/material.dart';
import '../../../themes/app_text_styles.dart';
import 'section_header.dart';

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
  });

  @override
  State<EditableNameList> createState() => _EditableNameListState();
}

class _EditableNameListState extends State<EditableNameList> {
  int? _editingIndex;
  bool _adding = false;
  final TextEditingController _editController = TextEditingController();
  final TextEditingController _addController = TextEditingController();
  final FocusNode _editFocus = FocusNode();
  final FocusNode _addFocus = FocusNode();

  @override
  void dispose() {
    _editController.dispose();
    _addController.dispose();
    _editFocus.dispose();
    _addFocus.dispose();
    super.dispose();
  }

  void _startEdit(int index) {
    setState(() {
      _adding = false;
      _editingIndex = index;
      _editController.text = widget.items[index];
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _editFocus.requestFocus(),
      );
    });
  }

  void _cancelEdit() {
    setState(() => _editingIndex = null);
    FocusScope.of(context).unfocus();
  }

  void _saveEdit() {
    final val = _editController.text.trim();
    if (val.isEmpty || _editingIndex == null) return;
    // Prevent duplicates (case-insensitive) except when unchanged
    final lower = val.toLowerCase();
    final unchanged = val == widget.items[_editingIndex!];
    if (!unchanged && widget.items.any((e) => e.toLowerCase() == lower)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.duplicateError)));
      return;
    }
    widget.onEdit(_editingIndex!, val);
    setState(() => _editingIndex = null);
    FocusScope.of(context).unfocus();
  }

  void _startAdd() {
    setState(() {
      _editingIndex = null;
      _adding = true;
      _addController.clear();
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _addFocus.requestFocus(),
      );
    });
  }

  void _cancelAdd() {
    setState(() => _adding = false);
    FocusScope.of(context).unfocus();
  }

  void _commitAdd() {
    final val = _addController.text.trim();
    if (val.isEmpty) return;
    final lower = val.toLowerCase();
    if (widget.items.any((e) => e.toLowerCase() == lower)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.duplicateError)));
      return;
    }
    widget.onAdd(val);
    setState(() {
      _adding = false;
      _addController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  Widget _buildStaticRow(int index, String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ),
                child: Text(name, style: AppTextStyles.listItem(context)),
              ),
            ),
            IconButton.filledTonal(
              tooltip: widget.editTooltip,
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: () => _startEdit(index),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHigh,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                minimumSize: const Size(42, 42),
              ),
            ),
            const SizedBox(width: 4),
            IconButton.filledTonal(
              tooltip: widget.deleteTooltip,
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: () => widget.onDelete(index),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHigh,
                foregroundColor: Theme.of(context).colorScheme.error,
                minimumSize: const Size(42, 42),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                child: TextField(
                  controller: _editController,
                  focusNode: _editFocus,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintLabel,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveEdit(),
                ),
              ),
            ),
            IconButton(
              tooltip: widget.saveTooltip,
              icon: const Icon(Icons.check_rounded),
              onPressed: _saveEdit,
            ),
            IconButton(
              tooltip: widget.cancelTooltip,
              icon: const Icon(Icons.close_outlined),
              onPressed: _cancelEdit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                child: TextField(
                  controller: _addController,
                  focusNode: _addFocus,
                  autofocus: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hintLabel,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _commitAdd(),
                ),
              ),
            ),
            IconButton(
              tooltip: widget.addTooltip,
              icon: const Icon(Icons.check_rounded),
              onPressed: _commitAdd,
            ),
            IconButton(
              tooltip: widget.cancelTooltip,
              icon: const Icon(Icons.close_outlined),
              onPressed: _cancelAdd,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: widget.title,
          description: widget.description,
          requiredMark: widget.requiredMark,
          padding: EdgeInsets.zero,
          spacing: 4,
        ),
        const SizedBox(height: 12),
        ...List.generate(widget.items.length, (index) {
          if (_editingIndex == index) return _buildEditRow();
          return _buildStaticRow(index, widget.items[index]);
        }),
        if (_adding)
          _buildAddRow()
        else
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _startAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 14.0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.addLabel,
                        style: AppTextStyles.listItem(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
