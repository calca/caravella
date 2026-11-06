import 'package:material_ui/material_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'map_tile_layer.dart';
import 'map_tile_status.dart';

/// A thin convenience wrapper around [FlutterMap] applying common defaults
/// and always including the shared [MapTileLayerWidget].
class StandardMap extends StatelessWidget {
  final MapController? mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final double minZoom;
  final double maxZoom;
  final void Function(TapPosition, LatLng)? onTap;
  final List<Widget> layers;

  /// Accessible name of the map area (e.g. "Expenses Map"). Markers keep
  /// their own semantics nodes inside it.
  final String? semanticLabel;

  /// Follows the tiles, for [MapLoadingOverlay] and [MapUnavailableCard].
  final MapTileStatus? tileStatus;

  const StandardMap({
    super.key,
    this.mapController,
    required this.initialCenter,
    this.initialZoom = 14,
    this.minZoom = 2,
    this.maxZoom = 18,
    this.onTap,
    this.layers = const [],
    this.semanticLabel,
    this.tileStatus,
  });

  @override
  Widget build(BuildContext context) {
    final map = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        minZoom: minZoom,
        maxZoom: maxZoom,
        onTap: onTap,
        // Shows until the tiles arrive, or instead of them when offline:
        // flutter_map's default is a light grey, also in dark.
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      children: [
        MapTileLayerWidget(status: tileStatus),
        ...layers,
      ],
    );
    if (semanticLabel == null) return map;
    // container without explicitChildNodes: flutter_map's own tap/long-press
    // gesture merges into this labeled node instead of forming an unnamed
    // one; markers with their own Semantics still get separate nodes.
    return Semantics(container: true, label: semanticLabel, child: map);
  }
}
