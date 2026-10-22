import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
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

class _GroupTypeTemplateFormPageState extends State<GroupTypeTemplateFormPage> {
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

    try {
      await widget.notifier.upsert(nextTemplate);
      if (mounted) Navigator.of(context).pop();
    } catch (e, st) {
      LoggerService.error(
        'Failed to save group type template',
        name: 'settings.group_templates',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        setState(() => _saving = false);
        AppToast.show(
          context,
          loc.error_saving_group(e),
          type: ToastType.error,
        );
      }
    }
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

    Widget label(String text) => Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );

    return AppSystemUI.edgeToEdge(
      child: SettingsScaffold(
        eyebrow: loc.settings_group_templates_page_title,
        title: isEdit
            ? loc.settings_group_templates_edit_title
            : loc.settings_group_templates_add_title,
        bottomBar: BottomActionBar(
          onPressed: _save,
          label: loc.save,
          enabled: !_saving,
        ),
        children: [
          // Name: a big field in its own card, like the group's settings.
          SettingsGroup(
            label: loc.settings_group_templates_name_label,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: TextField(
                  controller: _nameController,
                  maxLength: 40,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: loc.settings_group_templates_name_hint,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          SettingsGroup(
            label: loc.settings_group_templates_icon_label,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: GroupTypeLocalization.availableIcons.map((icon) {
                    final selected = icon.codePoint == _iconCodePoint;
                    return Semantics(
                      selected: selected,
                      button: true,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () =>
                            setState(() => _iconCodePoint = icon.codePoint),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected
                                ? scheme.onSurface
                                : scheme.onSurface.withValues(alpha: 0.06),
                          ),
                          child: Icon(
                            icon,
                            color: selected ? scheme.surface : scheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          label(loc.settings_group_templates_categories_label),
          EditableNameList(
            title: loc.settings_group_templates_categories_label,
            showHeader: false,
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
