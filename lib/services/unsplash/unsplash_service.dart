import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:caravella_core/caravella_core.dart';
import 'unsplash_photo.dart';

/// Service for searching and downloading photos from the Unsplash API.
///
/// Requires an API access key provided via `--dart-define=UNSPLASH_ACCESS_KEY=...`.
/// See https://unsplash.com/documentation for API details.
class UnsplashService {
  static const String _baseUrl = 'https://api.unsplash.com';
  static const String _userAgent =
      'Caravella/1.6.0 (https://github.com/calca/caravella)';

  /// Access key injected at build time via --dart-define=UNSPLASH_ACCESS_KEY=...
  static const String _accessKey = String.fromEnvironment(
    'UNSPLASH_ACCESS_KEY',
    defaultValue: '',
  );

  /// Returns true when a valid access key has been provided at build time.
  static bool get isAvailable => _accessKey.isNotEmpty;

  /// Searches Unsplash for photos matching [query].
  ///
  /// Returns a list of [UnsplashPhoto] results (up to [perPage] items).
  /// Throws on network errors or invalid responses.
  static Future<List<UnsplashPhoto>> searchPhotos(
    String query, {
    int page = 1,
    int perPage = 30,
  }) async {
    if (query.trim().isEmpty) return [];
    if (!isAvailable) {
      LoggerService.warning(
        'Unsplash access key not configured',
        name: 'api.unsplash',
      );
      return [];
    }

    final url = Uri.parse(
      '$_baseUrl/search/photos'
      '?query=${Uri.encodeComponent(query)}'
      '&page=$page'
      '&per_page=$perPage'
      '&orientation=squarish',
    );

    try {
      final response = await http
          .get(url, headers: _headers)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final results = (body['results'] as List<dynamic>?) ?? [];
        final photos =
            results
                .map(
                  (e) => UnsplashPhoto.fromJson(e as Map<String, dynamic>),
                )
                .toList();
        LoggerService.info(
          'Unsplash search for "$query" returned ${photos.length} results',
          name: 'api.unsplash',
        );
        return photos;
      } else if (response.statusCode == 401) {
        LoggerService.warning(
          'Unsplash access key is invalid or unauthorized',
          name: 'api.unsplash',
        );
        throw Exception('Invalid API key (401)');
      } else if (response.statusCode == 403) {
        LoggerService.warning(
          'Unsplash API rate limit exceeded',
          name: 'api.unsplash',
        );
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        LoggerService.warning(
          'Unsplash search failed with status ${response.statusCode}',
          name: 'api.unsplash',
        );
        throw Exception('Search failed (${response.statusCode})');
      }
    } on TimeoutException {
      LoggerService.warning(
        'Unsplash search timed out for "$query"',
        name: 'api.unsplash',
      );
      throw Exception('Connection timed out. Check your internet connection.');
    } catch (e) {
      LoggerService.warning(
        'Unsplash search error for "$query": $e',
        name: 'api.unsplash',
      );
      rethrow;
    }
  }

  /// Downloads the photo at [imageUrl] to a temporary file and returns it.
  ///
  /// Also triggers the Unsplash download tracking endpoint when
  /// [downloadLocationUrl] is provided (required by Unsplash API guidelines).
  static Future<File> downloadPhoto(
    String imageUrl, {
    String? downloadLocationUrl,
  }) async {
    // Trigger the download tracking endpoint (Unsplash API requirement)
    if (downloadLocationUrl != null && downloadLocationUrl.isNotEmpty) {
      _triggerDownloadTracking(downloadLocationUrl);
    }

    final response = await http
        .get(Uri.parse(imageUrl), headers: {'User-Agent': _userAgent})
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Failed to download image (${response.statusCode})');
    }

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/unsplash_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await file.writeAsBytes(response.bodyBytes);

    LoggerService.info('Downloaded Unsplash photo to ${file.path}',
        name: 'api.unsplash');
    return file;
  }

  /// Fires off the Unsplash download-tracking endpoint (fire-and-forget).
  static void _triggerDownloadTracking(String downloadLocationUrl) {
    // Fire-and-forget – do not await
    http
        .get(Uri.parse(downloadLocationUrl), headers: _headers)
        .timeout(const Duration(seconds: 5))
        .then((_) {
          LoggerService.debug(
            'Download tracking triggered',
            name: 'api.unsplash',
          );
        })
        .catchError((e) {
          LoggerService.debug(
            'Download tracking failed: $e',
            name: 'api.unsplash',
          );
        });
  }

  static Map<String, String> get _headers => {
    'Authorization': 'Client-ID $_accessKey',
    'User-Agent': _userAgent,
    'Accept-Version': 'v1',
  };
}
