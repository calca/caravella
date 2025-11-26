/// Represents a place from OpenStreetMap Nominatim API
class NominatimPlace {
  final double latitude;
  final double longitude;
  final String displayName;
  
  // Address details from Nominatim
  final String? name;
  final String? road;
  final String? houseNumber;
  final String? suburb;
  final String? city;
  final String? town;
  final String? village;
  final String? municipality;
  final String? state;
  final String? postcode;
  final String? country;
  final String? countryCode;

  NominatimPlace({
    required this.latitude,
    required this.longitude,
    required this.displayName,
    this.name,
    this.road,
    this.houseNumber,
    this.suburb,
    this.city,
    this.town,
    this.village,
    this.municipality,
    this.state,
    this.postcode,
    this.country,
    this.countryCode,
  });

  factory NominatimPlace.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    
    return NominatimPlace(
      latitude: double.parse(json['lat'] as String),
      longitude: double.parse(json['lon'] as String),
      displayName: json['display_name'] as String,
      name: json['name'] as String?,
      road: address?['road'] as String?,
      houseNumber: address?['house_number'] as String?,
      suburb: address?['suburb'] as String?,
      city: address?['city'] as String?,
      town: address?['town'] as String?,
      village: address?['village'] as String?,
      municipality: address?['municipality'] as String?,
      state: address?['state'] as String?,
      postcode: address?['postcode'] as String?,
      country: address?['country'] as String?,
      countryCode: address?['country_code'] as String?,
    );
  }
}
