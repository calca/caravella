import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../data/group_form_state.dart';
import 'group_title_field.dart';
import '../group_type/group_type_localization.dart';

/// Reusable widget that displays a group name input field with an icon
/// representing the selected group type. The icon is tappable to change
/// the group type.
class GroupNameWithIconField extends StatelessWidget {
  final VoidCallback onIconTap;
  final VoidCallback? onSubmitted;

  /// Optional localized hint forwarded to the embedded title field.
  final String? hintText;
  final TextAlign textAlign;
  final TextStyle? textStyle;
  final InputDecoration? decoration;

  const GroupNameWithIconField({
    super.key,
    required this.onIconTap,
    this.onSubmitted,
    this.hintText,
    this.textAlign = TextAlign.start,
    this.textStyle,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<GroupFormState, (ExpenseGroupType?, int?)>(
      selector: (context, s) => (s.groupType, s.customTemplateIconCodePoint),
      builder: (context, value, child) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: gen.AppLocalizations.of(context).group_type_description,
            excludeSemantics: true,
            child: InkWell(
              onTap: onIconTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                // 48dp: minimum touch target, and the height of the name field.
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  value.$1?.icon ??
                      GroupTypeLocalization.iconFromCodePoint(value.$2 ?? 0),
                  size: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GroupTitleField(
              onSubmitted: onSubmitted,
              hintText: hintText,
              textAlign: textAlign,
              style: textStyle,
              decoration: decoration,
            ),
          ),
        ],
      ),
    );
  }
}
