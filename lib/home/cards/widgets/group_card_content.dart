import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/group/group_type/group_type_localization.dart';
import 'group_card_header.dart';
import 'add_expense_controller.dart';

/// The group card on Home (the first of the two): type chip, title and
/// dates, then "Total | Today". The charts are in Statistics; the recent
/// expenses are in the second card ([GroupCardActivity]).
///
/// The whole card is in the group's tint ([GroupLook]: neutral grey without
/// a color) with the big faint type icon in the corner, or under a photo the
/// photo's own tone ([PhotoTone]) that it melts into; chip on top, title and
/// figures at the bottom.
class GroupCardContent extends StatelessWidget {
  final ExpenseGroup group;
  final gen.AppLocalizations localizations;
  final ThemeData theme;
  final VoidCallback onExpenseAdded;
  final VoidCallback? onCategoryAdded;

  /// Opens the group; exposed to screen readers on the header, since the
  /// card itself does not merge its interactive children.
  final VoidCallback? onOpen;

  /// Whether this group's data is fully synced with peers.
  final bool? isSynced;

  /// See [GroupCard.showAddButton].
  final bool showAddButton;

  /// The group photo, drawn as the card's cover.
  final String? photoPath;

  /// The group's color, drawn as the cover when there's no [photoPath].
  final Color? coverColor;

  /// "Today" for the figures; now when null (tests set it).
  final DateTime? today;

  const GroupCardContent({
    super.key,
    required this.group,
    required this.localizations,
    this.onOpen,
    required this.theme,
    required this.onExpenseAdded,
    this.onCategoryAdded,
    this.isSynced,
    this.showAddButton = true,
    this.photoPath,
    this.coverColor,
    this.today,
  });

  @override
  Widget build(BuildContext context) {
    final photo = photoPath;
    if (photo == null) {
      final look = GroupLook.of(coverColor, theme.brightness);
      return _build(context, null, look.tint, look.onTint, look.mark);
    }
    return PhotoToneBuilder(
      path: photo,
      builder: (context, tone) =>
          _build(context, photo, tone.tone, tone.onTone, null),
    );
  }

  ExpenseGroupType get _type => group.groupType ?? ExpenseGroupType.other;

  Widget _chip() => TypeChip(
    icon: _type.icon,
    label: GroupTypeLocalization.typeName(localizations, _type),
  );

  Widget _header(Color fg) => MergeSemantics(
    child: Semantics(
      button: onOpen != null,
      onTap: onOpen,
      // At least 48 dp to tap, also with a one-line title and no dates.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: GroupCardHeader(
          group: group,
          localizations: localizations,
          theme: theme,
          isSynced: isSynced,
          foreground: fg,
        ),
      ),
    ),
  );

  Widget _figures(Color fg) => FigureRow(
    color: fg,
    items: [
      FigureRowItem(
        label: localizations.group_total,
        value: group.getTotalExpenses(),
        currency: group.currency,
      ),
      FigureRowItem(
        label: localizations.today,
        value: group.getTodaySpendingSync(today),
        currency: group.currency,
      ),
    ],
  );

  Widget? _addButton() => showAddButton
      ? Padding(
          padding: const EdgeInsets.only(top: 12),
          child: GroupCardAddButton(
            group: group,
            theme: theme,
            controller: AddExpenseController(
              group: group,
              onExpenseAdded: onExpenseAdded,
              onCategoryAdded: onCategoryAdded,
            ),
          ),
        )
      : null;

  Widget _build(
    BuildContext context,
    String? photo,
    Color background,
    Color fg,
    Color? mark,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight;
        final content = Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(alignment: Alignment.centerLeft, child: _chip()),
              if (bounded) const Spacer() else const SizedBox(height: 96),
              _header(fg),
              const SizedBox(height: 8),
              _figures(fg),
              ?_addButton(),
            ],
          ),
        );
        final layers = <Widget>[
          if (photo != null)
            LayoutBuilder(
              builder: (context, box) => PhotoBand(
                path: photo,
                tone: background,
                photoHeight: box.maxHeight * 0.62,
              ),
            )
          else
            ColoredBox(color: background),
          if (mark != null)
            TypeMark(icon: _type.icon, size: 180, color: mark).positioned(),
        ];
        if (bounded) {
          return Stack(fit: StackFit.expand, children: [...layers, content]);
        }
        return Stack(
          children: [
            for (final layer in layers)
              layer is Positioned ? layer : Positioned.fill(child: layer),
            content,
          ],
        );
      },
    );
  }
}
