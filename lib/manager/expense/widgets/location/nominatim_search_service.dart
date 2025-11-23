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

    final response = await http.get(
      url,
      headers: {'User-Agent': _userAgent, 'Accept-Language': _acceptLanguage},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => NominatimPlace.fromJson(json)).toList();
    } else {
      throw Exception('Search failed with status: ${response.statusCode}');
    }
  }
}
