import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'nominatim_place.dart';
import 'nominatim_search_service.dart';
import 'location_service.dart';

export 'nominatim_place.dart';

/// Full-screen page for searching places using OpenStreetMap Nominatim
/// Shows search results on an interactive map with an overlay list
class PlaceSearchDialog extends StatefulWidget {
  final String hintText;

  const PlaceSearchDialog({super.key, required this.hintText});

  @override
  State<PlaceSearchDialog> createState() => _PlaceSearchDialogState();

  /// Shows the place search page and returns the selected place
  static Future<NominatimPlace?> show(
    BuildContext context,
    String hintText, {
    bool forceRefreshLocation = false,
  }) {
    return Navigator.of(context).push<NominatimPlace>(
      MaterialPageRoute(
        builder: (ctx) => PlaceSearchDialog(hintText: hintText),
      ),
    );
  }
}

class _PlaceSearchDialogState extends State<PlaceSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  List<NominatimPlace> _searchResults = [];
  bool _isSearching = false;
  String _errorMessage = '';
  bool _isLoadingNearby = false;
  LatLng _mapCenter = const LatLng(41.9028, 12.4964); // Default: Rome, Italy
  double _mapZoom = 18.0; // Maximum zoom to see nearby shops and POIs
  LatLng? _selectedMapLocation;
  String? _selectedLocationAddress;
  bool _isGeocodingLocation = false;
  late final Debouncer _debouncer;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer(duration: const Duration(milliseconds: 300));
    // Load user location and give focus to search box after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserLocation();
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  Future<void> _loadUserLocation() async {
    if (!mounted) return;

    try {
      // Get current GPS location
      final location = await LocationService.getCurrentLocation(
        context,
        resolveAddress: false,
      ).timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (location != null && mounted) {
        final latitude = location.latitude;
        final longitude = location.longitude;

        if (latitude != null && longitude != null) {
          setState(() {
            _mapCenter = LatLng(latitude, longitude);
          });
          // Move map to user location
          _mapController.move(_mapCenter, _mapZoom);
        }
      }
    } catch (e) {
      // Silently fail and use default location
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    // Only search with at least 3 characters
    if (query.trim().length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _isLoadingNearby = false;
        _errorMessage = '';
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      _isSearching = true;
      _isLoadingNearby = false;
      _errorMessage = '';
    });

    // Run search without blocking UI
    NominatimSearchService.searchPlaces(query)
        .then((results) {
          if (mounted) {
            setState(() {
              _searchResults = results;
              _isSearching = false;
            });
          }
        })
        .catchError((e) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Search failed';
              _isSearching = false;
            });
          }
        });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _errorMessage = '';
      _isSearching = false;
      _isLoadingNearby = false;
    });
  }

  Future<void> _geocodeSelectedLocation(LatLng location) async {
    try {
      final place = await NominatimSearchService.reverseGeocode(
        location.latitude,
        location.longitude,
      ).timeout(const Duration(seconds: 3), onTimeout: () => null);

      if (mounted) {
        setState(() {
          _selectedLocationAddress = place?.displayName;
          _isGeocodingLocation = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedLocationAddress = null;
          _isGeocodingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map background (always visible)
          _buildFullScreenMap(colorScheme),

          // Top search bar and results overlay
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(theme, colorScheme),
                if (_isSearching || _isLoadingNearby)
                  MapLoadingOverlay(
                    message: _isLoadingNearby
                        ? 'Finding nearby places...'
                        : 'Searching...',
                  ),
                if (_errorMessage.isNotEmpty)
                  MapErrorOverlay(message: _errorMessage),
                // Hide results list when a map location is selected
                if (_selectedMapLocation == null) ...[
                  if (!_isSearching &&
                      !_isLoadingNearby &&
                      _searchResults.isNotEmpty)
                    _buildResultsOverlay(theme, colorScheme),
                  if (!_isSearching &&
                      !_isLoadingNearby &&
                      _searchResults.isEmpty &&
                      _searchController.text.isNotEmpty &&
                      _errorMessage.isEmpty)
                    const MapNoResultsMessage(),
                ] else
                  // Show selected location info when map location is selected
                  _buildSelectedLocationInfo(theme, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                // Debounce search with shorter delay
                _debouncer.call(() {
                  if (mounted && _searchController.text == value) {
                    _performSearch(value);
                  }
                });
              },
              onSubmitted: _performSearch,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFullScreenMap(ColorScheme colorScheme) {
    return StandardMap(
      mapController: _mapController,
      initialCenter: _mapCenter,
      initialZoom: _mapZoom,
      minZoom: 3.0,
      maxZoom: 18.0,
      onTap: (tapPosition, point) {
        setState(() {
          _selectedMapLocation = point;
          _selectedLocationAddress = null;
          _isGeocodingLocation = true;
        });
        _geocodeSelectedLocation(point);
      },
      layers: [
        if (_searchResults.isNotEmpty)
          MarkerLayer(
            markers: _searchResults.map((place) {
              return Marker(
                point: LatLng(place.latitude, place.longitude),
                width: 40,
                height: 40,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(place),
                  child: Icon(
                    Icons.location_on,
                    color: colorScheme.error,
                    size: 40,
                  ),
                ),
              );
            }).toList(),
          ),
        if (_selectedMapLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _selectedMapLocation!,
                width: 50,
                height: 50,
                child: Icon(
                  Icons.place,
                  color: colorScheme.primary,
                  size: 50,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildResultsOverlay(ThemeData theme, ColorScheme colorScheme) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 300),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.place,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_searchResults.length} result${_searchResults.length != 1 ? 's' : ''}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final place = _searchResults[index];
                    return ListTile(
                      leading: Icon(
                        Icons.place_outlined,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      title: Text(
                        place.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      onTap: () => Navigator.of(context).pop(place),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedLocationInfo(ThemeData theme, ColorScheme colorScheme) {
    final selected = _selectedMapLocation!;
    final displayText =
        _selectedLocationAddress ??
        '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}';

    return Expanded(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                gen.AppLocalizations.of(context).location,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Address container (same style as location details)
              if (_isGeocodingLocation)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Finding address...',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(displayText, style: theme.textTheme.bodyLarge),
                ),

              // Coordinates if available
              if (_selectedLocationAddress != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Actions row (same style as location details)
              Row(
                children: [
                  const Spacer(),
                  _buildActionButton(
                    icon: Icons.close,
                    tooltip: 'Clear selection',
                    onTap: () {
                      setState(() {
                        _selectedMapLocation = null;
                        _selectedLocationAddress = null;
                        _isGeocodingLocation = false;
                      });
                    },
                    destructive: true,
                  ),
                  _buildActionButton(
                    icon: Icons.check,
                    tooltip: 'Confirm location',
                    onTap: () {
                      final displayName =
                          _selectedLocationAddress ??
                          '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}';

                      Navigator.of(context).pop(
                        NominatimPlace(
                          latitude: selected.latitude,
                          longitude: selected.longitude,
                          displayName: displayName,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(icon),
      iconSize: 28,
      color: destructive ? colorScheme.error : colorScheme.primary,
      tooltip: tooltip,
      onPressed: onTap,
    );
  }
}
