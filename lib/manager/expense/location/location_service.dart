import 'package:io_caravella_egm/services/permission_dialog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:caravella_core/caravella_core.dart';
import 'repository/location_repository.dart';
import 'repository/location_repository_impl.dart';
import '../errors/expense_error_handler.dart';

/// Why [LocationService.getCurrentLocation] found no position.
enum LocationProblem {
  serviceDisabled,
  permissionDenied,
  deniedForever,
  notFound,
}

/// Service class to handle location retrieval and geocoding
/// Now uses LocationRepository for better testability and separation of concerns
class LocationService {
  static final LocationRepository _repository = LocationRepositoryImpl();

  /// Retrieves the current location with optional reverse geocoding.
  ///
  /// Without a position, [onProblem] gets why (the caller shows it in
  /// place); without [onProblem], a toast says it.
  static Future<ExpenseLocation?> getCurrentLocation(
    BuildContext context, {
    bool resolveAddress = true,
    Function(bool)? onStatusChanged,
    void Function(LocationProblem problem)? onProblem,
  }) async {
    onStatusChanged?.call(true);

    void report(LocationProblem problem, [Object? error]) {
      if (error != null) {
        LoggerService.warning('Location retrieval failed: $error', name: 'ui');
      }
      if (onProblem != null) return onProblem(problem);
      if (!context.mounted) return;
      switch (problem) {
        case LocationProblem.serviceDisabled:
          ExpenseErrorHandler.showLocationServiceDisabled(context);
        case LocationProblem.permissionDenied:
          ExpenseErrorHandler.showLocationPermissionDenied(context);
        case LocationProblem.deniedForever:
          showPermissionDeniedDialog(context, DeniedPermission.location);
        case LocationProblem.notFound:
          ExpenseErrorHandler.showLocationRetrievalError(context);
      }
    }

    try {
      // Check if location services are enabled
      bool serviceEnabled = await _repository.isLocationServiceEnabled();
      if (!serviceEnabled) {
        report(LocationProblem.serviceDisabled);
        return null;
      }

      // Check and request permission
      LocationPermissionStatus permission = await _repository.checkPermission();
      if (permission == LocationPermissionStatus.denied) {
        permission = await _repository.requestPermission();
        if (permission == LocationPermissionStatus.denied) {
          report(LocationProblem.permissionDenied);
          return null;
        }
      }

      if (permission == LocationPermissionStatus.deniedForever) {
        report(LocationProblem.deniedForever);
        return null;
      }

      // Get current location through repository
      final location = await _repository.getCurrentLocation(
        resolveAddress: resolveAddress,
      );

      if (location == null) report(LocationProblem.notFound);

      return location;
    } catch (e) {
      report(LocationProblem.notFound, e);
      return null;
    } finally {
      onStatusChanged?.call(false);
    }
  }
}
