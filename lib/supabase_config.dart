import 'utils/env_config.dart';

/// Production-ready Supabase configuration that prioritizes security
///
/// This configuration uses environment variables for sensitive data
/// and falls back to local development configuration when available.
///
/// ⚠️ SECURITY WARNING: Never commit real credentials to git!
class SupabaseConfig {
  // Use environment variables for production security
  static String get supabaseUrl => EnvConfig.supabaseUrl;
  static String get supabaseAnonKey => EnvConfig.supabaseAnonKey;
  static String get googleClientIdWeb => EnvConfig.googleClientIdWeb;

  // Environment detection
  static bool get isProduction => EnvConfig.isProduction;
  static bool get isDevelopment => EnvConfig.isDevelopment;

  // URLs
  static String get baseUrl => EnvConfig.baseUrl;
  static String get redirectUrl => EnvConfig.authRedirectUrl;

  // Authentication configuration
  static const Map<String, String> authConfig = {
    'flowType': 'pkce', // More secure than implicit flow
  };

  /// Initialize and validate configuration
  static void initialize() {
    EnvConfig.validateConfig();
    EnvConfig.printConfigStatus();
  }

  /// Check if configuration is properly set up
  static bool get isConfigured => EnvConfig.isConfigured;
}
