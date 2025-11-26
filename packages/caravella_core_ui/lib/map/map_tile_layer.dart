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
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: userAgentPackageName,
      maxZoom: maxZoom,
      tileProvider: NetworkTileProvider(),
      keepBuffer: 2,
      // Evict error tiles immediately to retry on next pan/zoom
      evictErrorTileStrategy: EvictErrorTileStrategy.notVisibleRespectMargin,
      errorTileCallback: (tile, error, stackTrace) {
        // Silently handle tile errors - tiles will show as blank
        // This prevents network errors from blocking the UI
        debugPrint('Tile load error (non-blocking): $error');
      },
    );
  }
}
