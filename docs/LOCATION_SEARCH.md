# Location Search with OpenStreetMap

This document explains the location search functionality in Caravella using OpenStreetMap's Nominatim service.

## Overview

Caravella integrates OpenStreetMap's Nominatim geocoding service for location search in expense forms. This provides:

- **Free service** - No API key required
- **Privacy-friendly** - Uses open data from OpenStreetMap
- **F-Droid compatible** - No proprietary services
- **Consistent with maps** - Uses same data source as the expense map view

## Features

### Three Ways to Add Location

Users can add location information to expenses using:

1. **Search** (NEW) - Search for places using OpenStreetMap data
   - Tap the search icon (🔍)
   - Type a place name or address
   - Select from search results
   - Location saved with coordinates and full address

2. **GPS** - Get current device location
   - Tap the GPS icon (📍)
   - Device location retrieved
   - Reverse geocoded to address
   - Location saved with coordinates

3. **Manual Entry** - Type location text
   - Type directly in the field
   - Simple text stored
   - No coordinates (won't appear on map)

## Implementation Details

### Nominatim API

The search feature uses OpenStreetMap's Nominatim API:
- **Endpoint**: `https://nominatim.openstreetmap.org/search`
- **Format**: JSON
- **Rate limit**: 1 request per second
- **User Agent**: `Caravella-ExpenseTracker/1.1.0`

### Usage Policy Compliance

We comply with Nominatim's usage policy:
- Appropriate User-Agent header identifying the app
- Results limited to 10 per search
- Reasonable debouncing (500ms) to avoid excessive requests
- No caching or bulk downloads
- Respectful rate limiting

See: https://operations.osmfoundation.org/policies/nominatim/

### Data Model

Search results are parsed into:
```dart
class NominatimPlace {
  final double latitude;
  final double longitude;
  final String displayName;
}
```

This is then converted to the app's `ExpenseLocation` model:
```dart
ExpenseLocation(
  latitude: place.latitude,
  longitude: place.longitude,
  address: place.displayName,
)
```

## User Experience

### Search Dialog

When users tap the search button:
1. Dialog opens with search field
2. User types location query
3. Results appear after 500ms debounce
4. Selecting a result:
   - Closes dialog
   - Fills location field
   - Shows "Address resolved" toast
   - Saves coordinates for map display

### Error Handling

The implementation handles:
- Network errors (shows error message)
- No results (shows "No results found")
- Empty queries (clears results)
- Rate limiting (debounces requests)

## Benefits Over Proprietary Services

### OpenStreetMap vs Google Places

**OpenStreetMap/Nominatim:**
- ✅ Free, no API key
- ✅ Open data
- ✅ Privacy-friendly
- ✅ F-Droid compatible
- ✅ Consistent with existing maps
- ✅ Community-maintained
- ⚠️ Rate limited (1 req/sec)
- ⚠️ Less POI data in some regions

**Google Places:**
- ❌ Requires API key setup
- ❌ Costs after free tier
- ❌ Not F-Droid friendly
- ❌ Proprietary service
- ❌ Privacy concerns
- ✅ More POI data
- ✅ Better autocomplete in some cases

## Technical Notes

### Dependencies

The implementation uses standard Flutter/Dart packages:
- `http: ^1.1.0` - HTTP requests to Nominatim API
- `dart:convert` - JSON parsing
- Existing `flutter_map` - Map display (already in use)

No special geocoding packages needed.

### Performance

- Debouncing prevents excessive API calls
- Results limited to 10 items
- Dialog uses ListView for efficient rendering
- Minimal network traffic

### Privacy

- Only search queries sent to OSM
- No user tracking
- No API keys to secure
- User can always use GPS or manual entry instead

## Future Enhancements

Possible improvements:
- Add language preference to search
- Cache recent searches locally
- Add "Search near me" button
- Show distance to search results
- Add category filters (restaurants, hotels, etc.)

## Troubleshooting

### "No results found"
- Check internet connectivity
- Try broader search terms
- Verify location exists in OpenStreetMap data

### "Search failed" errors
- Check internet connection
- Wait a moment and retry (rate limit)
- Use GPS or manual entry as alternative

### Rate limiting
- App automatically debounces requests
- Wait 1 second between searches
- Not usually an issue for normal use

## References

- OpenStreetMap: https://www.openstreetmap.org
- Nominatim API: https://nominatim.org
- Usage Policy: https://operations.osmfoundation.org/policies/nominatim/
- Flutter Map: https://pub.dev/packages/flutter_map
