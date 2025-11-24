/// Represents a place from OpenStreetMap Nominatim API
class NominatimPlace {
  final double latitude;
  final double longitude;
  final String displayName;

  NominatimPlace({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    return NominatimPlace(
      latitude: double.parse(json['lat'] as String),
      longitude: double.parse(json['lon'] as String),
      displayName: json['display_name'] as String,
    );
  }
}
