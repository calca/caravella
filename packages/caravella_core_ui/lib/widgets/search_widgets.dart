import 'dart:io';

import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';

import '../themes/caravella_themes.dart';
import 'card_outline.dart';
import 'round_back_button.dart';

/// Top of a search page: round back button, the query in a white pill and,
/// with [onFilters], a round filters button showing how many filters are on.
class SearchTopBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilters;
  final int activeFilters;
  final String filtersTooltip;
  final String clearTooltip;

  const SearchTopBar({
    super.key,
    required this.controller,
    this.focusNode,
    required this.hintText,
    required this.onChanged,
    this.onSubmitted,
    this.onFilters,
    this.activeFilters = 0,
    required this.filtersTooltip,
    required this.clearTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return Row(
      children: [
        const RoundBackButton(),
        const SizedBox(width: 8),
        Expanded(
          child: DecoratedBox(
            decoration: ShapeDecoration(
              color: s.raisedSurface,
              shape: StadiumBorder(
                side: BorderSide(color: CardOutline.colorFor(s.brightness)),
              ),
            ),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: s.onSurfaceVariant,
                  ),
                  suffixIcon: value.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: clearTooltip,
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            controller.clear();
                            onChanged('');
                          },
                        ),
                ),
              ),
            ),
          ),
        ),
        if (onFilters != null) ...[
          const SizedBox(width: 8),
          Material(
            color: activeFilters > 0 ? s.primaryContainer : s.raisedSurface,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: activeFilters > 0
                  ? '$filtersTooltip ($activeFilters)'
                  : filtersTooltip,
              onPressed: onFilters,
              icon: Badge(
                isLabelVisible: activeFilters > 0,
                label: Text('$activeFilters'),
                backgroundColor: s.primary,
                textColor: s.onPrimary,
                child: Icon(
                  Icons.tune_rounded,
                  color: activeFilters > 0 ? s.onPrimaryContainer : s.onSurface,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// A filter or suggestion pill: outlined when off, filled when [selected];
/// with [onRemove] it shows a ✕ (an active filter to remove).
class FilterPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const FilterPill({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final fg = selected ? s.surface : s.onSurface;
    final tap = onTap ?? onRemove;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? s.onSurface : s.raisedSurface,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? s.onSurface : s.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: tap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (onRemove != null) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.close_rounded, size: 16, color: fg),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A labelled block of [FilterPill]s that wrap onto several lines.
class PillSection extends StatelessWidget {
  final String label;
  final List<Widget> pills;

  const PillSection({super.key, required this.label, required this.pills});

  @override
  Widget build(BuildContext context) {
    if (pills.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Semantics(
              header: true,
              child: Text(
                label.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
          Wrap(spacing: 8, runSpacing: 8, children: pills),
        ],
      ),
    );
  }
}

/// Count and total of the current results ("2 expenses · 206,00 €").
class SearchSummaryBar extends StatelessWidget {
  final String count;
  final String total;

  const SearchSummaryBar({super.key, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final style = theme.textTheme.titleSmall?.copyWith(
      color: s.onPrimaryContainer,
      fontWeight: FontWeight.w700,
    );
    return Semantics(
      liveRegion: true,
      label: '$count, $total',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: s.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(child: Text(count, style: style)),
            Text(total, style: style),
          ],
        ),
      ),
    );
  }
}

/// Round group avatar: its photo, else its palette color (or a neutral
/// circle) with the group type icon.
class GroupIconAvatar extends StatelessWidget {
  final ExpenseGroup group;
  final double size;

  const GroupIconAvatar({super.key, required this.group, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final file = group.file;
    Widget child;
    if (file != null && file.isNotEmpty && File(file).existsSync()) {
      child = ClipOval(
        child: Image.file(
          File(file),
          fit: BoxFit.cover,
          width: size,
          height: size,
          cacheWidth: (size * 3).round(),
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        ),
      );
    } else {
      final Color? color = group.color == null
          ? null
          : ExpenseGroupColorPalette.isLegacyColorValue(group.color)
          ? Color(group.color!)
          : ExpenseGroupColorPalette.resolveColor(group.color, s);
      child = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? s.onSurface.withValues(alpha: 0.06),
        ),
        child: Icon(
          (group.groupType ?? ExpenseGroupType.other).icon,
          size: size * 0.5,
          color: color == null
              ? s.onSurface
              : ExpenseGroupColorPalette.getContrastingTextColor(color),
        ),
      );
    }
    return ExcludeSemantics(
      child: SizedBox.square(dimension: size, child: child),
    );
  }
}

/// [text] with the first case-insensitive occurrence of [query] highlighted
/// (whole substring, not scattered letters).
class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final int maxLines;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final s = Theme.of(context).colorScheme;
    final q = query.trim().toLowerCase();
    final i = q.isEmpty ? -1 : text.toLowerCase().indexOf(q);
    if (i < 0) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, i)),
          TextSpan(
            text: text.substring(i, i + q.length),
            style: TextStyle(
              backgroundColor: s.primaryContainer,
              color: s.onPrimaryContainer,
            ),
          ),
          TextSpan(text: text.substring(i + q.length)),
        ],
      ),
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
