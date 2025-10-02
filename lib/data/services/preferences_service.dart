import 'package:shared_preferences/shared_preferences.dart';

/// Centralized service for managing SharedPreferences
/// Provides type-safe access to app preferences with consistent naming
class PreferencesService {
  static SharedPreferences? _instance;
  
  /// Get SharedPreferences instance (cached)
  static Future<SharedPreferences> get _prefs async {
    _instance ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  // Locale preferences
  static const String _localeKey = 'selected_locale';
  
  /// Get the user's selected locale (default: 'it')
  static Future<String> getLocale() async {
    final prefs = await _prefs;
    return prefs.getString(_localeKey) ?? 'it';
  }
  
  /// Set the user's selected locale
  static Future<void> setLocale(String locale) async {
    final prefs = await _prefs;
    await prefs.setString(_localeKey, locale);
  }
  
  // Theme preferences
  static const String _themeModeKey = 'theme_mode';
  
  /// Get the user's selected theme mode (default: 'system')
  static Future<String> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_themeModeKey) ?? 'system';
  }
  
  /// Set the user's selected theme mode
  static Future<void> setThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeModeKey, mode);
  }
  
  // Flag secure preferences
  static const String _flagSecureKey = 'flag_secure_enabled';
  
  /// Get flag secure enabled status (default: true)
  static Future<bool> getFlagSecureEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_flagSecureKey) ?? true;
  }
  
  /// Set flag secure enabled status
  static Future<void> setFlagSecureEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_flagSecureKey, enabled);
  }
  
  // User name preferences
  static const String _userNameKey = 'user_name';
  
  /// Get the user's display name
  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(_userNameKey);
  }
  
  /// Set the user's display name
  static Future<void> setUserName(String? name) async {
    final prefs = await _prefs;
    if (name != null) {
      await prefs.setString(_userNameKey, name);
    } else {
      await prefs.remove(_userNameKey);
    }
  }
  
  // Auto backup preferences
  static const String _autoBackupEnabledKey = 'auto_backup_enabled';
  static const String _lastAutoBackupKey = 'last_auto_backup';
  
  /// Get auto backup enabled status (default: false)
  static Future<bool> getAutoBackupEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_autoBackupEnabledKey) ?? false;
  }
  
  /// Set auto backup enabled status
  static Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_autoBackupEnabledKey, enabled);
  }
  
  /// Get last auto backup timestamp
  static Future<DateTime?> getLastAutoBackup() async {
    final prefs = await _prefs;
    final timestamp = prefs.getInt(_lastAutoBackupKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
  
  /// Set last auto backup timestamp
  static Future<void> setLastAutoBackup(DateTime timestamp) async {
    final prefs = await _prefs;
    await prefs.setInt(_lastAutoBackupKey, timestamp.millisecondsSinceEpoch);
  }
  
  /// Clear all preferences (useful for testing or reset)
  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
    _instance = null; // Force re-initialization
  }
  
  /// Remove a specific preference by key
  static Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }
  
  /// Check if a preference exists
  static Future<bool> containsKey(String key) async {
    final prefs = await _prefs;
    return prefs.containsKey(key);
  }
  
  // Store rating preferences
  static const String _totalExpenseCountKey = 'total_expense_count';
  static const String _lastRatingPromptKey = 'last_rating_prompt';
  static const String _hasShownInitialRatingKey = 'has_shown_initial_rating';
  
  /// Get total expense count across all groups
  static Future<int> getTotalExpenseCount() async {
    final prefs = await _prefs;
    return prefs.getInt(_totalExpenseCountKey) ?? 0;
  }
  
  /// Set total expense count
  static Future<void> setTotalExpenseCount(int count) async {
    final prefs = await _prefs;
    await prefs.setInt(_totalExpenseCountKey, count);
  }
  
  /// Get last rating prompt timestamp
  static Future<DateTime?> getLastRatingPrompt() async {
    final prefs = await _prefs;
    final timestamp = prefs.getInt(_lastRatingPromptKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
  
  /// Set last rating prompt timestamp
  static Future<void> setLastRatingPrompt(DateTime timestamp) async {
    final prefs = await _prefs;
    await prefs.setInt(_lastRatingPromptKey, timestamp.millisecondsSinceEpoch);
  }
  
  /// Get whether initial rating prompt has been shown
  static Future<bool> getHasShownInitialRating() async {
    final prefs = await _prefs;
    return prefs.getBool(_hasShownInitialRatingKey) ?? false;
  }
  
  /// Set whether initial rating prompt has been shown
  static Future<void> setHasShownInitialRating(bool shown) async {
    final prefs = await _prefs;
    await prefs.setBool(_hasShownInitialRatingKey, shown);
  }
}