import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../details/pages/tabs/usecase/date_range_formatter.dart';
import '../data/group_form_state.dart';
import '../group_type/group_type_localization.dart';

/// The group as it's being created, on the card it will have on the Groups
/// page ([GroupCardFace]), updated while typing: name, dates (or the type
/// until there are any), currency and background.
/// Decorative for screen readers: the field and the pills say the same.
class WizardGroupPreview extends StatelessWidget {
  /// Shown until the group has a name, then as the line below it until it
  /// has dates.
  final String fallbackTitle;

  /// Shorter while the keyboard is up, so the name field stays in view.
  final bool compact;

  const WizardGroupPreview({
    super.key,
    required this.fallbackTitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<GroupFormState>();
    final title = state.title.trim();
    final hasDates = state.startDate != null || state.endDate != null;
    final radius = GroupCardFace.borderRadiusFor(wide: true);

    return ExcludeSemantics(
      child: CardOutline(
        borderRadius: radius,
        child: ClipRRect(
          borderRadius: radius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: compact
                ? GroupCardFace.compactHeight
                : GroupCardFace.wideHeight,
            // The compact card has room for the text up to this size; the
            // name field below it follows the system's size.
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GroupCardFace(
                    title: title.isEmpty ? fallbackTitle : title,
                    subtitle: hasDates
                        ? formatDateRange(
                            start: state.startDate,
                            end: state.endDate,
                            locale: Localizations.localeOf(context),
                          )
                        : (title.isEmpty ? null : fallbackTitle),
                    total: 0,
                    currency:
                        state.currency['symbol'] ??
                        state.currency['code'] ??
                        'EUR',
                    photoPath: state.imagePath,
                    color: ExpenseGroupColorPalette.resolveColor(
                      state.color ??
                          ExpenseGroupColorPalette.defaultIndexFor(
                            state.groupType,
                          ),
                      theme.colorScheme,
                    ),
                    icon: state.customTemplateIconCodePoint != null
                        ? GroupTypeLocalization.iconFromCodePoint(
                            state.customTemplateIconCodePoint!,
                          )
                        : (state.groupType ?? ExpenseGroupType.other).icon,
                    wide: true,
                    compact: compact,
                  ),
                  if (state.loadingImage)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
