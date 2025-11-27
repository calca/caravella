import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Centralized OpenStreetMap tile layer configuration with error handling
///
/// Provides a consistent tile layer setup across the app with:
/// - Error handling for network issues
/// - Optimized tile loading
/// - Consistent tile provider configuration
class MapTileLayerWidget extends StatelessWidget {
  /// The maximum zoom level for tiles
  final double maxZoom;

  /// The user agent package name for tile requests
  final String userAgentPackageName;

  const MapTileLayerWidget({
    super.key,
    this.maxZoom = 19.0,
    this.userAgentPackageName = 'io.caravella.egm',
  });

  @override
  Widget build(BuildContext context) {
    // Detect theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Use CartoDB Dark Matter for dark theme, standard OSM for light theme
    final urlTemplate = isDarkMode
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    
    return TileLayer(
      urlTemplate: urlTemplate,
      subdomains: isDarkMode ? const ['a', 'b', 'c', 'd'] : const [],
      userAgentPackageName: userAgentPackageName,
      maxZoom: maxZoom,
      tileProvider: NetworkTileProvider(),
      keepBuffer: 2,
      // Evict error tiles immediately to retry on next pan/zoom
      evictErrorTileStrategy: EvictErrorTileStrategy.notVisibleRespectMargin,
      errorTileCallback: (tile, error, stackTrace) {
        // Completely swallow all tile errors - prevent any propagation
        // Network errors are expected and should not affect the UI
        try {
          // Only log in debug builds if absolutely necessary
          // debugPrint('Tile load error (non-blocking): $error');
        } catch (_) {
          // Even the error callback should not throw
        }
      },
      // Add attribution for CartoDB when using dark theme
      additionalOptions: isDarkMode
          ? const {
              'attribution':
                  '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
            }
          : const {},
    );
  }
}
