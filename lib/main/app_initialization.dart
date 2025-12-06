import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:caravella_core/caravella_core.dart';

import '../settings/flag_secure_android.dart';

/// Initializes the app: platform-specific setup, orientation, system UI, and image cache.
class AppInitialization {
  /// Configures error handling for Flutter framework errors
  static void configureErrorHandling() {
    // Handle Flutter framework errors (e.g., widget build errors)
    FlutterError.onError = (details) {
      // Network-related errors from tile loading are expected - silently ignore them
      final errorString = details.exception.toString();
      if (errorString.contains('NetworkImage') ||
          errorString.contains('SocketException') ||
          errorString.contains('Failed host lookup') ||
          errorString.contains('HttpException') ||
          errorString.contains('Connection') ||
          errorString.contains('NetworkTileImageProvider') ||
          errorString.contains('Image provider')) {
        // Silently ignore network-related errors from tile loading
        return;
      }

      // For other errors, log and show in debug mode
      LoggerService.warning('Flutter error: ${details.exception}');
      FlutterError.presentError(details);
    };

    // Handle errors from the platform dispatcher (isolate errors)
    PlatformDispatcher.instance.onError = (error, stack) {
      final errorString = error.toString();
      if (errorString.contains('NetworkImage') ||
          errorString.contains('SocketException') ||
          errorString.contains('Failed host lookup') ||
          errorString.contains('HttpException') ||
          errorString.contains('Connection') ||
          errorString.contains('NetworkTileImageProvider') ||
          errorString.contains('Image provider') ||
          errorString.contains('_loadImage') ||
          errorString.contains('TileLayer') ||
          errorString.contains('flutter_map') ||
          errorString.contains('MapController') ||
          errorString.contains('fitCamera')) {
        // Silently ignore network-related and map-related errors
        return true; // Mark as handled
      }

      // Log unexpected errors
      LoggerService.warning('Platform error: $error');
      return true; // Mark as handled to prevent crash
    };
  }

  /// Configures Android-specific image picker to use the native photo picker.
  static void configureImagePicker() {
    if (Platform.isAndroid) {
      final androidPicker = ImagePickerAndroid();
      androidPicker.useAndroidPhotoPicker = true;
      ImagePickerPlatform.instance = androidPicker;
    }
  }

  /// Sets the app environment based on the FLAVOR compile-time define.
  static void configureEnvironment() {
    const flavorString = String.fromEnvironment('FLAVOR', defaultValue: 'prod');
    switch (flavorString) {
      case 'dev':
        AppConfig.setEnvironment(Environment.dev);
        break;
      case 'staging':
        AppConfig.setEnvironment(Environment.staging);
        break;
      default:
        AppConfig.setEnvironment(Environment.prod);
    }
  }
  
  /// Initializes Hive storage system (default backend)
  /// Also handles automatic migration from JSON to Hive if needed
  static Future<void> initializeStorage() async {
    const backend = String.fromEnvironment('STORAGE_BACKEND', defaultValue: 'hive');
    if (backend.toLowerCase() == 'hive') {
      // Initialize Hive first
      await HiveInitializationService.initialize();
      
      // Then check and perform migration from JSON if needed
      await StorageMigrationService.migrateJsonToHiveIfNeeded();
    }
  }

  /// Locks the app to portrait orientation.
  static void lockOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Enables edge-to-edge mode on Android and sets transparent system bars.
  static void configureSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // Android 15+ compatible: transparent system bars
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Optimizes image cache for memory management.
  static void configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  }

  /// Initializes FLAG_SECURE on Android based on user preference.
  static Future<void> initFlagSecure() async {
    await PreferencesService.initialize();
    final enabled = PreferencesService.instance.security.getFlagSecureEnabled();
    await FlagSecureAndroid.setFlagSecure(enabled);
  }

  /// Runs all initialization steps in the correct order.
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    configureErrorHandling();
    configureImagePicker();
    configureEnvironment();
    await initializeStorage(); // Initialize storage (Hive if needed)
    lockOrientation();
    configureSystemUI();
    configureImageCache();
    await initFlagSecure();
  }
}
