import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import '../location/nominatim_place.dart';
import '../location/state/place_search_controller.dart';
import '../location/state/place_search_state.dart';

export '../location/nominatim_place.dart';

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
  final MapTileStatus _tileStatus = MapTileStatus();

  @override
  void initState() {
    super.initState();

    // Initialize controller with initial place if provided
    final initialState = widget.initialPlace != null
        ? PlaceSearchState.withPlace(widget.initialPlace!)
        : PlaceSearchState.initial();

    _controller = PlaceSearchController(initialState: initialState);
    _controller.addListener(_onStateChanged);
    // The selection card hides while typing a search.
    _controller.searchFocusNode.addListener(_onStateChanged);

    // Post-frame initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.initialPlace != null) {
        _centerAboveCard();
      } else {
        // Opens on where the phone is, already picked: one tap on Confirm.
        // No keyboard on top of it; the search is a tap away.
        _controller.loadUserLocation(context).then((_) {
          if (mounted && _controller.state.hasSelectedLocation) {
            _centerAboveCard();
          }
        });
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
    _tileStatus.dispose();
    _controller.removeListener(_onStateChanged);
    _controller.searchFocusNode.removeListener(_onStateChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gloc = gen.AppLocalizations.of(context);

    // The map fills the screen; back and the search pill float over it,
    // the results drop below the pill.
    final topInset = MediaQuery.paddingOf(context).top;
    return AppSystemUI.edgeToEdge(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: _buildFullScreenMap(colorScheme)),
            Positioned.fill(
              child: MapLoadingOverlay(
                status: _tileStatus,
                message: gloc.map_loading,
              ),
            ),
            Positioned(
              top: topInset + 8,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Semantics(
                        label: gloc.cancel,
                        child: const RoundBackButton(),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _buildSearchBar(theme, colorScheme)),
                    ],
                  ),
                  if (_controller.state.hasSearchResults &&
                      _controller.searchController.text.isNotEmpty)
                    _buildAutocompleteResults(theme, colorScheme),
                  MapUnavailableCard(
                    status: _tileStatus,
                    title: gloc.map_unavailable_title,
                    message: gloc.map_unavailable_place_message,
                    retryLabel: gloc.map_retry,
                  ),
                  if (_messageCard(gloc) case final message?)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: message,
                    ),
                ],
              ),
            ),
            // At the bottom: the round button to center on the position,
            // above the card (the picked point, or why there's none), so
            // neither covers the other. Not a modal sheet: the search above
            // and the map stay usable, to search another place or tap one.
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.paddingOf(context).bottom + 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: _controller.state.isCenteringOnLocation
                        ? null
                        : () => _controller.centerOnCurrentLocation(context),
                    tooltip: gloc.get_current_location,
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
                  if (!_controller.searchFocusNode.hasFocus)
                    if (_bottomCard(theme, colorScheme, gloc) case final card?)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SizedBox(width: double.infinity, child: card),
                      ),
                ],
              ),
            ),
          ],
        ),
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
                tooltip: gen.AppLocalizations.of(context).clear,
                onPressed: _controller.clearSearch,
              ),
            ]
          : [],
      onChanged: (value) {
        // Debounce search with shorter delay
        _controller.searchPlaces(value);
      },
      onSubmitted: (value) => _controller.searchPlaces(value),
      elevation: WidgetStateProperty.all(2),
      shadowColor: WidgetStateProperty.all(Colors.black26),
      backgroundColor: WidgetStateProperty.all(colorScheme.raisedSurface),
      shape: WidgetStateProperty.all(const StadiumBorder()),
    );
  }

  Widget _buildAutocompleteResults(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      margin: const EdgeInsets.only(top: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.raisedSurface,
        borderRadius: BorderRadius.circular(20),
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
        padding: EdgeInsets.zero,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 56,
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
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
              // Drops the keyboard so the selection card shows.
              _controller.searchFocusNode.unfocus();
              _centerAboveCard();
            },
          );
        },
      ),
    );
  }

  Widget _buildFullScreenMap(ColorScheme colorScheme) {
    return StandardMap(
      semanticLabel: gen.AppLocalizations.of(context).location,
      tileStatus: _tileStatus,
      mapController: _controller.mapController,
      initialCenter: _controller.state.mapCenter,
      initialZoom: _controller.state.mapZoom,
      minZoom: 3.0,
      maxZoom: 18.0,
      onTap: (tapPosition, point) {
        // Remove focus from search field when tapping the map
        _controller.searchFocusNode.unfocus();
        _controller.selectMapLocation(point);
        _centerAboveCard();
      },
      layers: [
        // Where the phone is: a blue dot, as in every map app.
        if (_controller.state.userLocation case final here?)
          MarkerLayer(
            markers: [
              Marker(
                point: here,
                width: 32,
                height: 32,
                child: const ExcludeSemantics(child: _UserDot()),
              ),
            ],
          ),
        if (_controller.state.hasSearchResults)
          MarkerLayer(
            markers: _controller.state.searchResults.map((place) {
              return Marker(
                point: LatLng(place.latitude, place.longitude),
                width: AppDimens.minTouchTarget,
                height: AppDimens.minTouchTarget,
                child: Semantics(
                  button: true,
                  label: place.displayName,
                  onTap: () => Navigator.of(context).pop(place),
                  excludeSemantics: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => Navigator.of(context).pop(place),
                    child: Center(
                      // The app's color: red on a map reads as an error.
                      child: Icon(
                        Icons.location_on,
                        color: colorScheme.primary,
                        size: 40,
                      ),
                    ),
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

  /// Under the search: why it found nothing, or that it failed (with Try
  /// again), or that the position couldn't be found; never red text on the
  /// map. Null when there's nothing to say.
  Widget? _messageCard(gen.AppLocalizations gloc) {
    final state = _controller.state;
    if (state.isSearching) return null;
    if (state.errorMessage == PlaceSearchController.searchFailed) {
      return _MessageCard(
        icon: Icons.wifi_off_rounded,
        title: gloc.place_search_failed_title,
        message: gloc.place_search_failed,
        actionLabel: gloc.map_retry,
        onAction: _controller.retrySearch,
      );
    }
    if (state.errorMessage == PlaceSearchController.locationFailed) {
      return _MessageCard(
        icon: Icons.location_disabled_outlined,
        title: gloc.location_error,
        message: gloc.place_location_unavailable,
      );
    }
    final query = state.noResultsQuery;
    if (query != null && _controller.searchController.text.isNotEmpty) {
      return _MessageCard(
        icon: Icons.search_off_rounded,
        title: gloc.place_no_results(query),
        message: gloc.place_no_results_hint,
      );
    }
    return null;
  }

  /// At the bottom: the picked point with Confirm; while the position is
  /// being found, that; without one, that it couldn't be found.
  Widget? _bottomCard(
    ThemeData theme,
    ColorScheme colorScheme,
    gen.AppLocalizations gloc,
  ) {
    final state = _controller.state;
    if (state.hasSelectedLocation) {
      return _buildSelectionCard(theme, colorScheme, gloc);
    }
    if (state.isLocating) {
      return _MessageCard(
        icon: null,
        title: gloc.getting_location,
        message: gloc.place_pick_hint,
      );
    }
    if (state.locationUnavailable) {
      return _MessageCard(
        icon: Icons.location_disabled_outlined,
        title: gloc.location_error,
        message: gloc.place_location_unavailable,
      );
    }
    return null;
  }

  /// Keeps the selected point visible above the selection card.
  void _centerAboveCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      const cardHeight = 200.0;
      _controller.adjustMapCenterForBottomSheet(
        cardHeight,
        MediaQuery.of(context).size.height,
      );
    });
  }

  /// The selected point's address (it arrives while the card shows), its
  /// coordinates, and Confirm.
  Widget _buildSelectionCard(
    ThemeData theme,
    ColorScheme colorScheme,
    gen.AppLocalizations gloc,
  ) {
    final selected = _controller.state.selectedMapLocation!;
    final coords =
        '${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}';
    final address = _controller.state.selectedLocationAddress;
    return Material(
      color: colorScheme.raisedSurface,
      elevation: 3,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_controller.state.selectedIsUserLocation)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const _UserDot(size: 12),
                    const SizedBox(width: 8),
                    Text(
                      gloc.place_you_are_here,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            Semantics(
              liveRegion: true,
              child: _controller.state.isGeocodingLocation
                  ? Row(
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
                            gloc.finding_address,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    )
                  : Text(address ?? coords, style: theme.textTheme.bodyLarge),
            ),
            if (address != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  coords,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                NominatimPlace(
                  latitude: selected.latitude,
                  longitude: selected.longitude,
                  displayName: address ?? coords,
                ),
              ),
              child: Text(gloc.crop_confirm),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                gloc.place_pick_hint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The phone's position: a blue dot with a white ring and a soft halo.
class _UserDot extends StatelessWidget {
  final double size;
  const _UserDot({this.size = 32});

  /// The blue of "you are here" in every map app, in both themes.
  static const Color _blue = Color(0xFF1A73E8);

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _blue.withValues(alpha: 0.18),
        ),
        child: Center(
          child: Container(
            width: size * 0.55,
            height: size * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _blue,
              border: Border.all(color: Colors.white, width: size * 0.08),
            ),
          ),
        ),
      ),
    );
  }
}

/// A calm card on the map (raised surface, no red): an icon, or a spinner
/// when [icon] is null, a title, a line under it and an optional action.
class _MessageCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = theme.colorScheme;
    return Semantics(
      liveRegion: true,
      container: true,
      child: Material(
        color: s.raisedSurface,
        elevation: 3,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: icon == null
                    ? Padding(
                        padding: const EdgeInsets.all(3),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: s.primary,
                        ),
                      )
                    : Icon(icon, color: s.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: s.onSurfaceVariant,
                      ),
                    ),
                    if (actionLabel case final label?)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: OutlinedButton(
                          onPressed: onAction,
                          child: Text(label),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
