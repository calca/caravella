/// Configuration model for Supabase connection
class SupabaseConfig {
  final String url;
  final String anonKey;
  final bool enableRealtimeSync;

  const SupabaseConfig({
    required this.url,
    required this.anonKey,
    this.enableRealtimeSync = true,
  });

  /// Creates config from environment variables
  /// In production, these should be loaded from secure storage or build-time constants
  factory SupabaseConfig.fromEnvironment() {
    const url = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: '',
    );
    const anonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );

    return SupabaseConfig(
      url: url,
      anonKey: anonKey,
      enableRealtimeSync: url.isNotEmpty && anonKey.isNotEmpty,
    );
  }

  bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  @override
  String toString() =>
      'SupabaseConfig(url: ${url.isNotEmpty ? "configured" : "empty"}, '
      'anonKey: ${anonKey.isNotEmpty ? "configured" : "empty"}, '
      'enableRealtimeSync: $enableRealtimeSync)';
}
