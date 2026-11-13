import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:material_ui/material_ui.dart';

/// Crops the group photo: a fixed 3:2 frame (the shape the photo has on the
/// group page, close to the Home card's) over the photo, which the user
/// moves by dragging and enlarges by pinching. Below, live previews of the
/// photo on Home, the group page and a Groups card, each melting into the
/// tone the crop gives it.
///
/// Returns the cropped photo, at most [maxSide] px on its long side.
class ImageCropPage extends StatefulWidget {
  final File imageFile;

  /// Width / height of the crop.
  final double aspectRatio;

  /// Longest side of the saved photo, in px.
  final int maxSide;

  const ImageCropPage({
    super.key,
    required this.imageFile,
    this.aspectRatio = 3 / 2,
    this.maxSide = 1600,
  });

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  final _transform = TransformationController();
  ui.Image? _image;

  /// The photo decoded [_thumbWidth] px wide (RGBA), to take the tone of
  /// the crop's lower part as the cards will (see [PhotoTone]).
  ByteData? _thumb;
  int _thumbHeight = 0;
  static const _thumbWidth = 64;

  Size _frame = Size.zero;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _transform.dispose();
    _image?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final bytes = await widget.imageFile.readAsBytes();
    // Decoded by the engine, which applies the EXIF orientation.
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final small = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _thumbWidth,
    );
    final thumb = (await small.getNextFrame()).image;
    final data = await thumb.toByteData(format: ui.ImageByteFormat.rawRgba);
    final thumbHeight = thumb.height;
    thumb.dispose();
    small.dispose();
    if (mounted) {
      setState(() {
        _image = frame.image;
        _thumb = data;
        _thumbHeight = thumbHeight;
      });
    } else {
      frame.image.dispose();
    }
  }

  /// The average color of the lower 45% of [crop] (photo pixels), as
  /// [PhotoTone] measures the saved photo; null before the photo is read.
  Color? _averageOf(Rect crop, ui.Image image) {
    final data = _thumb;
    if (data == null || crop.isEmpty) return null;
    final k = _thumbWidth / image.width;
    final x0 = (crop.left * k).floor().clamp(0, _thumbWidth - 1);
    final x1 = (crop.right * k).ceil().clamp(x0 + 1, _thumbWidth);
    final y0 = ((crop.top + crop.height * 0.55) * k).floor().clamp(
      0,
      _thumbHeight - 1,
    );
    final y1 = (crop.bottom * k).ceil().clamp(y0 + 1, _thumbHeight);
    var r = 0, g = 0, b = 0, n = 0;
    for (var y = y0; y < y1; y++) {
      for (var x = x0; x < x1; x++) {
        final i = (y * _thumbWidth + x) * 4;
        r += data.getUint8(i);
        g += data.getUint8(i + 1);
        b += data.getUint8(i + 2);
        n++;
      }
    }
    return n == 0 ? null : Color.fromARGB(255, r ~/ n, g ~/ n, b ~/ n);
  }

  /// Scale at which the photo just covers the frame.
  double get _coverScale {
    final image = _image!;
    return math.max(_frame.width / image.width, _frame.height / image.height);
  }

  /// The part of the photo inside the frame, in photo pixels.
  Rect get _cropRect {
    final image = _image!;
    final m = _transform.value;
    final zoom = m.getMaxScaleOnAxis();
    final dx = m.storage[12];
    final dy = m.storage[13];
    final toImage = 1 / (_coverScale * zoom);
    final rect = Rect.fromLTWH(
      -dx * toImage,
      -dy * toImage,
      _frame.width * toImage,
      _frame.height * toImage,
    );
    return rect.intersect(
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
    );
  }

  /// Starts with the frame on the middle of the photo.
  void _centre() {
    final image = _image!;
    final s = _coverScale;
    final dx = (_frame.width - image.width * s) / 2;
    final dy = (_frame.height - image.height * s) / 2;
    _transform.value = Matrix4.translationValues(dx, dy, 0);
  }

  Future<void> _save() async {
    if (_saving || _image == null) return;
    setState(() => _saving = true);
    final rect = _cropRect;
    try {
      final out = File('${widget.imageFile.path}_cropped.jpg');
      final jpg = await compute(
        cropAndResize,
        CropRequest(
          path: widget.imageFile.path,
          rect: rect,
          maxSide: widget.maxSide,
        ),
      );
      await out.writeAsBytes(jpg);
      if (mounted) Navigator.of(context).pop(out);
    } catch (e, st) {
      LoggerService.error(
        'Photo crop failed',
        name: 'manager.group',
        error: e,
        stackTrace: st,
      );
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);
    final image = _image;

    return AppSystemUI.edgeToEdge(
      child: Scaffold(
        backgroundColor: s.surfaceContainer,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const RoundBackButton(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        gloc.crop_image_title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (image == null)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final frame = Size(
                        constraints.maxWidth,
                        constraints.maxWidth / widget.aspectRatio,
                      );
                      if (frame != _frame) {
                        _frame = frame;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _centre();
                        });
                      }
                      return _CropFrame(
                        image: image,
                        size: frame,
                        coverScale: _coverScale,
                        controller: _transform,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    gloc.crop_hint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: s.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FormSectionLabel(gloc.crop_preview),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _transform,
                    builder: (context, _) => _frame.isEmpty
                        ? const SizedBox.shrink()
                        : _Previews(
                            image: image,
                            crop: _cropRect,
                            tone: switch (_averageOf(_cropRect, image)) {
                              final c? => PhotoTone.fromAverage(
                                c,
                                theme.brightness,
                              ),
                              null => PhotoTone.fallbackDark,
                            },
                            labels: [
                              gloc.nav_home,
                              gloc.group,
                              gloc.nav_groups,
                            ],
                          ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: _saving
                        ? SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: s.onPrimary,
                            ),
                          )
                        : Text(
                            gloc.crop_use_photo,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: s.onPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The frame: the photo under it moves and zooms, always covering it.
class _CropFrame extends StatelessWidget {
  final ui.Image image;
  final Size size;
  final double coverScale;
  final TransformationController controller;

  const _CropFrame({
    required this.image,
    required this.size,
    required this.coverScale,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    return SizedBox.fromSize(
      size: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: radius,
            child: InteractiveViewer(
              transformationController: controller,
              constrained: false,
              minScale: 1,
              maxScale: 5,
              boundaryMargin: EdgeInsets.zero,
              child: SizedBox(
                width: image.width * coverScale,
                height: image.height * coverScale,
                child: RawImage(image: image, fit: BoxFit.fill),
              ),
            ),
          ),
          // Corner marks; they let the touches through.
          IgnorePointer(
            child: CustomPaint(painter: _CornersPainter(radius: 24)),
          ),
        ],
      ),
    );
  }
}

class _CornersPainter extends CustomPainter {
  final double radius;

  _CornersPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    const len = 22.0;
    final w = size.width;
    final h = size.height;
    final rr = radius;
    final corners = [
      Path()
        ..moveTo(0, rr + len)
        ..lineTo(0, rr)
        ..arcToPoint(Offset(rr, 0), radius: Radius.circular(rr))
        ..lineTo(rr + len, 0),
      Path()
        ..moveTo(w - rr - len, 0)
        ..lineTo(w - rr, 0)
        ..arcToPoint(Offset(w, rr), radius: Radius.circular(rr))
        ..lineTo(w, rr + len),
      Path()
        ..moveTo(w, h - rr - len)
        ..lineTo(w, h - rr)
        ..arcToPoint(Offset(w - rr, h), radius: Radius.circular(rr))
        ..lineTo(w - rr - len, h),
      Path()
        ..moveTo(rr + len, h)
        ..lineTo(rr, h)
        ..arcToPoint(Offset(0, h - rr), radius: Radius.circular(rr))
        ..lineTo(0, h - rr - len),
    ];
    for (final c in corners) {
      canvas.drawPath(c, paint);
    }
  }

  @override
  bool shouldRepaint(_CornersPainter old) => old.radius != radius;
}

