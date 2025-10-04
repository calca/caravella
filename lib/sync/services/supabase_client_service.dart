import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/services/logger_service.dart';
import '../models/supabase_config.dart';

/// Singleton Supabase client manager
class SupabaseClientService {
  static final SupabaseClientService _instance =
      SupabaseClientService._internal();
  factory SupabaseClientService() => _instance;
  SupabaseClientService._internal();

  SupabaseClient? _client;
  bool _initialized = false;

  /// Initialize Supabase with configuration
  Future<bool> initialize(SupabaseConfig config) async {
    if (_initialized) {
      LoggerService.warning('Supabase already initialized');
      return true;
    }

    if (!config.isConfigured) {
      LoggerService.warning('Supabase configuration not provided, skipping initialization');
      return false;
    }

    try {
      await Supabase.initialize(
        url: config.url,
        anonKey: config.anonKey,
        realtimeClientOptions: const RealtimeClientOptions(
          eventsPerSecond: 10,
        ),
      );

      _client = Supabase.instance.client;
      _initialized = true;

      LoggerService.info('Supabase initialized successfully');
      return true;
    } catch (e) {
      LoggerService.error('Failed to initialize Supabase: $e');
      return false;
    }
  }

  /// Get the Supabase client instance
  SupabaseClient? get client => _client;

  /// Check if Supabase is initialized and ready
  bool get isInitialized => _initialized && _client != null;

  /// Get realtime channels
  RealtimeClient? get realtime => _client?.realtime;

  /// Dispose and cleanup
  Future<void> dispose() async {
    if (_client != null) {
      await _client!.dispose();
      _client = null;
      _initialized = false;
      LoggerService.info('Supabase client disposed');
    }
  }
}
