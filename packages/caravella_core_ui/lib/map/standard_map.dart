import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'map_tile_layer.dart';

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

  const StandardMap({
    super.key,
    this.mapController,
    required this.initialCenter,
    this.initialZoom = 14,
    this.minZoom = 2,
    this.maxZoom = 18,
    this.onTap,
    this.layers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        minZoom: minZoom,
        maxZoom: maxZoom,
        onTap: onTap,
      ),
      children: [const MapTileLayerWidget(), ...layers],
    );
  }
}