/// How the cropped photo will look on Home, on the group page and on a
/// Groups card: the same shape as each card, the photo on top melting into
/// its own [tone] (as the cards take it from the photo), with bars where the
/// title and figures sit in the tone's text color.
class _Previews extends StatelessWidget {
  final ui.Image image;
  final Rect crop;
  final PhotoTone tone;
  final List<String> labels;

  const _Previews({
    required this.image,
    required this.crop,
    required this.tone,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    // Width / height of each card and the share of it the photo covers.
    Widget tile(double aspect, double photo, String label) => Column(
      children: [
        AspectRatio(
          aspectRatio: aspect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: _PreviewPainter(
                image: image,
                crop: crop,
                photoShare: photo,
                tone: tone,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: s.onSurfaceVariant,
          ),
        ),
      ],
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 5, child: tile(368 / 390, 0.62, labels[0])),
        const SizedBox(width: 8),
        Expanded(flex: 5, child: tile(412 / 380, 0.66, labels[1])),
        const SizedBox(width: 8),
        Expanded(flex: 4, child: tile(179 / 170, 0.52, labels[2])),
      ],
    );
  }
}

class _PreviewPainter extends CustomPainter {
  final ui.Image image;
  final Rect crop;
  final double photoShare;
  final PhotoTone tone;

