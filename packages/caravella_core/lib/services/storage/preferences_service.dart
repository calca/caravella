import 'package:shared_preferences/shared_preferences.dart';

/// Preference keys organized by category for better maintainability
abstract class _PreferenceKeys {
  // Locale
  static const String locale = 'selected_locale';

  // Theme
  static const String themeMode = 'theme_mode';

  // Security
  static const String flagSecure = 'flag_secure_enabled';

  // User
  static const String userName = 'user_name';

  // Backup
  static const String autoBackupEnabled = 'auto_backup_enabled';
  static const String lastAutoBackup = 'last_auto_backup';

  // Store Rating
  static const String totalExpenseCount = 'total_expense_count';
  static const String lastRatingPrompt = 'last_rating_prompt';
  static const String hasShownInitialRating = 'has_shown_initial_rating';

  // App State
  static const String hasCreatedGroup = 'has_created_group';
}

/// Default values for preferences
abstract class _PreferenceDefaults {
  static const String locale = 'it';
  static const String themeMode = 'system';
  static const bool flagSecure = true;
  static const bool autoBackupEnabled = false;
  static const int totalExpenseCount = 0;
  static const bool hasShownInitialRating = false;
  static const bool hasCreatedGroup = false;
}

/// Centralized service for managing SharedPreferences.
///
/// Provides type-safe, organized access to app preferences with consistent
/// naming conventions and default values. Uses a singleton pattern for
/// efficient instance management.
///
/// Usage:
/// ```dart
/// final prefs = PreferencesService.instance;
/// await prefs.locale.set('en');
/// final locale = await prefs.locale.get();
/// ```
class PreferencesService {
  PreferencesService._(this._prefs);

  final SharedPreferences _prefs;

  // Singleton instance
  static PreferencesService? _instance;

