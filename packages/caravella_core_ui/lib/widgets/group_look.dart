import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:caravella_core/caravella_core.dart';
import 'package:material_ui/material_ui.dart';

/// The two group card styles being compared on device (Settings ›
/// Appearance › Card style):
/// - [a] "clean cover": the photo, color or neutral grey in a rounded cover
///   on top, the text below it on the card surface;
/// - [b] "full tint": the whole card in a soft tint of the group color (or
///   the photo's own tone under the photo), the text on it.
enum GroupCardStyle {
  a,
  b;

  static GroupCardStyle parse(String? value) =>
      value == 'b' ? GroupCardStyle.b : GroupCardStyle.a;

  /// The style every card follows; set from preferences at startup and by
  /// the setting.
  static final ValueNotifier<GroupCardStyle> current = ValueNotifier(
    GroupCardStyle.a,
  );
}

/// Rebuilds [builder] when the card style changes.
class GroupCardStyleBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, GroupCardStyle style) builder;

  const GroupCardStyleBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<GroupCardStyle>(
    valueListenable: GroupCardStyle.current,
    builder: (context, style, _) => builder(context, style),
  );
}

/// How a group is painted, from its palette color (or none) and the theme.
///
/// - [cover] and [coverMark]: style A's cover (the palette color as is, or
///   neutral grey) and the big type icon on it.
/// - [tint], [onTint] and [tintMark]: style B's background (the palette
///   color softened towards the page), its text color and big icon.
///
/// Every [onTint] keeps at least 4.5:1 on its [tint] (WCAG AA; tested for
/// all twelve palette colors in both themes).
class GroupLook {
  final Color cover;
  final Color coverMark;
  final Color tint;
  final Color onTint;
  final Color tintMark;

  const GroupLook({
    required this.cover,
    required this.coverMark,
    required this.tint,
    required this.onTint,
    required this.tintMark,
  });

  static const _noneLight = Color(0xFFECEDEF);
  static const _noneDark = Color(0xFF2A2B2E);
  static const _noneTintLight = Color(0xFFE4E5E8);
  static const _darkPage = Color(0xFF121212);

  /// The look for [color] (a resolved palette or legacy color; null: none).
  static GroupLook of(Color? color, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    if (color == null) {
      return GroupLook(
        cover: dark ? _noneDark : _noneLight,
        coverMark: (dark ? Colors.white : Colors.black).withValues(alpha: 0.07),
        tint: dark ? _noneDark : _noneTintLight,
        onTint: dark ? const Color(0xFFEDEDED) : const Color(0xFF1B1B1B),
        tintMark: (dark ? Colors.white : Colors.black).withValues(alpha: 0.07),
      );
    }
    final hsl = HSLColor.fromColor(color);
    final saturation = hsl.saturation.clamp(0.0, 0.5);
    final onTint = hsl
        .withSaturation(saturation)
        .withLightness(dark ? 0.9 : 0.15)
        .toColor();
    final tint = dark
        ? Color.lerp(color, _darkPage, 0.45)!
        : Color.lerp(color, Colors.white, 0.45)!;
    return GroupLook(
      cover: color,
      coverMark: dark
          ? Colors.white.withValues(alpha: 0.10)
          : hsl
                .withSaturation(saturation)
                .withLightness(0.2)
                .toColor()
                .withValues(alpha: 0.14),
      tint: tint,
      onTint: onTint,
      tintMark: onTint.withValues(alpha: dark ? 0.08 : 0.10),
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
/// small decode and kept in memory.
class PhotoTone {
  final Color tone;
  final Color onTone;

  const PhotoTone(this.tone, this.onTone);

  static const fallbackDark = PhotoTone(Color(0xFF1F2532), Colors.white);

  static final Map<String, Color> _averages = {};
  static final Map<String, Future<Color?>> _pending = {};

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
    final average = _averages[path];
    return average == null ? null : fromAverage(average, brightness);
  }

  /// Averages the lower 45% of the photo at [path] (decoded 24 px wide).
  static Future<PhotoTone?> load(String path, Brightness brightness) async {
    final average =
        _averages[path] ??
        await (_pending[path] ??= _average(path).whenComplete(() {
          // A block: returning the removed future would wait on itself.
          _pending.remove(path);
        }));
    if (average == null) return null;
    _averages[path] = average;
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
