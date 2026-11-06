import 'dart:async';
import 'dart:typed_data';
import 'package:material_ui/material_ui.dart';
import 'package:http/http.dart' as http;
import 'package:caravella_core/caravella_core.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

/// Loads an Unsplash thumbnail using the `http` package (same network path as
/// API calls) instead of [Image.network], which on Android emulators may bind
/// to the wlan0 interface even when only eth0 has a working default route.
///
/// Thumbnails stay in memory, so scrolling back doesn't download them again.
/// A failed download is tried once more on its own, then by tapping it.
class UnsplashThumbnail extends StatefulWidget {
  final String url;
  const UnsplashThumbnail({super.key, required this.url});

  /// Drops the least recently used first: a couple of MB at most.
  static const _cacheSize = 150;
  static final _cache = <String, Uint8List>{};

  @visibleForTesting
  static void clearCache() => _cache.clear();

  static Uint8List? _cached(String url) {
    final bytes = _cache.remove(url);
    if (bytes != null) _cache[url] = bytes;
    return bytes;
  }

  static void _remember(String url, Uint8List bytes) {
    _cache[url] = bytes;
    if (_cache.length > _cacheSize) _cache.remove(_cache.keys.first);
  }

  @override
  State<UnsplashThumbnail> createState() => _UnsplashThumbnailState();
}

class _UnsplashThumbnailState extends State<UnsplashThumbnail> {
  Uint8List? _bytes;
  bool _error = false;
  bool _visible = false;
  bool _retried = false;
  Timer? _retry;
  // Incremented on every new fetch; checked after each await so that
  // responses from a superseded request are silently discarded.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _retry?.cancel();
    super.dispose();
  }

  void _load() {
    final cached = UnsplashThumbnail._cached(widget.url);
    if (cached == null) {
      _fetch();
    } else {
      _bytes = cached;
      _visible = true;
    }
  }

  @override
  void didUpdateWidget(UnsplashThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      // Immediately invalidate any in-flight request from the old URL before
      // resetting state and starting a new fetch.
      ++_generation;
      _retry?.cancel();
      _bytes = null;
      _error = false;
      _visible = false;
      _retried = false;
      _load();
    }
  }

  Future<void> _fetch() async {
    final gen = ++_generation;
    final url = widget.url;
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        throw http.ClientException('Status ${response.statusCode}');
      }
      UnsplashThumbnail._remember(url, response.bodyBytes);
      if (_generation == gen && mounted) {
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
      _failed(gen);
    } catch (e) {
      LoggerService.warning('Thumbnail load failed: $e', name: 'api.unsplash');
      _failed(gen);
    }
  }

  void _failed(int gen) {
    if (_generation != gen || !mounted) return;
    if (_retried) {
      setState(() => _error = true);
    } else {
      _retried = true;
      _retry = Timer(const Duration(seconds: 2), _fetch);
    }
  }

  void _tryAgain() {
    setState(() => _error = false);
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Center(
        child: IconButton(
          tooltip: gen.AppLocalizations.of(context).unsplash_retry,
          icon: const Icon(Icons.broken_image_outlined),
          onPressed: _tryAgain,
        ),
      );
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