  _PreviewPainter({
    required this.image,
    required this.crop,
    required this.photoShare,
    required this.tone,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (crop.isEmpty) return;
    final card = Offset.zero & size;
    canvas.drawRect(card, Paint()..color = tone.tone);

    // The photo on top, covering its area as Image.file with BoxFit.cover:
    // the middle of the crop in that shape.
    final photo = Rect.fromLTWH(0, 0, size.width, size.height * photoShare);
    final aspect = photo.width / photo.height;
    var src = crop;
    if (crop.width / crop.height > aspect) {
      final w = crop.height * aspect;
      src = Rect.fromLTWH(crop.center.dx - w / 2, crop.top, w, crop.height);
    } else {
      final h = crop.width / aspect;
      src = Rect.fromLTWH(crop.left, crop.center.dy - h / 2, crop.width, h);
    }
    canvas.drawImageRect(
      image,
      src,
      photo,
      Paint()..filterQuality = FilterQuality.medium,
    );

    // Melting into the tone, as PhotoBand does.
    final fade = photo.height * 0.42;
    final fadeRect = Rect.fromLTWH(
      0,
      photo.bottom - fade,
      size.width,
      fade + 1,
    );
    canvas.drawRect(
      fadeRect,
      Paint()
        ..shader = PhotoBandGradient.smooth(
          tone.tone,
          fadeRect.height,
        ).createShader(fadeRect),
    );

    // Title, dates and figures at the bottom, in the tone's text color.
    final bar = Paint()..color = tone.onTone.withValues(alpha: 0.55);
    final left = size.width * 0.08;
    final unit = math.max(2.0, size.height * 0.03);
    final bottom = size.height - size.height * 0.09;
    // (top from the bottom, height, width share) of each line.
    for (final (y, h, w) in [
      (unit * 6.2, unit * 1.4, 0.55),
      (unit * 4.1, unit * 0.8, 0.34),
      (unit * 1.6, unit * 1.6, 0.42),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, bottom - y, size.width * w, h),
          Radius.circular(h / 2),
        ),
        bar,
      );
    }
  }

  @override
  bool shouldRepaint(_PreviewPainter old) =>
      old.crop != crop ||
      old.image != image ||
      old.photoShare != photoShare ||
      old.tone.tone != tone.tone;
}

/// What [cropAndResize] crops: the photo file, the part to keep in photo
/// pixels (as shown, i.e. after EXIF orientation) and the longest side.
class CropRequest {
  final String path;
  final Rect rect;
  final int maxSide;

  const CropRequest({
    required this.path,
    required this.rect,
    required this.maxSide,
  });
}

/// Crops the photo to [CropRequest.rect], scales it down so its longest side
/// is at most [CropRequest.maxSide] px, and encodes it as JPEG (quality 85).
/// Runs in an isolate: decoding a camera photo takes a while.
Future<Uint8List> cropAndResize(CropRequest request) async {
  final bytes = await File(request.path).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw const FormatException('Unreadable photo');
  final photo = img.bakeOrientation(decoded);
  final r = request.rect;
  final x = r.left.round().clamp(0, photo.width - 1);
  final y = r.top.round().clamp(0, photo.height - 1);
  final w = r.width.round().clamp(1, photo.width - x);
  final h = r.height.round().clamp(1, photo.height - y);
  var cropped = img.copyCrop(photo, x: x, y: y, width: w, height: h);
  final longest = math.max(cropped.width, cropped.height);
  if (longest > request.maxSide) {
    cropped = cropped.width >= cropped.height
        ? img.copyResize(
            cropped,
            width: request.maxSide,
            interpolation: img.Interpolation.average,
          )
        : img.copyResize(
            cropped,
            height: request.maxSide,
            interpolation: img.Interpolation.average,
          );
  }
  return img.encodeJpg(cropped, quality: 85);
}
