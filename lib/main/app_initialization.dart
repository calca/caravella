import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_android/image_picker_android.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import '../config/app_config.dart';
import '../data/services/preferences_service.dart';
import '../data/services/hive_initialization_service.dart';
import '../settings/flag_secure_android.dart';

/// Initializes the app: platform-specific setup, orientation, system UI, and image cache.
class AppInitialization {
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
  
  /// Initializes Hive storage system if STORAGE_BACKEND is set to 'hive'
  static Future<void> initializeStorage() async {
    const backend = String.fromEnvironment('STORAGE_BACKEND', defaultValue: 'file');
    if (backend.toLowerCase() == 'hive') {
      await HiveInitializationService.initialize();
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
    configureImagePicker();
    configureEnvironment();
    await initializeStorage(); // Initialize storage (Hive if needed)
    lockOrientation();
    configureSystemUI();
    configureImageCache();
    await initFlagSecure();
  }
}
