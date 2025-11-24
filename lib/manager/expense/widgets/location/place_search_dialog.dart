import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  bool _isLoadingNearby = true;
  bool _hasLoadedNearby = false;
  LatLng _mapCenter = const LatLng(41.9028, 12.4964); // Default: Rome, Italy
  double _mapZoom = 18.0; // Maximum zoom to see nearby shops and POIs
  LatLng? _selectedMapLocation;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Load nearby places after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNearbyPlacesAsync();
    });
  }

  void _loadNearbyPlacesAsync() {
    if (_hasLoadedNearby) return;
    _hasLoadedNearby = true;

    // Load immediately with proper context
    _loadNearbyPlaces();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNearbyPlaces() async {
    if (!mounted) return;

    if (mounted) {
      setState(() {
        _isLoadingNearby = true;
        _errorMessage = '';
      });
    }

    try {
      // Get current GPS location with reduced timeout
      final location =
          await LocationService.getCurrentLocation(
            context,
            resolveAddress: false,
          ).timeout(
            const Duration(seconds: 8),
            onTimeout: () {
              return null;
            },
          );

      if (location != null && mounted) {
        final latitude = location.latitude;
        final longitude = location.longitude;

        if (latitude != null && longitude != null) {
          // Update map center to user location immediately
          if (mounted) {
            setState(() {
              _mapCenter = LatLng(latitude, longitude);
              _mapZoom = 18.0; // Maximum zoom to see nearby shops and POIs
              _isLoadingNearby = false; // Stop loading indicator
            });
            // Move map to user location
            _mapController.move(_mapCenter, _mapZoom);
          }

          // Search for nearby places in background without blocking UI
          NominatimSearchService.searchNearbyPlaces(
                latitude,
                longitude,
                limit: 15,
              )
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () => <NominatimPlace>[],
              )
              .then((results) {
                if (mounted && results.isNotEmpty) {
                  setState(() {
                    _searchResults = results;
                  });
                }
              })
              .catchError((_) {
                // Silently ignore errors in background search
              });
        } else {
          if (mounted) {
            setState(() {
              _isLoadingNearby = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingNearby = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load nearby places';
          _isLoadingNearby = false;
        });
      }
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      // Reload nearby places when search is cleared
      setState(() {
        _isSearching = false;
        _isLoadingNearby = false;
      });
      _loadNearbyPlaces();
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
    });
    // Reload nearby places when clearing search
    _loadNearbyPlaces();
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
                if (_isSearching || _isLoadingNearby) _buildLoadingIndicator(),
                if (_errorMessage.isNotEmpty) _buildErrorMessage(colorScheme),
                if (!_isSearching &&
                    !_isLoadingNearby &&
                    _searchResults.isNotEmpty)
                  _buildResultsOverlay(theme, colorScheme),
                if (!_isSearching &&
                    !_isLoadingNearby &&
                    _searchResults.isEmpty &&
                    _searchController.text.isNotEmpty &&
                    _errorMessage.isEmpty)
                  _buildNoResultsMessage(theme, colorScheme),
              ],
            ),
          ),

          // Confirm button for map selection
          if (_selectedMapLocation != null)
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: () {
                  final selected = _selectedMapLocation!;
                  Navigator.of(context).pop(
                    NominatimPlace(
                      latitude: selected.latitude,
                      longitude: selected.longitude,
                      displayName:
                          '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}',
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Confirm'),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
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
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                // Cancel previous timer
                _debounceTimer?.cancel();
                // Debounce search with shorter delay
                _debounceTimer = Timer(const Duration(milliseconds: 300), () {
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

  Widget _buildLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _isLoadingNearby ? 'Finding nearby places...' : 'Searching...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(_errorMessage, style: TextStyle(color: colorScheme.error)),
    );
  }

  Widget _buildFullScreenMap(ColorScheme colorScheme) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: _mapZoom,
        minZoom: 3.0,
        maxZoom: 18.0,
        onTap: (tapPosition, point) {
          setState(() {
            _selectedMapLocation = point;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'io.caravella.egm',
        ),
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
        // Selected location marker
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

  Widget _buildNoResultsMessage(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'No results found',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
