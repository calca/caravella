import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageCropPage extends StatefulWidget {
  final File imageFile;
  final double aspectRatio;
  const ImageCropPage(
      {super.key, required this.imageFile, this.aspectRatio = 2 / 3});

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  late img.Image _decodedImage;
  bool _loading = true;
  Rect? _cropRectDisplay; // crop rect in display coordinates
  Size? _imageDisplaySize; // displayed image size
  double? _scale; // image pixel / display pixel

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    _decodedImage = img.decodeImage(bytes)!;
    setState(() {
      _loading = false;
    });
  }

  void _initCropRect(Size displaySize) {
    // Calcola il massimo crop 2:3 centrato nell'immagine visualizzata
    final aspect = widget.aspectRatio;
    double cropW = displaySize.width * 0.8;
    double cropH = cropW / aspect;
    if (cropH > displaySize.height * 0.8) {
      cropH = displaySize.height * 0.8;
      cropW = cropH * aspect;
    }
    final left = (displaySize.width - cropW) / 2;
    final top = (displaySize.height - cropH) / 2;
    _cropRectDisplay = Rect.fromLTWH(left, top, cropW, cropH);
  }

  // Drag crop area (move)
  void _onPanUpdate(DragUpdateDetails details) {
    if (_cropRectDisplay == null || _imageDisplaySize == null) return;
    final dx = details.delta.dx;
    final dy = details.delta.dy;
    double newLeft = _cropRectDisplay!.left + dx;
    double newTop = _cropRectDisplay!.top + dy;
    // Clamp to image bounds
    newLeft =
        newLeft.clamp(0.0, _imageDisplaySize!.width - _cropRectDisplay!.width);
    newTop =
        newTop.clamp(0.0, _imageDisplaySize!.height - _cropRectDisplay!.height);
    setState(() {
      _cropRectDisplay = Rect.fromLTWH(
          newLeft, newTop, _cropRectDisplay!.width, _cropRectDisplay!.height);
    });
  }

  // Resize crop area from a corner, keeping aspect ratio
  void _onResize(DragUpdateDetails details,
      {required bool fromLeft, required bool fromTop}) {
    if (_cropRectDisplay == null || _imageDisplaySize == null) return;
    double dx = details.delta.dx * (fromLeft ? -1 : 1);
    double dy = details.delta.dy * (fromTop ? -1 : 1);
    // Use the greater movement to resize, keeping aspect ratio
    double delta = dx.abs() > dy.abs() ? dx : dy;
    double newWidth =
        (_cropRectDisplay!.width + delta).clamp(60.0, _imageDisplaySize!.width);
    double newHeight = newWidth / widget.aspectRatio;
    if (newHeight > _imageDisplaySize!.height) {
      newHeight = _imageDisplaySize!.height;
      newWidth = newHeight * widget.aspectRatio;
    }
    double newLeft = fromLeft
        ? (_cropRectDisplay!.right - newWidth)
        : _cropRectDisplay!.left;
    double newTop = fromTop
        ? (_cropRectDisplay!.bottom - newHeight)
        : _cropRectDisplay!.top;
    // Clamp to image bounds
    if (newLeft < 0) newLeft = 0;
    if (newTop < 0) newTop = 0;
    if (newLeft + newWidth > _imageDisplaySize!.width)
      newLeft = _imageDisplaySize!.width - newWidth;
    if (newTop + newHeight > _imageDisplaySize!.height)
      newTop = _imageDisplaySize!.height - newHeight;
    setState(() {
      _cropRectDisplay = Rect.fromLTWH(newLeft, newTop, newWidth, newHeight);
    });
  }

  Future<void> _cropAndReturn() async {
    if (_cropRectDisplay == null || _scale == null) return;
    // Converti cropRect da display a pixel immagine
    final crop = img.copyCrop(
      _decodedImage,
      x: (_cropRectDisplay!.left * _scale!).round(),
      y: (_cropRectDisplay!.top * _scale!).round(),
      width: (_cropRectDisplay!.width * _scale!).round(),
      height: (_cropRectDisplay!.height * _scale!).round(),
    );
    final croppedFile = File('${widget.imageFile.path}_cropped.jpg');
    await croppedFile.writeAsBytes(img.encodeJpg(crop, quality: 85));
    if (mounted) Navigator.of(context).pop(croppedFile);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ritaglia immagine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _cropAndReturn,
            tooltip: 'Conferma',
          ),
        ],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcola la dimensione massima per l'immagine mantenendo il rapporto
            final imgW = _decodedImage.width.toDouble();
            final imgH = _decodedImage.height.toDouble();
            final maxW = constraints.maxWidth;
            final maxH = constraints.maxHeight;
            double displayW = maxW;
            double displayH = displayW * imgH / imgW;
            if (displayH > maxH) {
              displayH = maxH;
              displayW = displayH * imgW / imgH;
            }
            final scale = imgW / displayW;
            _scale = scale;
            _imageDisplaySize = Size(displayW, displayH);
            if (_cropRectDisplay == null) {
              _initCropRect(_imageDisplaySize!);
            }
            return SizedBox(
              width: displayW,
              height: displayH,
              child: Stack(
                children: [
                  Image.file(
                    widget.imageFile,
                    width: displayW,
                    height: displayH,
                    fit: BoxFit.contain,
                  ),
                  if (_cropRectDisplay != null) ...[
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _CropOverlayPainter(_cropRectDisplay!),
                        ),
                      ),
                    ),
                    Positioned(
                      left: _cropRectDisplay!.left,
                      top: _cropRectDisplay!.top,
                      child: GestureDetector(
                        onPanUpdate: _onPanUpdate,
                        child: Container(
                          width: _cropRectDisplay!.width,
                          height: _cropRectDisplay!.height,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.blueAccent, width: 2),
                            color:
                                Colors.transparent, // area interna trasparente
                          ),
                          child: Stack(
                            children: [
                              // Handle angolo in alto a sinistra
                              Positioned(
                                left: 0,
                                top: 0,
                                child: _CornerHandle(
                                  onPanUpdate: (details) => _onResize(details,
                                      fromLeft: true, fromTop: true),
                                ),
                              ),
                              // Handle angolo in alto a destra
                              Positioned(
                                right: 0,
                                top: 0,
                                child: _CornerHandle(
                                  onPanUpdate: (details) => _onResize(details,
                                      fromLeft: false, fromTop: true),
                                ),
                              ),
                              // Handle angolo in basso a sinistra
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: _CornerHandle(
                                  onPanUpdate: (details) => _onResize(details,
                                      fromLeft: true, fromTop: false),
                                ),
                              ),
                              // Handle angolo in basso a destra
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: _CornerHandle(
                                  onPanUpdate: (details) => _onResize(details,
                                      fromLeft: false, fromTop: false),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CornerHandle extends StatelessWidget {
  final void Function(DragUpdateDetails) onPanUpdate;
  const _CornerHandle({Key? key, required this.onPanUpdate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: onPanUpdate,
      child: Padding(
        padding: const EdgeInsets.all(3), // distanza dal bordo esterno
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  _CropOverlayPainter(this.cropRect);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.5);
    // Usa saveLayer per abilitare BlendMode.clear su tutte le piattaforme
    canvas.saveLayer(Offset.zero & size, Paint());
    // Area piena scura
    canvas.drawRect(Offset.zero & size, paint);
    // Area di crop "trasparente"
    paint.blendMode = BlendMode.clear;
    canvas.drawRect(cropRect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
