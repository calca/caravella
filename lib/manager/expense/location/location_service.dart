import 'package:flutter/material.dart';
import 'package:caravella_core/caravella_core.dart';
import 'repository/location_repository.dart';
import 'repository/location_repository_impl.dart';
import '../errors/expense_error_handler.dart';

/// Service class to handle location retrieval and geocoding
/// Now uses LocationRepository for better testability and separation of concerns
class LocationService {
  static final LocationRepository _repository = LocationRepositoryImpl();

  /// Retrieves the current location with optional reverse geocoding
  static Future<ExpenseLocation?> getCurrentLocation(
    BuildContext context, {
    bool resolveAddress = true,
    Function(bool)? onStatusChanged,
  }) async {
    onStatusChanged?.call(true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await _repository.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          ExpenseErrorHandler.showLocationServiceDisabled(context);
        }
        return null;
      }

      // Check and request permission
      LocationPermissionStatus permission = await _repository.checkPermission();
      if (permission == LocationPermissionStatus.denied) {
        permission = await _repository.requestPermission();
        if (permission == LocationPermissionStatus.denied) {
          if (context.mounted) {
            ExpenseErrorHandler.showLocationPermissionDenied(context);
          }
          return null;
        }
      }

      if (permission == LocationPermissionStatus.deniedForever) {
        if (context.mounted) {
          ExpenseErrorHandler.showLocationPermissionDeniedForever(context);
        }
        return null;
      }

      // Get current location through repository
      final location = await _repository.getCurrentLocation(
        resolveAddress: resolveAddress,
      );

      if (location == null && context.mounted) {
        ExpenseErrorHandler.showLocationTimeoutError(context);
      }

      return location;
    } catch (e) {
      if (context.mounted) {
        ExpenseErrorHandler.showLocationRetrievalError(context, e.toString());
      }
      return null;
    } finally {
      onStatusChanged?.call(false);
    }
  }
}
