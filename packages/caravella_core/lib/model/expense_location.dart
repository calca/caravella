class ExpenseLocation {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? name;

  // Detailed geocoding information
  final String? street;
  final String? streetNumber;
  final String? locality;
  final String? subLocality;
  final String? administrativeArea;
  final String? subAdministrativeArea;
  final String? postalCode;
  final String? country;
  final String? isoCountryCode;

  ExpenseLocation({
    this.latitude,
    this.longitude,
    this.address,
    this.name,
    this.street,
    this.streetNumber,
    this.locality,
    this.subLocality,
    this.administrativeArea,
    this.subAdministrativeArea,
    this.postalCode,
    this.country,
    this.isoCountryCode,
  });

  factory ExpenseLocation.fromJson(Map<String, dynamic> json) {
    return ExpenseLocation(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
      name: json['name'],
      street: json['street'],
      streetNumber: json['streetNumber'],
      locality: json['locality'],
      subLocality: json['subLocality'],
      administrativeArea: json['administrativeArea'],
      subAdministrativeArea: json['subAdministrativeArea'],
      postalCode: json['postalCode'],
      country: json['country'],
      isoCountryCode: json['isoCountryCode'],
    );
  }

  Map<String, dynamic> toJson() => {
    if (latitude != null) 'latitude': latitude,
    if (longitude != null) 'longitude': longitude,
    if (address != null) 'address': address,
    if (name != null) 'name': name,
    if (street != null) 'street': street,
    if (streetNumber != null) 'streetNumber': streetNumber,
    if (locality != null) 'locality': locality,
    if (subLocality != null) 'subLocality': subLocality,
    if (administrativeArea != null) 'administrativeArea': administrativeArea,
    if (subAdministrativeArea != null)
      'subAdministrativeArea': subAdministrativeArea,
    if (postalCode != null) 'postalCode': postalCode,
    if (country != null) 'country': country,
    if (isoCountryCode != null) 'isoCountryCode': isoCountryCode,
  };

  bool get hasLocation => latitude != null && longitude != null;

  String get displayText {
    if (name != null && name!.isNotEmpty) return name!;
    if (address != null && address!.isNotEmpty) return address!;
    if (hasLocation) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }
    return '';
  }

  ExpenseLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? name,
    String? street,
    String? streetNumber,
    String? locality,
    String? subLocality,
    String? administrativeArea,
    String? subAdministrativeArea,
    String? postalCode,
    String? country,
    String? isoCountryCode,
  }) {
    return ExpenseLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      name: name ?? this.name,
      street: street ?? this.street,
      streetNumber: streetNumber ?? this.streetNumber,
      locality: locality ?? this.locality,
      subLocality: subLocality ?? this.subLocality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      subAdministrativeArea:
          subAdministrativeArea ?? this.subAdministrativeArea,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isoCountryCode: isoCountryCode ?? this.isoCountryCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseLocation &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          address == other.address &&
          name == other.name &&
          street == other.street &&
          streetNumber == other.streetNumber &&
          locality == other.locality &&
          subLocality == other.subLocality &&
          administrativeArea == other.administrativeArea &&
          subAdministrativeArea == other.subAdministrativeArea &&
          postalCode == other.postalCode &&
          country == other.country &&
          isoCountryCode == other.isoCountryCode;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      address.hashCode ^
      name.hashCode ^
      street.hashCode ^
      streetNumber.hashCode ^
      locality.hashCode ^
      subLocality.hashCode ^
      administrativeArea.hashCode ^
      subAdministrativeArea.hashCode ^
      postalCode.hashCode ^
      country.hashCode ^
      isoCountryCode.hashCode;
}
