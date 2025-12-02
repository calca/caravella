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
  final double _mapZoom = 18.0; // Maximum zoom to see nearby shops and POIs
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
              // Deselect manually selected map point when showing search results
              _selectedMapLocation = null;
              _selectedLocationAddress = null;
              _isGeocodingLocation = false;
            });
            // Show results in bottom sheet
            if (results.isNotEmpty) {
              _showResultsBottomSheet();
            }
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
        // Show location confirmation bottom sheet
        _showLocationConfirmationBottomSheet();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedLocationAddress = null;
          _isGeocodingLocation = false;
        });
        // Show location confirmation bottom sheet even without address
        _showLocationConfirmationBottomSheet();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);

    return Scaffold(
      appBar: CaravellaAppBar(
        headerSemanticLabel: gloc.location,
        backButtonSemanticLabel: gloc.cancel,
      ),
      body: Column(
        children: [
          // Search bar (above map)
          Container(
            color: colorScheme.surface,
            child: _buildSearchBar(theme, colorScheme),
          ),
          // Map and results overlay
          Expanded(
            child: Stack(
              children: [
                // Full-screen map background
                _buildFullScreenMap(colorScheme),

                // Loading/error overlays only
                if (_isSearching || _isLoadingNearby)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: MapLoadingOverlay(
                      message: _isLoadingNearby
                          ? 'Finding nearby places...'
                          : 'Searching...',
                    ),
                  ),
                if (_errorMessage.isNotEmpty)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: MapErrorOverlay(message: _errorMessage),
                  ),
                if (!_isSearching &&
                    !_isLoadingNearby &&
                    _searchResults.isEmpty &&
                    _searchController.text.isNotEmpty &&
                    _errorMessage.isEmpty)
                  const Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: MapNoResultsMessage(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: SearchBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        hintText: widget.hintText,
        leading: const Icon(Icons.search_outlined),
        trailing: _searchController.text.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: _clearSearch,
                ),
              ]
            : [],
        onChanged: (value) {
          // Debounce search with shorter delay
          _debouncer.call(() {
            if (mounted && _searchController.text == value) {
              _performSearch(value);
            }
          });
        },
        onSubmitted: _performSearch,
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
        // Remove focus from search field when tapping the map
        _searchFocusNode.unfocus();

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

  void _showResultsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return GroupBottomSheetScaffold(
            title: '${_searchResults.length} risultati',
            scrollable: false,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.9,
              child: ListView.builder(
                controller: scrollController,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final place = _searchResults[index];
                  return ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      place.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop(place);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLocationConfirmationBottomSheet() {
    final selected = _selectedMapLocation!;
    final gloc = gen.AppLocalizations.of(context);
    final displayText =
        _selectedLocationAddress ??
        '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        return GroupBottomSheetScaffold(
          title: gloc.location,
          scrollable: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address container
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

              // Confirm button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final displayName =
                        _selectedLocationAddress ??
                        '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}';

                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).pop(
                      NominatimPlace(
                        latitude: selected.latitude,
                        longitude: selected.longitude,
                        displayName: displayName,
                      ),
                    );
                  },
                  child: Text(gloc.crop_confirm),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
