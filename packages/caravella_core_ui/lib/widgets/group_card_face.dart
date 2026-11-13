import 'dart:io';

import 'package:material_ui/material_ui.dart';

import 'currency_display.dart';
import 'group_look.dart';

/// What a group looks like on its card: background, type chip, name, a line
/// below it and the total. Shared by the Groups page (grid tiles) and the
/// creation wizard's preview (the [wide] card), so a new group looks the
/// same before and after saving. The caller adds the outline, the clipping
/// and any tap.
///
/// The whole card is in the group's tint ([GroupLook]: neutral grey without
/// a color) with the big faint type icon cropped by the corner, or under a
/// photo the photo's own tone ([PhotoTone]) that it melts into; the type
/// chip on top and the text at the bottom.
class GroupCardFace extends StatelessWidget {
  final String title;

  /// The line under the name.
  final String? subtitle;

  final double total;
  final String currency;

  /// The group's photo; [color] shows when there's none or it can't be found.
  final String? photoPath;
  final Color? color;

  final IconData icon;

  /// The type's name, read by screen readers on the chip.
  final String? typeLabel;

  /// A heart before the type icon on the chip.
  final bool favorite;

  /// The wide card (wizard) instead of a grid tile.
  final bool wide;

  /// The wide card at [compactHeight]: same text, smaller cover and margins.
  final bool compact;

  const GroupCardFace({
    super.key,
    required this.title,
    required this.total,
    required this.currency,
    required this.icon,
    this.subtitle,
    this.photoPath,
    this.color,
    this.typeLabel,
    this.favorite = false,
    this.wide = false,
    this.compact = false,
  });

  static const double wideHeight = 196;
  static const double compactHeight = 120;

  /// Grid tile height at the default text size; the text part grows with it.
  static double tileHeight(TextScaler scaler) => 108 + scaler.scale(62);

  static BorderRadius borderRadiusFor({required bool wide}) =>
      BorderRadius.circular(wide ? 28 : 24);

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    final photo = path != null && path.isNotEmpty && File(path).existsSync()
        ? path
        : null;
    if (photo == null) {
      final look = GroupLook.of(color, Theme.of(context).brightness);
      return _build(context, null, look.tint, look.onTint, look.mark);
    }
    return PhotoToneBuilder(
      path: photo,
      builder: (context, tone) =>
          _build(context, photo, tone.tone, tone.onTone, null),
    );
  }

  Widget _chip(BuildContext context) => TypeChip(
    icon: icon,
    favorite: favorite,
    semanticLabel: typeLabel,
    height: wide && !compact ? 30 : 26,
  );

  Widget _text(BuildContext context, Color fg) {
    final theme = Theme.of(context);
    final fgSecondary = fg.withValues(alpha: 0.8);
    final line = subtitle;
    final amount = CurrencyDisplay(
      value: total,
      currency: currency,
      valueFontSize: wide ? 24 : 18,
      currencyFontSize: wide ? 14 : 12,
      alignment: wide ? MainAxisAlignment.end : MainAxisAlignment.start,
      showDecimals: true,
      color: fg,
    );
    final name = Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: (wide ? theme.textTheme.titleLarge : theme.textTheme.titleMedium)
          ?.copyWith(color: fg, fontWeight: FontWeight.w700, height: 1.15),
    );
    final sub = line == null
        ? null
        : Text(
            line,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                (wide ? theme.textTheme.bodyMedium : theme.textTheme.bodySmall)
                    ?.copyWith(color: fgSecondary),
          );
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [name, ?sub],
            ),
          ),
          const SizedBox(width: 12),
          amount,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [name, ?sub, const SizedBox(height: 2), amount],
    );
  }

  Widget _build(
    BuildContext context,
    String? photo,
    Color background,
    Color fg,
    Color? mark,
  ) {
    final padding = wide ? (compact ? 12.0 : 16.0) : 12.0;
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        fit: StackFit.expand,
        children: [
          if (photo != null)
            PhotoBand(
              path: photo,
              tone: background,
              photoHeight: wide
                  ? constraints.maxHeight * 0.62
                  : constraints.maxHeight * 0.52,
            )
          else
            ColoredBox(color: background),
          if (mark != null)
            TypeMark(
              icon: icon,
              size: wide ? (compact ? 90 : 150) : 76,
              color: mark,
            ).positioned(),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_chip(context), const Spacer(), _text(context, fg)],
            ),
          ),
        ],
      ),
    );
  }
}
