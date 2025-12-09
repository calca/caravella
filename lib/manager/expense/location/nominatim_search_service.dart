import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:caravella_core/caravella_core.dart';
import 'nominatim_place.dart';

/// Service for searching places using OpenStreetMap Nominatim API
/// Respecting usage policy: https://operations.osmfoundation.org/policies/nominatim/
class NominatimSearchService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';
  // Nominatim requires a descriptive User-Agent with contact info
  static const String _userAgent =
      'Caravella/1.2.0 (https://github.com/calca/caravella)';
  static const String _acceptLanguage = 'it,en';

  // Rate limiting: Nominatim allows max 1 request per second
  static DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 1000);

  /// Ensures rate limiting compliance by waiting if needed
  static Future<void> _ensureRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - elapsed);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Searches for places matching the query
  /// Returns a list of up to [limit] results
  /// Throws an exception if the search fails
  static Future<List<NominatimPlace>> searchPlaces(
    String query, {
    int limit = 10,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final url = Uri.parse(
      '$_baseUrl?'
      'q=${Uri.encodeComponent(query)}'
      '&format=json'
      '&limit=$limit'
      '&addressdetails=1',
    );

    try {
      // Respect rate limiting
      await _ensureRateLimit();

      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': _userAgent,
              'Accept-Language': _acceptLanguage,
            },
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final results = jsonList
            .map((json) => NominatimPlace.fromJson(json))
            .toList();
        LoggerService.info(
          'Place search for "$query" returned ${results.length} results',
        );
        return results;
      } else if (response.statusCode == 418) {
        // 418 I'm a teapot - Nominatim rate limiting or blocked request
        LoggerService.warning(
          'Place search blocked by Nominatim (rate limit or invalid User-Agent)',
        );
        throw Exception(
          'Search temporarily unavailable. Please try again in a moment.',
        );
      } else {
        LoggerService.warning(
          'Place search failed with status code: ${response.statusCode}',
        );
        throw Exception(
          'Search failed with status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      LoggerService.warning('Place search error for "$query": $e');
      rethrow;
    }
  }

  /// Reverse geocodes coordinates to get the address at that exact location
  /// Returns a NominatimPlace representing the address at the given coordinates
  static Future<NominatimPlace?> reverseGeocode(
    double latitude,
    double longitude, {
    int zoom = 18, // Higher zoom = more specific address
  }) async {
    try {
      // Respect rate limiting
      await _ensureRateLimit();

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'lat=$latitude'
        '&lon=$longitude'
        '&format=json'
        '&zoom=$zoom'
        '&addressdetails=1',
      );

      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': _userAgent,
              'Accept-Language': _acceptLanguage,
            },
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              return http.Response('{}', 408);
            },
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['display_name'] != null) {
          return NominatimPlace.fromJson(json);
        }
      }
    } on http.ClientException catch (_) {
      // SSL/TLS or network error - return null
    } on FormatException catch (_) {
      // JSON parsing error - return null
    } catch (_) {
      // Any other error - return null
    }

    return null;
  }

  /// Searches for nearby places using reverse geocoding
  /// Returns a list of places near the given coordinates
  static Future<List<NominatimPlace>> searchNearbyPlaces(
    double latitude,
    double longitude, {
    int limit = 10,
    int zoom = 16, // Higher zoom = smaller area
  }) async {
    try {
      // Respect rate limiting
      await _ensureRateLimit();

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?'
        'lat=$latitude'
        '&lon=$longitude'
        '&format=json'
        '&zoom=$zoom'
        '&addressdetails=1',
      );

      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': _userAgent,
              'Accept-Language': _acceptLanguage,
            },
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              return http.Response('{}', 408);
            },
          );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Use the address to search for nearby places
        if (json['address'] != null) {
          final city =
              json['address']['city'] ??
              json['address']['town'] ??
              json['address']['village'] ??
              json['address']['municipality'] ??
              '';
          final suburb = json['address']['suburb'] ?? '';
          final road = json['address']['road'] ?? '';

          // Search with the most specific location available
          final searchQuery = suburb.isNotEmpty
              ? suburb
              : (road.isNotEmpty ? road : city);

          if (searchQuery.isNotEmpty) {
            // Directly call searchPlaces with proper error handling
            return searchPlaces(searchQuery, limit: limit);
          }
        }
      }
    } on http.ClientException catch (_) {
      // SSL/TLS or network error - return empty list
    } on FormatException catch (_) {
      // JSON parsing error - return empty list
    } catch (_) {
      // Any other error - return empty list
    }

    return [];
  }
}
