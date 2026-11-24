import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../home/cards/widgets/group_meta_line.dart';
import '../data/group_form_state.dart';
import '../group_type/group_type_localization.dart';

/// The group as it's being created, on the card it will have on the Groups
/// page ([GroupCardFace]), updated while typing: name, the line under it as
/// on Home's card ([GroupMetaLine]: the type, then the dates once set),
/// currency and background.
/// Decorative for screen readers: the field and the pills say the same.
class WizardGroupPreview extends StatelessWidget {
  /// Shown until the group has a name.
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
    final radius = GroupCardFace.borderRadiusFor(wide: true);
    final icon = state.customTemplateIconCodePoint != null
        ? GroupTypeLocalization.iconFromCodePoint(
            state.customTemplateIconCodePoint!,
          )
        : (state.groupType ?? ExpenseGroupType.other).icon;

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
                    meta: (fg) => GroupMetaLine(
                      group: ExpenseGroup(
                        id: 'wizard-preview',
                        title: title,
                        expenses: const [],
                        participants: const [],
                        currency: '',
                        startDate: state.startDate,
                        endDate: state.endDate,
                        groupType: state.groupType,
                      ),
                      foreground: fg,
                      icon: icon,
                      // Until there's a name the type is the title already.
                      showTypeName: title.isNotEmpty,
                    ),
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
                    icon: icon,
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
