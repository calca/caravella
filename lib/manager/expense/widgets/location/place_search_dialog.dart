import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'nominatim_place.dart';
import 'nominatim_search_service.dart';

export 'nominatim_place.dart';

/// Full-screen page for searching places using OpenStreetMap Nominatim
/// Shows search results on an interactive map with an overlay list
class PlaceSearchDialog extends StatefulWidget {
  final String hintText;

  const PlaceSearchDialog({super.key, required this.hintText});

  @override
  State<PlaceSearchDialog> createState() => _PlaceSearchDialogState();

  /// Shows the place search page and returns the selected place
  static Future<NominatimPlace?> show(BuildContext context, String hintText) {
    return Navigator.of(context).push<NominatimPlace>(
      MaterialPageRoute(
        builder: (ctx) => PlaceSearchDialog(hintText: hintText),
      ),
    );
  }
}

class _PlaceSearchDialogState extends State<PlaceSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<NominatimPlace> _searchResults = [];
  bool _isSearching = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _errorMessage = '';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final results = await NominatimSearchService.searchPlaces(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map background
          if (_searchResults.isNotEmpty)
            _buildFullScreenMap(colorScheme)
          else
            Container(color: colorScheme.surfaceContainerLow),

          // Top search bar and results overlay
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(theme, colorScheme),
                if (_isSearching) _buildLoadingIndicator(),
                if (_errorMessage.isNotEmpty) _buildErrorMessage(colorScheme),
                if (!_isSearching && _searchResults.isNotEmpty)
                  _buildResultsOverlay(theme, colorScheme),
                if (!_isSearching &&
                    _searchResults.isEmpty &&
                    _searchController.text.isNotEmpty &&
                    _errorMessage.isEmpty)
                  _buildNoResultsMessage(theme, colorScheme),
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
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
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
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
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
      options: MapOptions(
        initialCenter: LatLng(
          _searchResults.first.latitude,
          _searchResults.first.longitude,
        ),
        initialZoom: 12.0,
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'io.caravella.egm',
        ),
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
                    Icon(Icons.place, color: colorScheme.primary, size: 20),
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
                        color: colorScheme.primary,
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
