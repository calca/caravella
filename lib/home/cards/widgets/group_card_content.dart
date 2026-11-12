import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:intl/intl.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../../../manager/details/pages/tabs/usecase/daily_totals_utils.dart';
import 'group_card_header.dart';
import 'group_card_amounts.dart';
import 'add_expense_controller.dart';

/// The group card on Home (the first of the two): title and dates, total and
/// today's spending, and a calm wave of the spending over the period.
///
/// With a photo, the photo fills the top of the card in full color and melts
/// into the card color, where title, dates and figures keep the theme's
/// colors. A group color takes the photo's place the same way
/// ([ColorVeil]), with the type icon top-left so it doesn't look empty. The recent expenses
/// are in the second card ([GroupCardActivity]).
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
  });

  /// Card height from which the spending wave fits under the figures.
  static const double waveMinHeight = 300;

  /// Same, with a photo cover above the figures.
  static const double photoWaveMinHeight = 440;

  static const double _padding = 24;

  /// Photo shown above the title when the card sizes to its content (large
  /// text): the photo area is this plus the title block, however tall.
  static const double _photoAboveTitle = 140;

  @override
  Widget build(BuildContext context) {
    final photo = photoPath;
    final tint = photo == null ? coverColor : null;
    final header = MergeSemantics(
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
          ),
        ),
      ),
    );
    final amounts = GroupCardAmounts(
      group: group,
      theme: theme,
      localizations: localizations,
    );
    final addButton = showAddButton
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final wave = constraints.maxHeight >= waveMinHeight
            ? _wave(context)
            : null;

        // Unbounded (large text): stacked at their own height, no spacers.
        final bounded = constraints.hasBoundedHeight;
        final gap = bounded ? const Spacer() : const SizedBox(height: _padding);
        if (photo == null && tint == null) {
          return Padding(
            padding: const EdgeInsets.all(_padding),
            child: Column(
              mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [header, gap, amounts, gap, ?wave, ?addButton],
            ),
          );
        }

        // Title and dates sit on the plain surface below the cover.
        Widget cover() => photo != null
            ? PhotoVeil(
                path: photo,
                color: theme.colorScheme.raisedSurface,
                solidExtent: PhotoVeilSpot.home.solidExtent,
                fadeExtent: PhotoVeilSpot.home.fadeExtent,
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  ColorVeil(
                    color: tint!,
                    surface: theme.colorScheme.raisedSurface,
                    solidExtent: PhotoVeilSpot.home.solidExtent,
                    fadeExtent: PhotoVeilSpot.home.fadeExtent,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(_padding),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: _TypeIcon(group: group, color: tint),
                    ),
                  ),
                ],
              );

        final photoArea = Stack(
          fit: StackFit.expand,
          children: [
            cover(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _padding,
                _padding,
                _padding,
                12,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [header],
              ),
            ),
          ],
        );
        return Column(
          mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (bounded)
              Expanded(child: photoArea)
            else
              Stack(
                children: [
                  Positioned.fill(child: cover()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _padding,
                      _photoAboveTitle,
                      _padding,
                      12,
                    ),
                    child: header,
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                _padding,
                16,
                _padding,
                _padding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  amounts,
                  // The cover needs room to show: the wave only on cards
                  // tall enough for both.
                  if (wave != null &&
                      constraints.maxHeight >= photoWaveMinHeight) ...[
                    const SizedBox(height: 16),
                    wave,
                  ],
                  ?addButton,
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// The spending over the group's period, or null with too little to draw.
  Widget? _wave(BuildContext context) {
    final series = buildGroupSpendingSeries(group);
    if (series == null || !SpendingWave.canShow(series.values)) return null;
    final locale = Localizations.localeOf(context).toString();
    final format = DateFormat.MMMd(locale);
    final now = DateTime.now();
    final endsToday =
        series.end.year == now.year &&
        series.end.month == now.month &&
        series.end.day == now.day;
    return SpendingWave(
      values: series.values,
      startLabel: format.format(series.start),
      endLabel: endsToday ? localizations.today : format.format(series.end),
    );
  }
}

/// The group type's icon in a circle, on the color cover (as on the Groups
/// cards).
class _TypeIcon extends StatelessWidget {
  final ExpenseGroup group;
  final Color color;

  const _TypeIcon({required this.group, required this.color});

  @override
  Widget build(BuildContext context) {
    final fg = ExpenseGroupColorPalette.getContrastingTextColor(color);
    return ExcludeSemantics(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fg.withValues(alpha: 0.12),
        ),
        child: Icon(
          (group.groupType ?? ExpenseGroupType.other).icon,
          size: 24,
          color: fg,
        ),
      ),
    );
  }
}
