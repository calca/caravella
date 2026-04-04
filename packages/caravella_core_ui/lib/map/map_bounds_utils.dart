import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

/// Utility helpers for working with map bounds.
///
/// Provides a single function [computeBounds] that returns a [LatLngBounds]
/// covering all provided points. If all points collapse to (almost) a single
/// location, a minimum span is enforced to avoid an overly aggressive zoom.
LatLngBounds? computeBounds(
  List<LatLng> points, {
  double minSpanDegrees = 0.002, // ~200m
}) {
  if (points.isEmpty) return null;

  double minLat = points.first.latitude;
  double maxLat = points.first.latitude;
  double minLng = points.first.longitude;
  double maxLng = points.first.longitude;

  for (final p in points) {
    if (p.latitude < minLat) minLat = p.latitude;
    if (p.latitude > maxLat) maxLat = p.latitude;
    if (p.longitude < minLng) minLng = p.longitude;
    if (p.longitude > maxLng) maxLng = p.longitude;
  }

  // Expand very small spans so fitCamera does not zoom too far in.
  if ((maxLat - minLat).abs() < minSpanDegrees / 20) {
    final expand = minSpanDegrees / 2;
    minLat -= expand;
    maxLat += expand;
  }
  if ((maxLng - minLng).abs() < minSpanDegrees / 20) {
    final expand = minSpanDegrees / 2;
    minLng -= expand;
    maxLng += expand;
  }

  return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
}
