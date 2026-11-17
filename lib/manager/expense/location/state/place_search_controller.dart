import 'package:material_ui/material_ui.dart';
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

  /// Values of [PlaceSearchState.errorMessage]; the page shows them translated.
  static const searchFailed = 'search_failed';
  static const locationFailed = 'location_failed';

  PlaceSearchController({PlaceSearchState? initialState})
    : _state = initialState ?? PlaceSearchState.initial();

  PlaceSearchState get state => _state;

  void _updateState(PlaceSearchState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  /// Finds the phone's position when the page opens and picks it, so one
  /// tap on Confirm saves it. Without one (no permission, location off, no
  /// fix), [PlaceSearchState.locationUnavailable] says so on the page; no
  /// toast. The position's own time limit (10 s) starts after the
  /// permission prompt: an outer timeout would count the time spent
  /// answering it and drop a position that did arrive.
  Future<void> loadUserLocation(BuildContext context) async {
    _updateState(_state.copyWith(isLocating: true, locationUnavailable: false));
    LatLng? found;
    try {
      final location = await LocationService.getCurrentLocation(
        context,
        resolveAddress: false,
        onProblem: (_) {},
      );
      final latitude = location?.latitude;
      final longitude = location?.longitude;
      if (latitude != null && longitude != null) {
        found = LatLng(latitude, longitude);
      }
    } catch (_) {
      found = null;
    }
    if (_disposed) return;
    if (found == null) {
      _updateState(
        _state.copyWith(isLocating: false, locationUnavailable: true),
      );
      return;
    }
    _updateState(
      _state.copyWith(isLocating: false, userLocation: found, mapCenter: found),
    );
    // Picked unless something else was picked meanwhile (a tap, a search).
    if (!_state.hasSelectedLocation) {
      await selectMapLocation(found);
    } else {
      mapController.move(found, _state.mapZoom);
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
            _state.copyWith(
              mapCenter: newCenter,
              userLocation: newCenter,
              isCenteringOnLocation: false,
              locationUnavailable: false,
            ),
          );
          mapController.move(newCenter, _state.mapZoom);
          return;
        }
      }
    } catch (e) {
      _updateState(
        _state.copyWith(
          errorMessage: locationFailed,
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
          clearNoResults: true,
        ),
      );
      return;
    }

    _updateState(
      _state.copyWith(
        isSearching: true,
        clearError: true,
        clearNoResults: true,
      ),
    );

    try {
      final results = await NominatimSearchService.searchPlaces(query);
      if (_disposed || searchController.text != query) return;
      _updateState(
        _state.copyWith(
          searchResults: results,
          isSearching: false,
          clearSelectedLocation: results.isNotEmpty,
          isGeocodingLocation: false,
          noResultsQuery: results.isEmpty ? query.trim() : null,
        ),
      );
    } catch (e) {
      if (_disposed) return;
      _updateState(
        _state.copyWith(errorMessage: searchFailed, isSearching: false),
      );
    }
  }

  /// The search again, after it failed (Try again).
  void retrySearch() => _performSearch(searchController.text);

  /// Clear search results and input
  void clearSearch() {
    searchController.clear();
    _updateState(
      _state.copyWith(
        searchResults: [],
        clearError: true,
        clearNoResults: true,
        isSearching: false,
      ),
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

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _debouncer.dispose();
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
}
