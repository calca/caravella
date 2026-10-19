import 'package:material_ui/material_ui.dart';

import 'floating_nav_bar.dart';

/// Pill-shaped segmented control in the floating navigation's style: a
/// neutral pill with the selected segment on a tonal fill (e.g. Active /
/// Archived on Groups, Expenses / Balances / Statistics on a group).
///
/// With [expand] the segments share the available width equally; otherwise
/// the control sizes to its labels.
class PillSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool expand;

  const PillSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    Widget segment(int i) {
      final selected = i == selectedIndex;
      void onTap() => onChanged(i);
      return Semantics(
        selected: selected,
        button: true,
        label: labels[i],
        onTap: onTap,
        excludeSemantics: true,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: selected
                  ? FloatingNavBar.selectedColor(s)
                  : Colors.transparent,
            ),
            child: Text(
              labels[i],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? s.onSurface : s.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        color: FloatingNavBar.pillColor(s),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          children: [
            for (var i = 0; i < labels.length; i++)
              expand ? Expanded(child: segment(i)) : segment(i),
          ],
        ),
      ),
    );
  }
}
