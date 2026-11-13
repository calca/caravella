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
/// Follows [GroupCardStyle.current]:
/// - **A**: the photo, the color or neutral grey in a rounded cover on top
///   with the chip and the big faint type icon; title and figures below on
///   the card surface;
/// - **B**: the whole card in the group's tint (under a photo, the photo's
///   own tone), chip on top, title and figures at the bottom.
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

  /// Overrides [GroupCardStyle.current] (tests).
  final GroupCardStyle? style;

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
    this.style,
    this.today,
  });

  /// Share of the card's height the style A cover takes.
  static const double coverShare = 0.53;

  /// Cover height when the card sizes to its content (large text).
  static const double _coverUnbounded = 160;

  @override
  Widget build(BuildContext context) {
    if (style case final style?) return _build(context, style);
    return GroupCardStyleBuilder(builder: _build);
  }

  Widget _build(BuildContext context, GroupCardStyle style) {
    final photo = photoPath;
    final look = GroupLook.of(
      photo == null ? coverColor : null,
      theme.brightness,
    );
    if (style == GroupCardStyle.a) return _buildA(context, photo, look);
    if (photo == null) {
      return _buildB(context, null, look.tint, look.onTint, look.tintMark);
    }
    return PhotoToneBuilder(
      path: photo,
      builder: (context, tone) =>
          _buildB(context, photo, tone.tone, tone.onTone, null),
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

  Widget _buildA(BuildContext context, String? photo, GroupLook look) {
    final fg = theme.colorScheme.onSurface;
    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (photo != null)
            GroupCoverPhoto(path: photo, fallback: look.cover)
          else ...[
            ColoredBox(color: look.cover),
            TypeMark(
              icon: _type.icon,
              size: 180,
              color: look.coverMark,
            ).positioned(),
          ],
          Positioned(top: 14, left: 14, child: _chip()),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.hasBoundedHeight;
        final body = Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(fg),
              if (bounded) const Spacer() else const SizedBox(height: 16),
              _figures(fg),
              ?_addButton(),
            ],
          ),
        );
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: bounded
                    ? (constraints.maxHeight - 16) * coverShare
                    : _coverUnbounded,
                child: cover,
              ),
              if (bounded) Expanded(child: body) else body,
            ],
          ),
        );
      },
    );
  }

  Widget _buildB(
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
