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
/// photo on Home, the group page and a Groups card.
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
    if (mounted) {
      setState(() => _image = frame.image);
    } else {
      frame.image.dispose();
    }
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

/// How the cropped photo will look: on Home, on the group page and on a
/// Groups card, each melting into the surface like the real ones.
class _Previews extends StatelessWidget {
  final ui.Image image;
  final Rect crop;
  final List<String> labels;

  const _Previews({
    required this.image,
    required this.crop,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    Widget tile(double aspect, Color surface, String label) => Column(
      children: [
        AspectRatio(
          aspectRatio: aspect,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomPaint(
              painter: _PreviewPainter(image: image, crop: crop, fade: surface),
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
        Expanded(flex: 5, child: tile(1.7, s.surface, labels[0])),
        const SizedBox(width: 8),
        Expanded(flex: 4, child: tile(1.25, s.surfaceContainer, labels[1])),
        const SizedBox(width: 8),
        Expanded(flex: 3, child: tile(0.82, s.raisedSurface, labels[2])),
      ],
    );
  }
}

class _PreviewPainter extends CustomPainter {
  final ui.Image image;
  final Rect crop;
  final Color fade;

  _PreviewPainter({
    required this.image,
    required this.crop,
    required this.fade,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (crop.isEmpty) return;
    // Cover: the middle of the crop in this tile's shape.
    final aspect = size.width / size.height;
    var src = crop;
    if (crop.width / crop.height > aspect) {
      final w = crop.height * aspect;
      src = Rect.fromLTWH(crop.center.dx - w / 2, crop.top, w, crop.height);
    } else {
      final h = crop.width / aspect;
      src = Rect.fromLTWH(crop.left, crop.center.dy - h / 2, crop.width, h);
    }
    final dst = Offset.zero & size;
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
    canvas.drawRect(
      dst,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fade.withValues(alpha: 0), fade],
          stops: const [0.45, 1],
        ).createShader(dst),
    );
  }

  @override
  bool shouldRepaint(_PreviewPainter old) =>
      old.crop != crop || old.image != image || old.fade != fade;
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
