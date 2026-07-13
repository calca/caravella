import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/material.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import '../../manager/group/group_type/group_type_localization.dart';
import '../../manager/group/widgets/editable_name_list.dart';
import '../state/group_type_templates_notifier.dart';

/// Full page editor for creating or editing a [GroupTypeTemplate].
///
/// Replaces the previous popup-dialog based editor with a dedicated page
/// that keeps the primary save action pinned at the bottom, following the
/// same pattern used by other full-page forms in the app.
class GroupTypeTemplateFormPage extends StatefulWidget {
  final GroupTypeTemplatesNotifier notifier;
  final GroupTypeTemplate? template;

  const GroupTypeTemplateFormPage({
    super.key,
    required this.notifier,
    this.template,
  });

  @override
  State<GroupTypeTemplateFormPage> createState() =>
      _GroupTypeTemplateFormPageState();
}

class _GroupTypeTemplateFormPageState
    extends State<GroupTypeTemplateFormPage> {
  late final TextEditingController _nameController;
  late final List<String> _categories;
  late int _iconCodePoint;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _categories = <String>[...?widget.template?.defaultCategories];
    _iconCodePoint =
        widget.template?.iconCodePoint ??
        GroupTypeLocalization.availableIcons.first.codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final loc = gen.AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty || _categories.isEmpty) {
      AppToast.show(
        context,
        loc.settings_group_templates_validation_error,
        type: ToastType.info,
      );
      return;
    }

    setState(() => _saving = true);
    final nextTemplate = GroupTypeTemplate(
      id: widget.template?.id,
      createdAt: widget.template?.createdAt,
      name: name,
      iconCodePoint: _iconCodePoint,
      defaultCategories: _categories,
    );

    await widget.notifier.upsert(nextTemplate);
    if (mounted) Navigator.of(context).pop();
  }

  void _addCategory(String name) {
    setState(() => _categories.add(name));
  }

  void _editCategory(int index, String name) {
    setState(() => _categories[index] = name);
  }

  void _removeCategory(int index) {
    setState(() => _categories.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final isEdit = widget.template != null;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? loc.settings_group_templates_edit_title
              : loc.settings_group_templates_add_title,
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                style: FormTheme.getFieldTextStyle(context),
                decoration: FormTheme.getStandardDecoration(
                  hintText: loc.settings_group_templates_name_hint,
                ).copyWith(labelText: loc.settings_group_templates_name_label),
                maxLength: 40,
              ),
              const SizedBox(height: 16),
              SectionHeader(
                title: loc.settings_group_templates_icon_label,
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GroupTypeLocalization.availableIcons.map((icon) {
                  final selected = icon.codePoint == _iconCodePoint;
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () =>
                        setState(() => _iconCodePoint = icon.codePoint),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: selected
                            ? scheme.primaryContainer
                            : scheme.surfaceContainerHigh,
                        border: Border.all(
                          color: selected ? scheme.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: selected
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              EditableNameList(
                title: loc.settings_group_templates_categories_label,
                requiredMark: true,
                items: _categories,
                addLabel: loc.add_category,
                hintLabel: loc.category_name,
                editTooltip: loc.edit_category,
                deleteTooltip: loc.delete,
                saveTooltip: loc.save,
                cancelTooltip: loc.cancel,
                addTooltip: loc.add,
                duplicateError: '${loc.category_name} ${loc.already_exists}',
                onAdd: _addCategory,
                onEdit: _editCategory,
                onDelete: _removeCategory,
                itemIcon: AppIcons.category,
                showEmptyHint: _categories.isEmpty,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        onPressed: _save,
        label: loc.save,
        enabled: !_saving,
      ),
    );
  }
}
