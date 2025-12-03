import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'nominatim_place.dart';
import 'state/place_search_controller.dart';
import 'state/place_search_state.dart';

export 'nominatim_place.dart';

/// Full-screen page for searching places using OpenStreetMap Nominatim
/// Shows search results on an interactive map with an overlay list
class PlaceSearchPage extends StatefulWidget {
  final String hintText;
  final NominatimPlace? initialPlace;

  const PlaceSearchPage({super.key, required this.hintText, this.initialPlace});

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();

  /// Shows the place search page and returns the selected place
  static Future<NominatimPlace?> show(
    BuildContext context,
    String hintText, {
    NominatimPlace? initialPlace,
    bool forceRefreshLocation = false,
  }) {
    return Navigator.of(context).push<NominatimPlace>(
      MaterialPageRoute(
        builder: (ctx) =>
            PlaceSearchPage(hintText: hintText, initialPlace: initialPlace),
      ),
    );
  }
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  late final PlaceSearchController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize controller with initial place if provided
    final initialState = widget.initialPlace != null
        ? PlaceSearchState.withPlace(widget.initialPlace!)
        : PlaceSearchState.initial();

    _controller = PlaceSearchController(initialState: initialState);
    _controller.addListener(_onStateChanged);

    // Post-frame initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.initialPlace != null) {
        _showLocationConfirmationBottomSheet();
      } else {
        _controller.loadUserLocation(context);
        _controller.searchFocusNode.requestFocus();
      }
    });
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
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
          // Search bar sotto app bar
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: _buildSearchBar(theme, colorScheme),
          ),

          // Mappa
          Expanded(
            child: Stack(
              children: [
                // Full-screen map background
                _buildFullScreenMap(colorScheme),

                // Autocomplete results overlay
                if (_controller.state.hasSearchResults &&
                    _controller.searchController.text.isNotEmpty)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _buildAutocompleteResults(theme, colorScheme),
                  ),

                // Error overlay
                if (_controller.state.hasError)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: MapErrorOverlay(
                      message: _controller.state.errorMessage,
                    ),
                  ),

                // FAB per centrare su posizione corrente
                Positioned(
                  bottom: 16 + MediaQuery.of(context).padding.bottom,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: _controller.state.isCenteringOnLocation
                        ? null
                        : () => _controller.centerOnCurrentLocation(context),
                    tooltip: gloc.location,
                    child: _controller.state.isCenteringOnLocation
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return SearchBar(
      controller: _controller.searchController,
      focusNode: _controller.searchFocusNode,
      hintText: widget.hintText,
      leading: const Icon(Icons.search_outlined),
      trailing: _controller.state.isSearching
          ? [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ]
          : _controller.searchController.text.isNotEmpty
          ? [
              IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: _controller.clearSearch,
              ),
            ]
          : [],
      onChanged: (value) {
        // Debounce search with shorter delay
        _controller.searchPlaces(value);
      },
      onSubmitted: (value) => _controller.searchPlaces(value),
      elevation: WidgetStateProperty.all(0),
      backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAutocompleteResults(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _controller.state.searchResults.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final place = _controller.state.searchResults[index];
          return ListTile(
            leading: const Icon(Icons.place_outlined),
            title: Text(
              place.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              _controller.selectPlace(place);
              _showLocationConfirmationBottomSheet();
            },
          );
        },
      ),
    );
  }

  Widget _buildFullScreenMap(ColorScheme colorScheme) {
    return StandardMap(
      mapController: _controller.mapController,
      initialCenter: _controller.state.mapCenter,
      initialZoom: _controller.state.mapZoom,
      minZoom: 3.0,
      maxZoom: 18.0,
      onTap: (tapPosition, point) {
        // Remove focus from search field when tapping the map
        _controller.searchFocusNode.unfocus();
        _controller.selectMapLocation(point);
        _showLocationConfirmationBottomSheet();
      },
      layers: [
        if (_controller.state.hasSearchResults)
          MarkerLayer(
            markers: _controller.state.searchResults.map((place) {
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
        if (_controller.state.hasSelectedLocation)
          MarkerLayer(
            markers: [
              Marker(
                point: _controller.state.selectedMapLocation!,
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

  void _showLocationConfirmationBottomSheet() {
    final selected = _controller.state.selectedMapLocation!;
    final gloc = gen.AppLocalizations.of(context);
    final displayText =
        _controller.state.selectedLocationAddress ??
        '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        // Adjust map center after bottom sheet is rendered
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Approximate bottom sheet height based on content
            const bottomSheetHeight = 200.0; // Content height + padding
            final screenHeight = MediaQuery.of(context).size.height;
            _controller.adjustMapCenterForBottomSheet(
              bottomSheetHeight,
              screenHeight,
            );
          }
        });

        return GroupBottomSheetScaffold(
          title: gloc.location,
          scrollable: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Address container
              if (_controller.state.isGeocodingLocation)
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
              if (_controller.state.selectedLocationAddress != null)
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
                        _controller.state.selectedLocationAddress ??
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
