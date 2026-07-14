# Location & Maps

Covers the geocoding/search pipeline (`lib/manager/expense/location/**`) and the map building blocks it renders on (`caravella_core_ui/lib/map/**`). Two independent geocoding paths exist for two different purposes — don't conflate them.

## Path 1: "use my current location" (device GPS + platform geocoder)

Entry point: `LocationService.getCurrentLocation(context, ...)` (`location/location_service.dart`).

1. Checks `LocationRepository.isLocationServiceEnabled()`, then permission (`checkPermission` → `requestPermission`), surfacing the right error toast (via `ExpenseErrorHandler`, see [Expense Entry](APP_EXPENSE_ENTRY.md)) at every failure point.
2. On success, calls `LocationRepositoryImpl.getCurrentLocation(resolveAddress: true)`.
3. `LocationRepositoryImpl` (`location/repository/location_repository_impl.dart`) composes `LocationServiceAbstraction` (the platform GPS wrapper — implemented in `lib/manager/expense/services/location_service_impl.dart`, fulfilling the abstract interface declared in `caravella_core`) with the **platform** geocoder (`placemark`) for reverse geocoding, building an `ExpenseLocation` (street/locality/administrative-area/etc.).

This path is used for auto-location capture when adding an expense (toggle in [Group Management § standalone edit pages](APP_GROUP_MANAGEMENT.md#standalone-edit-pages), `autoLocationEnabled`).

## Path 2: interactive place search (Nominatim / OpenStreetMap)

A **separate** service, not the platform geocoder — used when the user searches for or taps a place on the map.

`NominatimSearchService` (`location/nominatim_search_service.dart`):
- `searchPlaces(query)` → `nominatim.openstreetmap.org/search`
- `reverseGeocode(lat, lon)` → `.../reverse`
- `searchNearbyPlaces(...)` — derives a nearby query from a reverse-geocode's suburb/road/city

Self-enforces Nominatim's 1-request/second usage policy via a static `_lastRequestTime`/`_ensureRateLimit()` gate, and sends a required descriptive `User-Agent`. Treats HTTP 418 as a distinct "blocked/rate-limited" exception. Results parse into `NominatimPlace` (lat/lon/displayName + structured address fields).

`PlaceSearchController` (`location/state/place_search_controller.dart`, `ChangeNotifier` over immutable `PlaceSearchState`) is the map-search screen's brain:
- Debounces `searchPlaces(query)` (minimum 3 characters) via a shared `Debouncer` (see [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md)).
- On map tap, `selectMapLocation` → `_geocodeLocation` → `NominatimSearchService.reverseGeocode` (3s timeout) resolves a display address for an arbitrary tapped point.
- `PlaceSearchState` tracks `mapCenter`/`mapZoom` (default: Rome, `41.9028,12.4964`) and `isCenteringOnLocation`/`isGeocodingLocation` UI flags.

The result flows back into `ExpenseFormController.updateLocation`. UI: `pages/place_search_page.dart` (full map+search screen), `widgets/location_input_widget.dart`, `widgets/compact_location_indicator.dart`.

## Map rendering

Both the place-search screen and [Group Details & Stats § Locations map](APP_GROUP_DETAILS_STATS.md#locations-map) render on `flutter_map` (OSM tiles) via the shared building blocks in `caravella_core_ui/lib/map/`: `StandardMap` (base map + tile layer), `computeBounds` (fit-camera bounding box with degenerate-span handling), and the `MapLoadingOverlay`/`MapErrorOverlay`/`MapEmptyState`/`MapNoResultsMessage` presentational overlays. See [caravella_core_ui reference § Map widgets](PACKAGE_CARAVELLA_CORE_UI.md#map-widgets) for the full catalog.

## See also

- [App: Expense Entry](APP_EXPENSE_ENTRY.md)
- [App: Group Details & Stats § Locations map](APP_GROUP_DETAILS_STATS.md#locations-map)
- [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md)
