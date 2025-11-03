import 'package:caravella_core/caravella_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;

import '../widgets/expense_map_detail_sheet.dart';

/// Page that displays expenses with location data on an OpenStreetMap
class ExpenseLocationsMapPage extends StatefulWidget {
  final ExpenseGroup group;

  const ExpenseLocationsMapPage({super.key, required this.group});

  @override
  State<ExpenseLocationsMapPage> createState() =>
      _ExpenseLocationsMapPageState();
}

class _ExpenseLocationsMapPageState extends State<ExpenseLocationsMapPage> {
  final MapController _mapController = MapController();
  List<ExpenseDetails> _expensesWithLocation = [];

  @override
  void initState() {
    super.initState();
    _loadExpensesWithLocation();

    // Fit bounds after the map is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bounds = _calculateBounds();
      if (bounds != null) {
        _mapController.fitCamera(
          CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
        );
      }
    });
  }

  void _loadExpensesWithLocation() {
    _expensesWithLocation = widget.group.expenses
        .where(
          (expense) =>
              expense.location != null && expense.location!.hasLocation,
        )
        .toList();
  }

  /// Calculate bounds to fit all expense locations
  LatLngBounds? _calculateBounds() {
    if (_expensesWithLocation.isEmpty) return null;

    double minLat = _expensesWithLocation.first.location!.latitude!;
    double maxLat = _expensesWithLocation.first.location!.latitude!;
    double minLng = _expensesWithLocation.first.location!.longitude!;
    double maxLng = _expensesWithLocation.first.location!.longitude!;

    for (final expense in _expensesWithLocation) {
      final lat = expense.location!.latitude!;
      final lng = expense.location!.longitude!;

      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    return LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));
  }

  /// Group expenses by location (for clustering)
  Map<String, List<ExpenseDetails>> _groupExpensesByLocation() {
    final Map<String, List<ExpenseDetails>> grouped = {};

    for (final expense in _expensesWithLocation) {
      final key =
          '${expense.location!.latitude!.toStringAsFixed(6)},${expense.location!.longitude!.toStringAsFixed(6)}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(expense);
    }

    return grouped;
  }

  void _showExpenseDetails(List<ExpenseDetails> expenses) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ExpenseMapDetailSheet(
        expenses: expenses,
        currency: widget.group.currency,
      ),
    );
  }

  List<Marker> _buildMarkers() {
    final grouped = _groupExpensesByLocation();
    final colorScheme = Theme.of(context).colorScheme;

    return grouped.entries.map((entry) {
      final expenses = entry.value;
      final firstExpense = expenses.first;
      final location = LatLng(
        firstExpense.location!.latitude!,
        firstExpense.location!.longitude!,
      );
      final count = expenses.length;

      return Marker(
        point: location,
        width: count > 1 ? 60 : 40,
        height: count > 1 ? 60 : 40,
        child: GestureDetector(
          onTap: () => _showExpenseDetails(expenses),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.location_on,
                size: count > 1 ? 44 : 40,
                color: colorScheme.primary,
              ),
              if (count > 1)
                Positioned(
                  top: 2,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    child: Center(
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (_expensesWithLocation.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(gloc.expenses_map),
          backgroundColor: colorScheme.surface,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map_outlined,
                  size: 80,
                  color: colorScheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  gloc.no_locations_available,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  gloc.no_locations_subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bounds = _calculateBounds();

    return Scaffold(
      appBar: AppBar(
        title: Text(gloc.expenses_map),
        backgroundColor: colorScheme.surface,
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: bounds != null
              ? LatLng(
                  (bounds.northWest.latitude + bounds.southEast.latitude) / 2,
                  (bounds.northWest.longitude + bounds.southEast.longitude) / 2,
                )
              : const LatLng(0, 0),
          initialZoom: 2,
          minZoom: 2,
          maxZoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'io.caravella.egm',
            maxZoom: 19,
          ),
          MarkerLayer(markers: _buildMarkers()),
        ],
      ),
    );
  }
}
