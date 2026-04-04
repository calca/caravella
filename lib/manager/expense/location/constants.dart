import 'package:flutter/material.dart';

/// Consolidated constants for location subsystem
///
/// Centralizes all constants previously spread across multiple files
/// for easier maintenance and consistency.
class LocationConstants {
  LocationConstants._();

  // Widget constants
  static const IconData loadingIcon = Icons.location_searching;
  static const IconData successIcon = Icons.place;
  static const IconData clearIcon = Icons.close;

  static const double iconSize = 20.0;
  static const double loaderSize = 20.0;
  static const double loaderStrokeWidth = 2.0;

  // Service constants
  static const Duration locationTimeout = Duration(seconds: 10);

  // Search constants
  static const int searchResultLimit = 10;
  static const Duration searchDebounce = Duration(milliseconds: 500);
}