  /// Get the singleton instance of PreferencesService
  static PreferencesService get instance {
    if (_instance == null) {
      throw StateError(
        'PreferencesService not initialized. Call PreferencesService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Initialize the PreferencesService singleton
  static Future<PreferencesService> initialize() async {
    if (_instance != null) return _instance!;

    final prefs = await SharedPreferences.getInstance();
    _instance = PreferencesService._(prefs);
    return _instance!;
  }

  /// Reset the singleton instance (useful for testing)
  static void reset() {
    _instance = null;
  }

  // ============================================================================
  // Locale Preferences
  // ============================================================================

  /// Locale preferences management
  LocalePreferences get locale => LocalePreferences._(_prefs);

  // ============================================================================
  // Theme Preferences
  // ============================================================================

  /// Theme preferences management
  ThemePreferences get theme => ThemePreferences._(_prefs);

  // ============================================================================
  // Security Preferences
  // ============================================================================

  /// Security preferences management
  SecurityPreferences get security => SecurityPreferences._(_prefs);

  // ============================================================================
  // User Preferences
  // ============================================================================

  /// User preferences management
  UserPreferences get user => UserPreferences._(_prefs);

  // ============================================================================
  // Backup Preferences
  // ============================================================================

  /// Backup preferences management
  BackupPreferences get backup => BackupPreferences._(_prefs);

  // ============================================================================
  // Store Rating Preferences
  // ============================================================================

  /// Store rating preferences management
  StoreRatingPreferences get storeRating => StoreRatingPreferences._(_prefs);

  // ============================================================================
  // App State Preferences
  // ============================================================================

  /// App state preferences management
  AppStatePreferences get appState => AppStatePreferences._(_prefs);

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Clear all preferences (useful for testing or reset)
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  /// Remove a specific preference by key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Check if a preference exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Get all stored keys
  Set<String> getAllKeys() {
    return _prefs.getKeys();
  }
}

// ==============================================================================
// Locale Preferences
// ==============================================================================

/// Manages locale-related preferences
class LocalePreferences {
  LocalePreferences._(this._prefs);
  final SharedPreferences _prefs;

  /// Get the user's selected locale (default: 'it')
  String get() {
    return _prefs.getString(_PreferenceKeys.locale) ??
        _PreferenceDefaults.locale;
  }

  /// Set the user's selected locale
  Future<void> set(String locale) async {
    await _prefs.setString(_PreferenceKeys.locale, locale);
  }
}

// ==============================================================================
// Theme Preferences
// ==============================================================================

/// Manages theme-related preferences
class ThemePreferences {
  ThemePreferences._(this._prefs);
  final SharedPreferences _prefs;

  /// Get the user's selected theme mode (default: 'system')
  String get() {
    return _prefs.getString(_PreferenceKeys.themeMode) ??
        _PreferenceDefaults.themeMode;
  }

  /// Set the user's selected theme mode
  Future<void> set(String mode) async {
    await _prefs.setString(_PreferenceKeys.themeMode, mode);
  }
}

// ==============================================================================
// Security Preferences
// ==============================================================================

/// Manages security-related preferences
class SecurityPreferences {
  SecurityPreferences._(this._prefs);
  final SharedPreferences _prefs;

  /// Get flag secure enabled status (default: true)
  bool getFlagSecureEnabled() {
    return _prefs.getBool(_PreferenceKeys.flagSecure) ??
        _PreferenceDefaults.flagSecure;
  }

  /// Set flag secure enabled status
  Future<void> setFlagSecureEnabled(bool enabled) async {
    await _prefs.setBool(_PreferenceKeys.flagSecure, enabled);
  }
}

// ==============================================================================
// User Preferences
// ==============================================================================

/// Manages user-related preferences
class UserPreferences {
  UserPreferences._(this._prefs);
  final SharedPreferences _prefs;

  /// Get the user's display name
  String? getName() {
    return _prefs.getString(_PreferenceKeys.userName);
  }

  /// Set the user's display name
  Future<void> setName(String? name) async {
    if (name != null) {
      await _prefs.setString(_PreferenceKeys.userName, name);
    } else {
      await _prefs.remove(_PreferenceKeys.userName);
    }
  }
}

// ==============================================================================
// Backup Preferences
// ==============================================================================

/// Manages backup-related preferences
class BackupPreferences {
  BackupPreferences._(this._prefs);
  final SharedPreferences _prefs;

  /// Get auto backup enabled status (default: false)
  bool isAutoBackupEnabled() {
    return _prefs.getBool(_PreferenceKeys.autoBackupEnabled) ??
        _PreferenceDefaults.autoBackupEnabled;
  }

  /// Set auto backup enabled status
  Future<void> setAutoBackupEnabled(bool enabled) async {
    await _prefs.setBool(_PreferenceKeys.autoBackupEnabled, enabled);
  }

  /// Get last auto backup timestamp
  DateTime? getLastAutoBackupTime() {
    final timestamp = _prefs.getInt(_PreferenceKeys.lastAutoBackup);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Set last auto backup timestamp
  Future<void> setLastAutoBackupTime(DateTime timestamp) async {
    await _prefs.setInt(
      _PreferenceKeys.lastAutoBackup,
      timestamp.millisecondsSinceEpoch,
    );
  }
}

// ==============================================================================
// Store Rating Preferences
// ==============================================================================

/// Manages store rating-related preferences
class StoreRatingPreferences {
  StoreRatingPreferences._(this._prefs);
  final SharedPreferences _prefs;

  /// Get total expense count across all groups
  int getTotalExpenseCount() {
    return _prefs.getInt(_PreferenceKeys.totalExpenseCount) ??
        _PreferenceDefaults.totalExpenseCount;
  }

  /// Set total expense count
  Future<void> setTotalExpenseCount(int count) async {
    await _prefs.setInt(_PreferenceKeys.totalExpenseCount, count);
  }

  /// Increment total expense count by 1
  Future<void> incrementExpenseCount() async {
    final current = getTotalExpenseCount();
    await setTotalExpenseCount(current + 1);
  }

  /// Get last rating prompt timestamp
  DateTime? getLastPromptTime() {
    final timestamp = _prefs.getInt(_PreferenceKeys.lastRatingPrompt);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Set last rating prompt timestamp
  Future<void> setLastPromptTime(DateTime timestamp) async {
    await _prefs.setInt(
      _PreferenceKeys.lastRatingPrompt,
      timestamp.millisecondsSinceEpoch,
    );
  }

  /// Clear last rating prompt timestamp (useful for testing)
  Future<void> clearLastPromptTime() async {
    await _prefs.remove(_PreferenceKeys.lastRatingPrompt);
  }

  /// Get whether initial rating prompt has been shown
  bool hasShownInitialPrompt() {
    return _prefs.getBool(_PreferenceKeys.hasShownInitialRating) ??
        _PreferenceDefaults.hasShownInitialRating;
  }

  /// Set whether initial rating prompt has been shown
  Future<void> setHasShownInitialPrompt(bool shown) async {
    await _prefs.setBool(_PreferenceKeys.hasShownInitialRating, shown);
  }
}

// ==============================================================================
// App State Preferences
// ==============================================================================

/// Manages app state-related preferences
class AppStatePreferences {
  AppStatePreferences._(this._prefs);
  final SharedPreferences _prefs;

  /// Get whether user has created at least one group (default: false)
  bool hasCreatedGroup() {
    return _prefs.getBool(_PreferenceKeys.hasCreatedGroup) ??
        _PreferenceDefaults.hasCreatedGroup;
  }

  /// Set whether user has created at least one group
  Future<void> setHasCreatedGroup(bool value) async {
    await _prefs.setBool(_PreferenceKeys.hasCreatedGroup, value);
  }
}
