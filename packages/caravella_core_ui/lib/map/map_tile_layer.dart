import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';

import 'map_tile_status.dart';

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

  /// Told of the tiles that load and fail, and asks to reload them.
  final MapTileStatus? status;

  const MapTileLayerWidget({
    super.key,
    this.maxZoom = 19.0,
    this.userAgentPackageName = 'io.caravella.egm',
    this.status,
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
      reset: status?.reset,
      tileBuilder: status == null
          ? null
          : (context, tileWidget, tile) {
              if (tile.loadFinishedAt != null && !tile.loadError) {
                status?.tileLoaded();
              }
              return tileWidget;
            },
      // Network errors are expected: they only reach the map's messages.
      errorTileCallback: (tile, error, stackTrace) => status?.tileFailed(),
    );
  }
}
