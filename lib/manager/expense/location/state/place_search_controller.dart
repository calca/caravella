import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import '../location_service.dart';
import '../nominatim_place.dart';
import '../nominatim_search_service.dart';
import 'place_search_state.dart';

/// Controller for place search page managing state and business logic
class PlaceSearchController extends ChangeNotifier {
  PlaceSearchState _state;
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final Debouncer _debouncer = Debouncer(
    duration: const Duration(milliseconds: 300),
  );

  PlaceSearchController({PlaceSearchState? initialState})
    : _state = initialState ?? PlaceSearchState.initial();

  PlaceSearchState get state => _state;

  void _updateState(PlaceSearchState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Load user's current GPS location
  Future<void> loadUserLocation(BuildContext context) async {
    try {
      final location = await LocationService.getCurrentLocation(
        context,
        resolveAddress: false,
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (location != null) {
        final latitude = location.latitude;
        final longitude = location.longitude;

        if (latitude != null && longitude != null) {
          final newCenter = LatLng(latitude, longitude);
          _updateState(_state.copyWith(mapCenter: newCenter));
          mapController.move(newCenter, _state.mapZoom);
        }
      }
    } catch (e) {
      // Silently fail and use default location
    }
  }

  /// Center map on user's current GPS location
  Future<void> centerOnCurrentLocation(BuildContext context) async {
    _updateState(
      _state.copyWith(isCenteringOnLocation: true, clearError: true),
    );

    try {
      final location = await LocationService.getCurrentLocation(
        context,
        resolveAddress: false,
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (location != null) {
        final latitude = location.latitude;
        final longitude = location.longitude;

        if (latitude != null && longitude != null) {
          final newCenter = LatLng(latitude, longitude);
          _updateState(
            _state.copyWith(mapCenter: newCenter, isCenteringOnLocation: false),
          );
          mapController.move(newCenter, _state.mapZoom);
          return;
        }
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          errorMessage: 'Unable to get current location',
          isCenteringOnLocation: false,
        ),
      );
      return;
    }

    _updateState(_state.copyWith(isCenteringOnLocation: false));
  }

  /// Perform place search with debouncing
  void searchPlaces(String query) {
    _debouncer.call(() {
      if (searchController.text == query) {
        _performSearch(query);
      }
    });
  }

  /// Execute the actual search
  Future<void> _performSearch(String query) async {
    // Only search with at least 3 characters
    if (query.trim().length < 3) {
      _updateState(
        _state.copyWith(
          searchResults: [],
          isSearching: false,
          clearError: true,
        ),
      );
      return;
    }

    _updateState(_state.copyWith(isSearching: true, clearError: true));

    try {
      final results = await NominatimSearchService.searchPlaces(query);
      _updateState(
        _state.copyWith(
          searchResults: results,
          isSearching: false,
          clearSelectedLocation: true,
          isGeocodingLocation: false,
        ),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(errorMessage: 'Search failed', isSearching: false),
      );
    }
  }

  /// Clear search results and input
  void clearSearch() {
    searchController.clear();
    _updateState(
      _state.copyWith(searchResults: [], clearError: true, isSearching: false),
    );
  }

  /// Select a place from search results
  void selectPlace(NominatimPlace place) {
    final location = LatLng(place.latitude, place.longitude);
    _updateState(
      _state.copyWith(
        selectedMapLocation: location,
        selectedLocationAddress: place.displayName,
        isGeocodingLocation: false,
        searchResults: [],
      ),
    );
    searchController.clear();
    mapController.move(location, _state.mapZoom);
  }

  /// Handle map tap to select a location
  Future<void> selectMapLocation(LatLng location) async {
    _updateState(
      _state.copyWith(
        selectedMapLocation: location,
        selectedLocationAddress: null,
        isGeocodingLocation: true,
      ),
    );

    await _geocodeLocation(location);
  }

  /// Reverse geocode a location to get address
  Future<void> _geocodeLocation(LatLng location) async {
    try {
      final place = await NominatimSearchService.reverseGeocode(
        location.latitude,
        location.longitude,
      ).timeout(const Duration(seconds: 3), onTimeout: () => null);

      _updateState(
        _state.copyWith(
          selectedLocationAddress: place?.displayName,
          isGeocodingLocation: false,
        ),
      );
    } catch (_) {
      _updateState(
        _state.copyWith(
          selectedLocationAddress: null,
          isGeocodingLocation: false,
        ),
      );
    }
  }

  /// Adjust map center to account for bottom sheet
  void adjustMapCenterForBottomSheet(
    double bottomSheetHeight,
    double screenHeight,
  ) {
    if (_state.selectedMapLocation == null) return;

    final offsetPixels = bottomSheetHeight / 2;
    final latitudeOffset = (offsetPixels / screenHeight) * 0.003;

    final adjustedCenter = LatLng(
      _state.selectedMapLocation!.latitude - latitudeOffset,
      _state.selectedMapLocation!.longitude,
    );

    mapController.move(adjustedCenter, _state.mapZoom);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}
