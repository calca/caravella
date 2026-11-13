import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';

/// How a group card is painted, from the group's palette color (or none)
/// and the theme: the whole card in [tint] (the palette color softened
/// towards the page, or neutral grey without one), text in [onTint] (a deep
/// shade of the same hue) and the big type icon in [mark].
///
/// Every [onTint] keeps at least 4.5:1 on its [tint] (WCAG AA; tested for
/// all twelve palette colors in both themes).
class GroupLook {
  final Color tint;
  final Color onTint;
  final Color mark;

  const GroupLook({
    required this.tint,
    required this.onTint,
    required this.mark,
  });

  static const _noneLight = Color(0xFFE4E5E8);
  static const _noneDark = Color(0xFF2A2B2E);
  static const _darkPage = Color(0xFF121212);

  /// The look for [color] (a resolved palette or legacy color; null: none).
  static GroupLook of(Color? color, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    if (color == null) {
      return GroupLook(
        tint: dark ? _noneDark : _noneLight,
        onTint: dark ? const Color(0xFFEDEDED) : const Color(0xFF1B1B1B),
        mark: (dark ? Colors.white : Colors.black).withValues(alpha: 0.07),
      );
    }
    final hsl = HSLColor.fromColor(color);
    final onTint = hsl
        .withSaturation(hsl.saturation.clamp(0.0, 0.5))
        .withLightness(dark ? 0.9 : 0.15)
        .toColor();
    return GroupLook(
      tint: dark
          ? Color.lerp(color, _darkPage, 0.45)!
          : Color.lerp(color, Colors.white, 0.45)!,
      onTint: onTint,
      mark: onTint.withValues(alpha: dark ? 0.08 : 0.10),
    );
  }

  /// The group's resolved color, or null without one.
  static Color? colorOf(ExpenseGroup group, ColorScheme s) {
    if (group.color == null) return null;
    return ExpenseGroupColorPalette.isLegacyColorValue(group.color)
        ? Color(group.color!)
        : ExpenseGroupColorPalette.resolveColor(group.color, s);
  }

  /// The group's photo, when it has one that still exists.
  static String? photoOf(ExpenseGroup group) {
    final file = group.file;
    return file != null && file.isNotEmpty && File(file).existsSync()
        ? file
        : null;
  }

  /// WCAG contrast ratio between two opaque colors.
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }
}

/// The tone a style B card takes under a photo: the average color of the
/// photo's lower part, made very dark (white text) or, for a light photo in
/// the light theme, very light (dark text). Computed once per photo from a
/// small decode, kept in memory and, through [onChanged], between launches.
class PhotoTone {
  final Color tone;
  final Color onTone;

  const PhotoTone(this.tone, this.onTone);

  static const fallbackDark = PhotoTone(Color(0xFF1F2532), Colors.white);

  /// Keyed by [_key]: the path and the file's modification time, so a photo
  /// replaced at the same path is measured again.
  static final Map<String, Color> _averages = {};
  static final Map<String, Future<Color?>> _pending = {};

  /// Called with every measured photo (key → ARGB) after a new one, for the
  /// app to store; [seed] gives them back at the next launch, so cards
  /// show their tone from the first frame.
  static void Function(Map<String, int> all)? onChanged;

  static void seed(Map<String, int> stored) {
    for (final e in stored.entries) {
      _averages.putIfAbsent(e.key, () => Color(e.value));
    }
  }

  static String? _key(String path) {
    try {
      return '$path@${File(path).lastModifiedSync().millisecondsSinceEpoch}';
    } catch (_) {
      return null;
    }
  }

  /// Measures the photos not measured yet, one at a time (at startup, so
  /// the cards don't wait for them).
  static Future<void> warmUp(Iterable<String> paths) async {
    for (final path in paths) {
      await load(path, Brightness.dark);
    }
  }

  /// The tone for [average] (the photo's lower part) in [brightness].
  static PhotoTone fromAverage(Color average, Brightness brightness) {
    final hsl = HSLColor.fromColor(average);
    final light =
        brightness == Brightness.light && average.computeLuminance() > 0.4;
    if (light) {
      return PhotoTone(
        hsl
            .withSaturation(hsl.saturation.clamp(0.0, 0.25))
            .withLightness(0.91)
            .toColor(),
        const Color(0xFF1B1B1B),
      );
    }
    return PhotoTone(
      hsl
          .withSaturation(hsl.saturation.clamp(0.0, 0.3))
          .withLightness(0.15)
          .toColor(),
      Colors.white,
    );
  }

  /// The cached tone of [path], or null until [load] has run for it.
  static PhotoTone? cached(String path, Brightness brightness) {
    final key = _key(path);
    final average = key == null ? null : _averages[key];
    return average == null ? null : fromAverage(average, brightness);
  }

  /// Averages the lower 45% of the photo at [path] (decoded 24 px wide).
  static Future<PhotoTone?> load(String path, Brightness brightness) async {
    final key = _key(path);
    if (key == null) return null;
    final known = _averages[key];
    if (known != null) return fromAverage(known, brightness);
    final average = await (_pending[key] ??= _average(path).whenComplete(() {
      // A block: returning the removed future would wait on itself.
      _pending.remove(key);
    }));
    if (average == null) return null;
    if (_averages[key] == null) {
      _averages[key] = average;
      onChanged?.call({
        for (final e in _averages.entries) e.key: e.value.toARGB32(),
      });
    }
    return fromAverage(average, brightness);
  }

