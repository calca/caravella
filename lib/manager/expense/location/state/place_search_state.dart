import 'package:latlong2/latlong.dart';
import '../nominatim_place.dart';

/// Immutable state for place search
class PlaceSearchState {
  final List<NominatimPlace> searchResults;
  final bool isSearching;
  final String errorMessage;
  final LatLng mapCenter;
  final double mapZoom;
  final LatLng? selectedMapLocation;
  final String? selectedLocationAddress;
  final bool isGeocodingLocation;
  final bool isCenteringOnLocation;

  const PlaceSearchState({
    this.searchResults = const [],
    this.isSearching = false,
    this.errorMessage = '',
    required this.mapCenter,
    this.mapZoom = 18.0,
    this.selectedMapLocation,
    this.selectedLocationAddress,
    this.isGeocodingLocation = false,
    this.isCenteringOnLocation = false,
  });

  /// Default state with Rome coordinates
  factory PlaceSearchState.initial() {
    return const PlaceSearchState(
      mapCenter: LatLng(41.9028, 12.4964), // Rome, Italy
    );
  }

  /// State initialized with a place
  factory PlaceSearchState.withPlace(NominatimPlace place) {
    final location = LatLng(place.latitude, place.longitude);
    return PlaceSearchState(
      mapCenter: location,
      selectedMapLocation: location,
      selectedLocationAddress: place.displayName,
    );
  }

  PlaceSearchState copyWith({
    List<NominatimPlace>? searchResults,
    bool? isSearching,
    String? errorMessage,
    LatLng? mapCenter,
    double? mapZoom,
    LatLng? selectedMapLocation,
    String? selectedLocationAddress,
    bool? isGeocodingLocation,
    bool? isCenteringOnLocation,
    bool clearSelectedLocation = false,
    bool clearError = false,
  }) {
    return PlaceSearchState(
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      errorMessage: clearError ? '' : (errorMessage ?? this.errorMessage),
      mapCenter: mapCenter ?? this.mapCenter,
      mapZoom: mapZoom ?? this.mapZoom,
      selectedMapLocation: clearSelectedLocation
          ? null
          : (selectedMapLocation ?? this.selectedMapLocation),
      selectedLocationAddress: clearSelectedLocation
          ? null
          : (selectedLocationAddress ?? this.selectedLocationAddress),
      isGeocodingLocation: isGeocodingLocation ?? this.isGeocodingLocation,
      isCenteringOnLocation:
          isCenteringOnLocation ?? this.isCenteringOnLocation,
    );
  }

  bool get hasSearchResults => searchResults.isNotEmpty;
  bool get hasError => errorMessage.isNotEmpty;
  bool get hasSelectedLocation => selectedMapLocation != null;
}
