import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:io_caravella_egm/l10n/app_localizations.dart' as gen;
import 'package:caravella_core_ui/caravella_core_ui.dart';
import 'package:caravella_core/caravella_core.dart';

/// Service class to handle location retrieval and geocoding
class LocationService {
  /// Retrieves the current location with optional reverse geocoding
  static Future<ExpenseLocation?> getCurrentLocation(
    BuildContext context, {
    bool resolveAddress = true,
    Function(bool)? onStatusChanged,
  }) async {
    onStatusChanged?.call(true);
    final messenger = ScaffoldMessenger.of(context);
    final gloc = gen.AppLocalizations.of(context);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          AppToast.showFromMessenger(
            messenger,
            gloc.location_service_disabled,
            type: ToastType.info,
          );
        }
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            AppToast.showFromMessenger(
              messenger,
              gloc.location_permission_denied,
              type: ToastType.info,
            );
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          AppToast.showFromMessenger(
            messenger,
            gloc.location_permission_denied,
            type: ToastType.error,
          );
        }
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String? address;
      if (resolveAddress) {
        try {
          final placemarks = await geocoding.placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          );
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            final parts = [
              if ((p.thoroughfare ?? '').isNotEmpty) p.thoroughfare,
              if ((p.subThoroughfare ?? '').isNotEmpty) p.subThoroughfare,
              if ((p.locality ?? '').isNotEmpty) p.locality,
              if ((p.administrativeArea ?? '').isNotEmpty) p.administrativeArea,
              if ((p.country ?? '').isNotEmpty) p.country,
            ].whereType<String>().where((e) => e.trim().isNotEmpty).toList();
            if (parts.isNotEmpty) {
              address = parts.join(', ');
            }
          }
        } catch (_) {
          // Ignore reverse geocoding failure
        }
      }

      return ExpenseLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );
    } catch (e) {
      if (context.mounted) {
        AppToast.showFromMessenger(
          messenger,
          gloc.location_error,
          type: ToastType.error,
        );
      }
      return null;
    } finally {
      onStatusChanged?.call(false);
    }
  }
}
