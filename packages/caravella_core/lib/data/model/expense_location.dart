class ExpenseLocation {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? name;

  ExpenseLocation({
    this.latitude,
    this.longitude,
    this.address,
    this.name,
  });

  factory ExpenseLocation.fromJson(Map<String, dynamic> json) {
    return ExpenseLocation(
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (address != null) 'address': address,
        if (name != null) 'name': name,
      };

  bool get hasLocation => latitude != null && longitude != null;

  String get displayText {
    if (name != null && name!.isNotEmpty) return name!;
    if (address != null && address!.isNotEmpty) return address!;
    if (hasLocation) return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    return '';
  }

  ExpenseLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? name,
  }) {
    return ExpenseLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      name: name ?? this.name,
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
          name == other.name;

  @override
  int get hashCode =>
      latitude.hashCode ^
      longitude.hashCode ^
      address.hashCode ^
      name.hashCode;
}