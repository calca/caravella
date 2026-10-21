import 'package:caravella_core/caravella_core.dart';
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:material_ui/material_ui.dart';
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

      if (mounted) {
        setState(() {
          _expensesWithLocation = expensesWithLocation;
          _bounds = bounds;
          _isLoading = false;
          _errorMessage = null;
        });

        // Fit camera after map is fully initialized
        // Use a timer to ensure map is ready before fitting camera
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _bounds != null) {
            try {
              _mapController.fitCamera(
                CameraFit.bounds(
                  bounds: _bounds!,
                  padding: const EdgeInsets.all(50),
                ),
              );
            } catch (e) {
              // Silently ignore map camera errors
              // Map might not be ready or already disposed
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

  /// Pins closer than this on screen are merged into one numbered pin, so
  /// nearby expenses don't stack on top of each other (only the top one
  /// would be tappable). Re-evaluated on every zoom/pan: zooming in splits
  /// a group back into separate pins.
  static const double _clusterRadius = 44;

  /// Groups expenses whose pins would overlap at the current [camera].
  List<List<ExpenseDetails>> _clusterExpenses(MapCamera camera) {
    final clusters = <({Offset anchor, List<ExpenseDetails> expenses})>[];
    for (final expense in _expensesWithLocation) {
      final offset = camera.latLngToScreenOffset(
        LatLng(expense.location!.latitude!, expense.location!.longitude!),
      );
      final index = clusters.indexWhere(
        (c) => (c.anchor - offset).distance < _clusterRadius,
      );
      if (index >= 0) {
        clusters[index].expenses.add(expense);
      } else {
        clusters.add((anchor: offset, expenses: [expense]));
      }
    }
    return [for (final c in clusters) c.expenses];
  }

  List<Marker> _buildMarkers(MapCamera camera) {
    if (_expensesWithLocation.isEmpty) return [];

    final colorScheme = Theme.of(context).colorScheme;
    final gloc = gen.AppLocalizations.of(context);

    return _clusterExpenses(camera).map((expenses) {
      final firstExpense = expenses.first;
      final location = LatLng(
        firstExpense.location!.latitude!,
        firstExpense.location!.longitude!,
      );
      final count = expenses.length;
      final place =
          firstExpense.location!.name ??
          firstExpense.location!.locality ??
          firstExpense.location!.address ??
          '';
      final markerLabel = count > 1
          ? gloc.accessibility_map_marker_group(count, place)
          : gloc.accessibility_map_marker_expense(
              firstExpense.name ?? '',
              CurrencyDisplay.formatCurrencyText(
                firstExpense.amount ?? 0,
                widget.group.currency,
              ),
            );

      return Marker(
        point: location,
        // At least 48dp so the pin is a comfortable touch target.
        width: count > 1 ? 60 : 48,
        height: count > 1 ? 60 : 48,
        child: Semantics(
          button: true,
          label: markerLabel,
          // The child GestureDetector's tap is excluded with the rest of the
          // subtree, so expose the action on this node.
          onTap: () => _showExpenseDetails(expenses),
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
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
                        border: Border.all(
                          color: colorScheme.surface,
                          width: 2,
                        ),
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
        ),
      );
    }).toList();
  }

  /// A plain page (loading, error, empty) with the round back button.
  Widget _plainPage(BuildContext context, Widget body) =>
      AppSystemUI.edgeToEdge(
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: RoundBackButton(),
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final gloc = gen.AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return _plainPage(
        context,
        const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return _plainPage(
        context,
        MapErrorState(title: gloc.location_error, message: _errorMessage!),
      );
    }

    if (_expensesWithLocation.isEmpty) {
      return _plainPage(
        context,
        MapEmptyState(
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

    // The map fills the screen; back and the group's name float over it.
    return AppSystemUI.edgeToEdge(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ErrorBoundary(
                child: StandardMap(
                  semanticLabel: gloc.expenses_map,
                  mapController: _mapController,
                  initialCenter: center,
                  initialZoom: hasBounds ? 12 : 14,
                  minZoom: 2,
                  maxZoom: 18,
                  layers: [
                    // Rebuilt on every camera change (MapCamera is
                    // inherited), so clustering follows the zoom level.
                    Builder(
                      builder: (context) => MarkerLayer(
                        markers: _buildMarkers(MapCamera.of(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      const RoundBackButton(),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Material(
                          color: colorScheme.raisedSurface,
                          shape: const StadiumBorder(),
                          elevation: 2,
                          shadowColor: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.group.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  gloc.expenses_map,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget to catch and handle errors in child widgets
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (e) {
          // Return empty container if child throws
          return const SizedBox.shrink();
        }
      },
    );
  }
}
