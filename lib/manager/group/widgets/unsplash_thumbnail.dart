import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:caravella_core/caravella_core.dart';

/// Loads an Unsplash thumbnail using the `http` package (same network path as
/// API calls) instead of [Image.network], which on Android emulators may bind
/// to the wlan0 interface even when only eth0 has a working default route.
class UnsplashThumbnail extends StatefulWidget {
  final String url;
  const UnsplashThumbnail({super.key, required this.url});

  @override
  State<UnsplashThumbnail> createState() => _UnsplashThumbnailState();
}

class _UnsplashThumbnailState extends State<UnsplashThumbnail> {
  Uint8List? _bytes;
  bool _error = false;
  bool _visible = false;
  // Incremented on every new fetch; checked after each await so that
  // responses from a superseded request are silently discarded.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void didUpdateWidget(UnsplashThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      // Immediately invalidate any in-flight request from the old URL before
      // resetting state and starting a new fetch.
      ++_generation;
      setState(() {
        _bytes = null;
        _error = false;
        _visible = false;
      });
      _fetch();
    }
  }

  Future<void> _fetch() async {
    final gen = ++_generation;
    final url = widget.url;
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 && _generation == gen && mounted) {
        setState(() => _bytes = response.bodyBytes);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_generation == gen && mounted) setState(() => _visible = true);
        });
      }
    } on TimeoutException {
      LoggerService.warning(
        'Thumbnail load timed out: $url',
        name: 'api.unsplash',
      );
      if (_generation == gen && mounted) setState(() => _error = true);
    } catch (e) {
      LoggerService.warning('Thumbnail load failed: $e', name: 'api.unsplash');
      if (_generation == gen && mounted) setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Center(child: Icon(Icons.broken_image_outlined));
    }
    if (_bytes == null) {
      return const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeIn,
      child: Image.memory(_bytes!, fit: BoxFit.cover),
    );
  }
}
