import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../data/group_form_state.dart';

/// Bottom sheet for picking a suggested (or random) background color,
/// opened from [BackgroundPicker]'s main sheet.
class ColorSheet extends StatelessWidget {
  final GroupFormState state;
  const ColorSheet({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final loc = gen.AppLocalizations.of(context);
    final s = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(20);
    Widget card(Widget child) => CardOutline(
      borderRadius: radius,
      child: Material(
        color: s.raisedSurface,
        borderRadius: radius,
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
    return CaravellaBottomSheetScaffold(
      title: loc.color_suggested_title,
      subtitle: loc.color_suggested_subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          card(
            Builder(
              builder: (ctx) {
                final scheme = Theme.of(ctx).colorScheme;
                final palette = ExpenseGroupColorPalette.getPaletteColors(
                  scheme,
                );
                final firstRow = palette.take(6).toList();
                final secondRow = palette.skip(6).take(6).toList();
                return Column(
                  children: [
                    _ColorPaletteRow(
                      state: state,
                      colors: firstRow,
                      startIndex: 0,
                    ),
                    const SizedBox(height: 14),
                    _ColorPaletteRow(
                      state: state,
                      colors: secondRow,
                      startIndex: 6,
                    ),
                  ],
                );
              },
            ),
          ),
          SettingsGroup(
            topSpacing: 12,
            children: [
              SettingsTile(
                icon: Icons.casino_outlined,
                title: loc.background_random_color,
                subtitle: loc.color_random_subtitle,
                chevron: false,
                onTap: () {
                  state.setColor(_randomOtherIndex(state.color));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A random palette index, never the group's current one.
int _randomOtherIndex(int? current) {
  const size = ExpenseGroupColorPalette.paletteSize;
  final index = math.Random().nextInt(size - 1);
  return current != null && index >= current ? index + 1 : index;
}

class _ColorPaletteRow extends StatelessWidget {
  final GroupFormState state;
  final List<Color> colors;
  final int startIndex; // Index offset for this row
  const _ColorPaletteRow({
    required this.state,
    required this.colors,
    required this.startIndex,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(colors.length, (i) {
        final c = colors[i];
        final colorIndex = startIndex + i;
        final selected = state.color == colorIndex;
        final mark = ExpenseGroupColorPalette.getContrastingTextColor(c);
        return InkWell(
          onTap: () {
            state.setColor(colorIndex);
            Navigator.pop(context); // chiudi subito la sheet dopo selezione
          },
          borderRadius: BorderRadius.circular(28),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected
                    ? scheme.onSurface
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                width: selected ? 3 : 1.2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: c.withValues(alpha: 0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: selected
                ? Icon(Icons.check_rounded, color: mark, size: 22)
                : null,
          ),
        );
      }),
    );
  }
}
