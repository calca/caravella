import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImageCropPage extends StatefulWidget {
  final File imageFile;
  final double aspectRatio;
  const ImageCropPage(
      {super.key, required this.imageFile, this.aspectRatio = 3 / 2});

  @override
  State<ImageCropPage> createState() => _ImageCropPageState();
}

class _ImageCropPageState extends State<ImageCropPage> {
  Rect? cropRect;
  late double _imageWidth;
  late double _imageHeight;
  late img.Image _decodedImage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    _decodedImage = img.decodeImage(bytes)!;
    _imageWidth = _decodedImage.width.toDouble();
    _imageHeight = _decodedImage.height.toDouble();
    final cropW = _imageWidth;
    final cropH = cropW / widget.aspectRatio;
    setState(() {
      cropRect = Rect.fromLTWH(0, (_imageHeight - cropH) / 2, cropW, cropH);
      _loading = false;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (cropRect == null) return;
    final dy = details.delta.dy;
    final newTop =
        (cropRect!.top + dy).clamp(0.0, _imageHeight - cropRect!.height);
    setState(() {
      cropRect = Rect.fromLTWH(
          cropRect!.left, newTop, cropRect!.width, cropRect!.height);
    });
  }

  Future<void> _cropAndReturn() async {
    if (cropRect == null) return;
    final crop = img.copyCrop(
      _decodedImage,
      x: cropRect!.left.round(),
      y: cropRect!.top.round(),
      width: cropRect!.width.round(),
      height: cropRect!.height.round(),
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
        child: GestureDetector(
          onPanUpdate: _onPanUpdate,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(widget.imageFile),
              if (cropRect != null)
                Positioned(
                  left: cropRect!.left,
                  top: cropRect!.top,
                  child: Container(
                    width: cropRect!.width,
                    height: cropRect!.height,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent, width: 2),
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
