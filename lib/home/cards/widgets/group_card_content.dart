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
/// colors. The recent expenses
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
    final header = MergeSemantics(
      child: Semantics(
        button: onOpen != null,
        onTap: onOpen,
        child: GroupCardHeader(
          group: group,
          localizations: localizations,
          theme: theme,
          isSynced: isSynced,
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
        if (photo == null) {
          return Padding(
            padding: const EdgeInsets.all(_padding),
            child: Column(
              mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [header, gap, amounts, gap, ?wave, ?addButton],
            ),
          );
        }

        final photoArea = Stack(
          fit: StackFit.expand,
          children: [
            PhotoVeil(
              path: photo,
              color: theme.colorScheme.surface,
              // Title and dates sit on the plain surface below.
              solidExtent: PhotoVeilSpot.home.solidExtent,
              fadeExtent: PhotoVeilSpot.home.fadeExtent,
            ),
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
                  Positioned.fill(
                    child: PhotoVeil(
                      path: photo,
                      color: theme.colorScheme.surface,
                      solidExtent: PhotoVeilSpot.home.solidExtent,
                      fadeExtent: PhotoVeilSpot.home.fadeExtent,
                    ),
                  ),
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
                  // The photo needs room to show: the wave only on cards
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
