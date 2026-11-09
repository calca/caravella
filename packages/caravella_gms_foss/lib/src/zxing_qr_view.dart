import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zxing2/qrcode.dart';

/// Live camera QR scanner for the F-Droid build, with no Google libraries:
/// the `camera` plugin (CameraX) for the preview and frames, and `zxing2`
/// (a pure Dart port of ZXing) to decode them off the UI isolate.
///
/// Same contract as the Play build's scanner: reports every decoded value
/// through [onDetect], and stops looking at frames while [paused].
class ZxingQrView extends StatefulWidget {
  final ValueChanged<String> onDetect;
  final bool paused;

  const ZxingQrView({super.key, required this.onDetect, this.paused = false});

  @override
  State<ZxingQrView> createState() => _ZxingQrViewState();
}

class _ZxingQrViewState extends State<ZxingQrView> with WidgetsBindingObserver {
  /// At most one frame is decoded at a time, and no more often than this:
  /// plenty for a code held still in front of the camera, and it keeps the
  /// phone cool.
  static const _minInterval = Duration(milliseconds: 200);

  CameraController? _controller;
  bool _failed = false;
  bool _decoding = false;
  DateTime _lastDecode = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Release the camera while the app is in the background.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _stop();
    } else if (state == AppLifecycleState.resumed && _controller == null) {
      _start();
    }
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw CameraException('none', 'No camera');
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await controller.startImageStream(_onFrame);
      setState(() {
        _controller = controller;
        _failed = false;
      });
    } catch (_) {
      // Permission denied or no usable camera: the page around this view
      // keeps its own instructions and the Bluetooth path.
      if (mounted) setState(() => _failed = true);
    }
  }

  Future<void> _stop() async {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    if (mounted) setState(() {});
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {}
    await controller.dispose();
  }

  void _onFrame(CameraImage image) {
    if (widget.paused || _decoding) return;
    final now = DateTime.now();
    if (now.difference(_lastDecode) < _minInterval) return;
    _lastDecode = now;
    _decoding = true;
    final plane = image.planes.first;
    // The plugin reuses the frame buffer: copy the luminance plane before
    // handing it to another isolate.
    final frame = QrFrame(
      Uint8List.fromList(plane.bytes),
      image.width,
      image.height,
      plane.bytesPerRow,
    );
    compute(decodeQrFrame, frame)
        .then((text) {
          if (text != null && mounted && !widget.paused) {
            widget.onDetect(text);
          }
        })
        .whenComplete(() => _decoding = false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed || controller == null || !controller.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }
    // previewSize is in landscape sensor terms; the app is portrait-only.
    final size = controller.value.previewSize!;
    return ColoredBox(
      color: Colors.black,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.height,
            height: size.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

/// One camera frame's luminance (Y) plane, as sent to the decoding isolate.
@visibleForTesting
class QrFrame {
  final Uint8List luminance;
  final int width;
  final int height;

  /// Bytes per row in [luminance], which can be more than [width].
  final int rowStride;

  const QrFrame(this.luminance, this.width, this.height, this.rowStride);
}

/// Decodes the QR code in [frame], or `null` when there is none (most
/// frames). Runs in a background isolate.
@visibleForTesting
String? decodeQrFrame(QrFrame frame) {
  final source = _LuminancePlane(frame);
  for (final bitmap in [
    BinaryBitmap(HybridBinarizer(source)),
    // A code shown light-on-dark, e.g. a phone in dark mode.
    BinaryBitmap(HybridBinarizer(source.invert())),
  ]) {
    try {
      return QRCodeReader().decode(bitmap).text;
    } on ReaderException {
      // Nothing readable this way; try the next one.
    }
  }
  return null;
}

/// A [LuminanceSource] reading a camera Y plane in place, honouring its row
/// stride.
class _LuminancePlane extends LuminanceSource {
  _LuminancePlane(this._frame) : super(_frame.width, _frame.height);

  final QrFrame _frame;

  @override
  Int8List getRow(int y, Int8List? row) {
    if (row == null || row.length < width) row = Int8List(width);
    final start = y * _frame.rowStride;
    final bytes = _frame.luminance;
    for (var x = 0; x < width; x++) {
      row[x] = bytes[start + x];
    }
    return row;
  }

  @override
  Int8List getMatrix() {
    final bytes = _frame.luminance;
    if (_frame.rowStride == width) {
      return Int8List.view(bytes.buffer, bytes.offsetInBytes, width * height);
    }
    final matrix = Int8List(width * height);
    for (var y = 0; y < height; y++) {
      final from = y * _frame.rowStride;
      for (var x = 0; x < width; x++) {
        matrix[y * width + x] = bytes[from + x];
      }
    }
    return matrix;
  }
}
