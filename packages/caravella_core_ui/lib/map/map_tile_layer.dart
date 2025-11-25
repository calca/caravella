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
      errorTileCallback: (tile, error, stackTrace) {
        // Log but don't crash - tiles will show as blank
        debugPrint('Tile load error: $error');
      },
    );
  }
}
