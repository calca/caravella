import 'dart:convert';
import 'package:http/http.dart' as http;
import 'nominatim_place.dart';

/// Service for searching places using OpenStreetMap Nominatim API
/// Respecting usage policy: https://operations.osmfoundation.org/policies/nominatim/
class NominatimSearchService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org/search';
  static const String _userAgent = 'Caravella-ExpenseTracker/1.1.0';
  static const String _acceptLanguage = 'it,en';

  /// Searches for places matching the query
  /// Returns a list of up to [limit] results
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
      final response = await http
          .get(
            url,
            headers: {
              'User-Agent': _userAgent,
              'Accept-Language': _acceptLanguage,
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => NominatimPlace.fromJson(json)).toList();
      } else {
        throw Exception('Search failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty list on timeout or error
      return [];
    }
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
          .timeout(const Duration(seconds: 10));

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
    } catch (e) {
      // Return empty list on any error
      return [];
    }

    return [];
  }
}
