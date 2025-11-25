import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
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
  bool _isLoading = true;
  String? _errorMessage;
  List<ExpenseDetails> _expensesWithLocation = [];
  LatLngBounds? _bounds;
  Map<String, List<ExpenseDetails>> _groupedExpenses = {};

  @override
  void initState() {
    super.initState();
    // Offload processing to next frame to prevent UI blocking during navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processLocationData();
    });
  }

  Future<void> _processLocationData() async {
    // Yield execution to allow UI to render loading state
    await Future.delayed(const Duration(milliseconds: 50));

    if (!mounted) return;

    final expenses = widget.group.expenses;

    try {
      final expensesWithLocation = expenses.where((expense) {
        final location = expense.location;
        return location != null &&
            location.latitude != null &&
            location.longitude != null;
      }).toList();

      if (expensesWithLocation.isEmpty) {
        if (mounted) {
          setState(() {
            _expensesWithLocation = [];
            _isLoading = false;
            _errorMessage = null;
          });
        }
        return;
      }

      // Calculate bounds using shared utility
      final points = expensesWithLocation
          .map((e) => LatLng(e.location!.latitude!, e.location!.longitude!))
          .toList();
      final bounds = computeBounds(points);

      // Group expenses
      final Map<String, List<ExpenseDetails>> grouped = {};
      for (final expense in expensesWithLocation) {
        final location = expense.location;
        if (location == null ||
            location.latitude == null ||
            location.longitude == null) {
          continue;
        }
        final key =
            '${location.latitude!.toStringAsFixed(6)},${location.longitude!.toStringAsFixed(6)}';
        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }
        grouped[key]!.add(expense);
      }

      if (mounted) {
        setState(() {
          _expensesWithLocation = expensesWithLocation;
          _bounds = bounds;
          _groupedExpenses = grouped;
          _isLoading = false;
          _errorMessage = null;
        });

        // Fit camera after layout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _bounds != null) {
            try {
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: _bounds!,
                  padding: const EdgeInsets.all(50),
                ),
              );
            } catch (_) {
              // Ignore map camera errors (e.g., when map is not ready)
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
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
    if (_groupedExpenses.isEmpty) return [];

    final colorScheme = Theme.of(context).colorScheme;

    return _groupedExpenses.entries.map((entry) {
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

    final appBar = AppBar(
      title: Text(gloc.expenses_map),
      backgroundColor: colorScheme.surface,
    );

    if (_isLoading) {
      return Scaffold(
        appBar: appBar,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: appBar,
        body: MapErrorState(
          title: gloc.location_error,
          message: _errorMessage!,
        ),
      );
    }

    if (_expensesWithLocation.isEmpty) {
      return Scaffold(
        appBar: appBar,
        body: MapEmptyState(
          title: gloc.no_locations_available,
          subtitle: gloc.no_locations_subtitle,
        ),
      );
    }

    final hasBounds = _bounds != null;
    final center = hasBounds
        ? LatLng(
            (_bounds!.northEast.latitude + _bounds!.southWest.latitude) / 2,
            (_bounds!.northEast.longitude + _bounds!.southWest.longitude) / 2,
          )
        : LatLng(
            _expensesWithLocation.first.location!.latitude!,
            _expensesWithLocation.first.location!.longitude!,
          );

    return Scaffold(
      appBar: appBar,
      body: StandardMap(
        mapController: _mapController,
        initialCenter: center,
        initialZoom: hasBounds ? 12 : 14,
        minZoom: 2,
        maxZoom: 18,
        layers: [MarkerLayer(markers: _buildMarkers())],
      ),
    );
  }
}
