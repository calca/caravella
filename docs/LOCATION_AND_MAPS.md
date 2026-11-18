# Location & Maps

Covers the geocoding/search pipeline (`lib/manager/expense/location/**`) and the map building blocks it renders on (`caravella_core_ui/lib/map/**`). Two independent geocoding paths exist for two different purposes — don't conflate them.

## Places saved as bare coordinates

Before SQLite v7 (2.3.0) a place kept only latitude, longitude and name, so one from the automatic location — a locality but no name — reads back as coordinates (`ExpenseLocation.isBareCoordinates`). When such an expense is opened in the form, `ExpenseFormComponent._nameBarePlace` asks `LocationService.name` (→ `LocationRepository.describe`, the platform geocoder, the same as for the current location) in the background; with an answer, and the place untouched meanwhile, it shows it (`updateLocation(byUser: false)`: no "discard changes?") and keeps it with `ExpenseGroupStorageV2.fillExpenseLocation` — a local fix, not an edit: no "modified by", the group's `updated_at` unchanged, nothing synced (each device names its own copy). Offline or without a geocoder nothing happens, and it tries again the next time the expense is opened. Places still bare elsewhere (search, CSV export) show coordinates until their expense is opened.

## Path 1: "use my current location" (device GPS + platform geocoder)

Entry point: `LocationService.getCurrentLocation(context, ...)` (`location/location_service.dart`).

1. Checks `LocationRepository.isLocationServiceEnabled()`, then permission (`checkPermission` → `requestPermission`), reporting every failure point as a `LocationProblem` (`serviceDisabled`, `permissionDenied`, `deniedForever`, `notFound`). With an `onProblem` callback the caller shows it in place — the expense form's empty Place pill (`LocationInputWidget`) then reads "Location is off" / "Location not allowed" / "Location not found" and still opens the place search; without one, `ExpenseErrorHandler` shows the matching toast, except `deniedForever`, which opens `showPermissionDeniedDialog` (“Allow location?” → Open settings) (see [Expense Entry](APP_EXPENSE_ENTRY.md)).
2. On success, calls `LocationRepositoryImpl.getCurrentLocation(resolveAddress: true)`.
3. `LocationRepositoryImpl` (`location/repository/location_repository_impl.dart`) composes `LocationServiceAbstraction` (the platform GPS wrapper — implemented in `lib/manager/expense/services/location_service_impl.dart`, fulfilling the abstract interface declared in `caravella_core`; its position comes from `GmsIntegrations.instance.createPositionProvider()` — Google's fused provider via `geolocator` in Play builds — or, in the F-Droid build, from `LocationManagerPositionProvider`, the platform `LocationManager` behind the `io.caravella.egm/location` channel in `android/.../LocationChannel.kt`; see [caravella_gms](PACKAGE_CARAVELLA_GMS.md)) with the **platform** geocoder (`placemark`) for reverse geocoding, building an `ExpenseLocation` (street/locality/administrative-area/etc.).

This path is used for auto-location capture when adding an expense (toggle in [Group Management § standalone edit pages](APP_GROUP_MANAGEMENT.md#standalone-edit-pages), `autoLocationEnabled`).

## Path 2: interactive place search (Nominatim / OpenStreetMap)

A **separate** service, not the platform geocoder — used when the user searches for or taps a place on the map.

`NominatimSearchService` (`location/nominatim_search_service.dart`):
- `searchPlaces(query)` → `nominatim.openstreetmap.org/search`
- `reverseGeocode(lat, lon)` → `.../reverse`
- `searchNearbyPlaces(...)` — derives a nearby query from a reverse-geocode's suburb/road/city

Asks for names in the app's language (`Accept-Language`: `NominatimSearchService.language`, set by `CaravellaApp` with its locale, English as fallback). Self-enforces Nominatim's 1-request/second usage policy via a static `_lastRequestTime`/`_ensureRateLimit()` gate, and sends a required descriptive `User-Agent`. Treats HTTP 418 as a distinct "blocked/rate-limited" exception. Results parse into `NominatimPlace` (lat/lon/displayName + structured address fields).

`PlaceSearchController` (`location/state/place_search_controller.dart`, `ChangeNotifier` over immutable `PlaceSearchState`) is the map-search screen's brain:
- Debounces `searchPlaces(query)` (minimum 3 characters) via a shared `Debouncer` (see [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md)).
- On map tap, `selectMapLocation` → `_geocodeLocation` → `NominatimSearchService.reverseGeocode` (3s timeout) resolves a display address for an arbitrary tapped point.
- `PlaceSearchPage` shows the selected point (a tapped point, a search result, or the expense's place when it already has one) in a card at the bottom of the map, with the address, coordinates and Confirm. It is not a modal sheet, so the search above and the map stay usable to pick another place, and the card steps aside while the search field has focus.
- Opened without a place, `loadUserLocation` finds the phone's position (`LocationService.getCurrentLocation` with `onProblem` silenced: the page shows it, no toast; no outer timeout, since one would count the time spent on the permission prompt; the position's own limit is 10 s) and picks it: the card says "You are here" (`place_you_are_here`, `selectedIsUserLocation`) over its address, so one tap on Confirm saves it, and a blue dot marks the position (`_UserDot`) from then on. While it looks, the card says so (`getting_location`); without a position (`locationUnavailable`), that it couldn't be found and to search or tap the map. The search field isn't focused on open, so no keyboard covers the card. The round button to center on the position sits above the card; when nothing is picked yet (the position wasn't found on opening) it also picks the position, so the card offers Confirm.
- A search that finds nothing sets `noResultsQuery` ("No places found for “…”" with a hint); one that fails (network, timeout — 10 s —, HTTP error) sets `errorMessage` to `searchFailed`: both show in a neutral card under the search (`_MessageCard`, raised surface, no red), the failure with Try again (`retrySearch`). Search results are pins in the primary color (red read as an error).
- `PlaceSearchState` tracks `mapCenter`/`mapZoom` (default: Rome, `41.9028,12.4964`, until the position is found), `userLocation`, `isLocating`/`locationUnavailable`, `noResultsQuery` and the `isCenteringOnLocation`/`isGeocodingLocation` UI flags.

The result flows back into `ExpenseFormController.updateLocation`. UI: `pages/place_search_page.dart` (full map+search screen), `widgets/location_input_widget.dart`, `widgets/compact_location_indicator.dart`.

## Map rendering

Both the place-search screen and [Group Details & Stats § Locations map](APP_GROUP_DETAILS_STATS.md#locations-map) render on `flutter_map` (OSM tiles) via the shared building blocks in `caravella_core_ui/lib/map/`: `StandardMap` (base map + tile layer; give it a `MapTileStatus` to follow the tiles, for `MapLoadingOverlay` while they are slow and `MapUnavailableCard` with Try again when they fail and none shows), `computeBounds` (fit-camera bounding box with degenerate-span handling), and the `MapErrorOverlay`/`MapEmptyState`/`MapNoResultsMessage` presentational overlays. See [caravella_core_ui reference § Map widgets](PACKAGE_CARAVELLA_CORE_UI.md#map-widgets) for the full catalog.

## See also

- [App: Expense Entry](APP_EXPENSE_ENTRY.md)
- [App: Group Details & Stats § Locations map](APP_GROUP_DETAILS_STATS.md#locations-map)
- [caravella_core_ui reference](PACKAGE_CARAVELLA_CORE_UI.md)
