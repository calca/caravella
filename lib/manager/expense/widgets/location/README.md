# Location Widgets

This directory contains the location input functionality for the expense form, including GPS location retrieval, manual entry, and OpenStreetMap place search.

## Structure

The location functionality is organized into the following files:

### Core Components

- **`location_input_widget.dart`**: Main widget for location input
  - Provides a text field with GPS, search, clear, and edit buttons
  - Integrates with `LocationService` for GPS functionality
  - Manages location state and user interactions
  - Supports both automatic and manual location retrieval

- **`place_search_dialog.dart`**: Full-screen page for searching places using OpenStreetMap
  - Interactive map as background with markers for all results
  - Floating search bar at the top
  - Results shown in an overlay card at the bottom
  - Debounced search for performance
  - Tap markers on map or items in overlay list to select
  - Exports `NominatimPlace` for convenience

### Data & Services

- **`nominatim_place.dart`**: Model representing a place from OpenStreetMap Nominatim API
  - Contains latitude, longitude, and display name
  - JSON deserialization support

- **`nominatim_search_service.dart`**: Service for searching places using Nominatim API
  - Respects OpenStreetMap usage policy
  - Proper User-Agent header
  - Configurable result limit

### Supporting Files

- **`location_service.dart`**: Service for GPS location retrieval and address resolution
- **`location_widget_constants.dart`**: Shared constants for icons, sizes, etc.
- **`compact_location_indicator.dart`**: Compact view of location status

## Usage

```dart
LocationInputWidget(
  initialLocation: expense.location,
  onLocationChanged: (location) {
    // Handle location change
  },
  autoRetrieve: true, // Automatically get GPS location
)
```

## Dependencies

- `geolocator`: GPS location retrieval
- `geocoding`: Address resolution
- `flutter_map`: Interactive map display
- `latlong2`: Latitude/longitude types
- `http`: API requests to Nominatim

## OpenStreetMap Integration

The place search uses OpenStreetMap's Nominatim API following their usage policy:
- Proper User-Agent identification
- Respect for rate limits
- Attribution as required

Map tiles are provided by OpenStreetMap and displayed using `flutter_map`.
