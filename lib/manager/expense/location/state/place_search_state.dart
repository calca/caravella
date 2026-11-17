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

  /// Where the phone is, once found (the blue dot).
  final LatLng? userLocation;

  /// Looking for the phone's position when the page opens.
  final bool isLocating;

  /// The phone's position couldn't be found (no permission, location off,
  /// no fix in time): the page says so instead of staying on the default.
  final bool locationUnavailable;

  /// The last search that found nothing, to say so.
  final String? noResultsQuery;

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
    this.userLocation,
    this.isLocating = false,
    this.locationUnavailable = false,
    this.noResultsQuery,
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
    LatLng? userLocation,
    bool? isLocating,
    bool? locationUnavailable,
    String? noResultsQuery,
    bool clearNoResults = false,
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
      userLocation: userLocation ?? this.userLocation,
      isLocating: isLocating ?? this.isLocating,
      locationUnavailable: locationUnavailable ?? this.locationUnavailable,
      noResultsQuery: clearNoResults
          ? null
          : (noResultsQuery ?? this.noResultsQuery),
    );
  }

  bool get hasSearchResults => searchResults.isNotEmpty;
  bool get hasError => errorMessage.isNotEmpty;
  bool get hasSelectedLocation => selectedMapLocation != null;

  /// The selected point is the phone's own position ("You are here").
  bool get selectedIsUserLocation =>
      userLocation != null && selectedMapLocation == userLocation;
}
