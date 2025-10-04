import 'models/supabase_config.dart';
import 'services/supabase_client_service.dart';
import 'services/revenue_cat_service.dart';
import 'services/auth_service.dart';
import '../data/services/logger_service.dart';

/// Initialize the multi-device sync system
/// Call this during app startup, after other initializations
class SyncInitializer {
  static bool _initialized = false;

  /// Initialize sync system with Supabase and RevenueCat configuration
  /// Returns true if initialization was successful
  static Future<bool> initialize({
    SupabaseConfig? config,
    String? revenueCatApiKey,
  }) async {
    if (_initialized) {
      LoggerService.warning('Sync system already initialized');
      return true;
    }

    try {
      LoggerService.info('Initializing multi-device sync system...');

      // Use provided config or load from environment
      final syncConfig = config ?? SupabaseConfig.fromEnvironment();

      // Check if configuration is valid
      if (!syncConfig.isConfigured) {
        LoggerService.warning(
          'Supabase configuration not provided. '
          'Multi-device sync will be disabled. '
          'Set SUPABASE_URL and SUPABASE_ANON_KEY environment variables or '
          'pass a SupabaseConfig to enable sync.',
        );
        _initialized = true;
        return false;
      }

      // Initialize Supabase client
      final supabaseService = SupabaseClientService();
      final success = await supabaseService.initialize(syncConfig);

      if (!success) {
        LoggerService.error('Failed to initialize Supabase client');
        _initialized = true;
        return false;
      }

      // Initialize RevenueCat if API key is provided
      final rcApiKey = revenueCatApiKey ?? 
          const String.fromEnvironment('REVENUECAT_API_KEY', defaultValue: '');
      
      if (rcApiKey.isNotEmpty) {
        try {
          final revenueCat = RevenueCatService();
          
          // Get current user ID from auth if available
          final authService = AuthService();
          final userId = authService.currentUser?.id;
          
          await revenueCat.initialize(
            apiKey: rcApiKey,
            userId: userId,
          );
          
          LoggerService.info('RevenueCat initialized successfully');
        } catch (e) {
          LoggerService.error('Failed to initialize RevenueCat: $e');
          // Continue without RevenueCat
        }
      } else {
        LoggerService.warning(
          'RevenueCat API key not provided. '
          'Subscription features will be disabled. '
          'Set REVENUECAT_API_KEY environment variable to enable subscriptions.',
        );
      }

      _initialized = true;
      LoggerService.info('Multi-device sync system initialized successfully');
      return true;
    } catch (e) {
      LoggerService.error('Failed to initialize sync system: $e');
      _initialized = true;
      return false;
    }
  }

  /// Check if sync system is initialized
  static bool get isInitialized => _initialized;

  /// Dispose sync system (call on app shutdown)
  static Future<void> dispose() async {
    if (!_initialized) return;

    try {
      LoggerService.info('Disposing sync system...');
      final supabaseService = SupabaseClientService();
      await supabaseService.dispose();
      _initialized = false;
      LoggerService.info('Sync system disposed');
    } catch (e) {
      LoggerService.error('Failed to dispose sync system: $e');
    }
  }
}