  static Future<Color?> _average(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 24);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final width = image.width;
      final height = image.height;
      image.dispose();
      codec.dispose();
      if (data == null || width == 0 || height == 0) return null;
      var r = 0, g = 0, b = 0, n = 0;
      for (var y = (height * 0.55).floor(); y < height; y++) {
        for (var x = 0; x < width; x++) {
          final i = (y * width + x) * 4;
          r += data.getUint8(i);
          g += data.getUint8(i + 1);
          b += data.getUint8(i + 2);
          n++;
        }
      }
      if (n == 0) return null;
      return Color.fromARGB(255, r ~/ n, g ~/ n, b ~/ n);
    } catch (e) {
      LoggerService.warning('Photo tone not computed: $e', name: 'ui.card');
      return null;
    }
  }
}

/// Builds with the [PhotoTone] of [path], loading it the first time (the
/// dark fallback shows meanwhile, without flashing on later builds).
class PhotoToneBuilder extends StatefulWidget {
  final String path;
  final Widget Function(BuildContext context, PhotoTone tone) builder;

  const PhotoToneBuilder({
    super.key,
    required this.path,
    required this.builder,
  });

  @override
  State<PhotoToneBuilder> createState() => _PhotoToneBuilderState();
}

class _PhotoToneBuilderState extends State<PhotoToneBuilder> {
  String? _loading;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final tone = PhotoTone.cached(widget.path, brightness);
    if (tone == null && _loading != widget.path) {
      _loading = widget.path;
      unawaited(
        PhotoTone.load(widget.path, brightness).then((_) {
          if (mounted) setState(() {});
        }),
      );
    }
    return widget.builder(context, tone ?? PhotoTone.fallbackDark);
  }
}

/// A photo filling the top [photoHeight] of its box and melting into
/// [tone] below (style B), no dark veil.
class PhotoBand extends StatelessWidget {
  final String path;
  final Color tone;
  final double photoHeight;

  const PhotoBand({
    super.key,
    required this.path,
    required this.tone,
    required this.photoHeight,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth.isFinite ? constraints.maxWidth : null;
      final fade = photoHeight * 0.42;
      return Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: tone),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: photoHeight,
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              cacheWidth: width == null
                  ? null
                  : (width * MediaQuery.devicePixelRatioOf(context)).round(),
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
              // Decoded off the first frame: the tone shows at once and the
              // photo fades in over it, instead of popping in late.
              frameBuilder: (context, child, frame, sync) => sync
                  ? child
                  : AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      child: child,
                    ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: photoHeight - fade,
            height: fade + 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: PhotoVeilGradient.smooth(tone, fade + 1),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Smoothstep gradient from clear to [color] over [height].
abstract final class PhotoVeilGradient {
  static LinearGradient smooth(Color color, double height) {
    const steps = 8;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        for (var i = 0; i <= steps; i++)
          color.withValues(alpha: _ease(i / steps)),
      ],
      stops: [for (var i = 0; i <= steps; i++) i / steps],
    );
  }

  static double _ease(double t) => t * t * (3 - 2 * t);
}

/// The group type's icon drawn large and faint, cropped by the card's
/// corner: [size] is the glyph's width, [overflow] the share of it outside
/// the card on the right and above [top] (the card's top by default).
///
/// Glyphs don't fill their 24-unit box the same way (a person is narrower
/// than a plane), so each is measured to its own outline: every type is
/// cropped by the same amount.
class TypeMark extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final double overflow;

  const TypeMark({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
    this.overflow = 0.3,
  });

  /// Left, top and width of each glyph's outline in its 24-unit box.
  static (double, double, double) glyphBox(IconData icon) {
    if (icon == Icons.flight_takeoff) return (2.5, 3.5, 19.6);
    if (icon == Icons.person) return (4, 4, 16);
    if (icon == Icons.family_restroom) return (2, 2, 20);
    if (icon == Icons.widgets_outlined) return (3, 1.69, 19.3);
    return (2, 2, 20);
  }

  /// Positions the mark in a [Stack] covering the card: cropped at its
  /// top-right corner, or [top] below it.
  Widget positioned({double top = 0}) {
    final (x, y, w) = glyphBox(icon);
    final unit = size / w;
    return Positioned(
      right: -overflow * size - (24 - x - w) * unit,
      top: top - overflow * size - y * unit,
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final (_, _, w) = glyphBox(icon);
    return ExcludeSemantics(
      child: Icon(icon, size: size * 24 / w, color: color),
    );
  }
}

/// The chip on a group card: an optional heart (favorite), the type icon and
/// an optional [label] (the type's name), on a translucent pill.
class TypeChip extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool favorite;

  /// The type's name for screen readers when no [label] shows.
  final String? semanticLabel;

  final double height;

  const TypeChip({
    super.key,
    required this.icon,
    this.label,
    this.favorite = false,
    this.semanticLabel,
    this.height = 30,
  });

  static Color background(Brightness b) =>
      b == Brightness.dark ? const Color(0xB8121212) : const Color(0xD9FFFFFF);

  static Color foreground(Brightness b) =>
      b == Brightness.dark ? const Color(0xFFEDEDED) : const Color(0xFF1B1B1B);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = foreground(theme.brightness);
    final iconSize = height * 0.53;
    final text = label;
    return Semantics(
      label: text ?? semanticLabel,
      excludeSemantics: true,
      child: Container(
        constraints: BoxConstraints(minHeight: height, minWidth: height),
        padding: EdgeInsets.symmetric(
          horizontal: text == null ? height * 0.23 : 10,
        ),
        decoration: BoxDecoration(
          color: background(theme.brightness),
          borderRadius: BorderRadius.circular(height),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (favorite) ...[
              Icon(Icons.favorite_rounded, size: iconSize, color: fg),
              SizedBox(width: height * 0.15),
            ],
            Icon(icon, size: iconSize, color: fg),
            if (text != null) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
