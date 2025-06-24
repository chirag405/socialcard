import 'package:flutter/foundation.dart';

/// Environment configuration handler for sensitive data
/// This class handles loading configuration from environment variables
/// and build-time definitions to keep sensitive data out of source code.
class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  /// Supabase configuration from environment variables
  /// These should be set at build time using --dart-define
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: _defaultSupabaseUrl,
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: _defaultSupabaseAnonKey,
  );

  /// Google OAuth configuration
  static const String googleClientIdWeb = String.fromEnvironment(
    'GOOGLE_CLIENT_ID_WEB',
    defaultValue: _defaultGoogleClientIdWeb,
  );

  // Default values for development (SHOULD BE REPLACED)
  // ⚠️ WARNING: These are placeholder values for development only
  // ⚠️ Replace with your actual credentials using environment variables
  static const String _defaultSupabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String _defaultSupabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
  static const String _defaultGoogleClientIdWeb = 'YOUR_GOOGLE_CLIENT_ID_HERE';

  /// Check if configuration is properly set up
  static bool get isConfigured {
    return supabaseUrl != _defaultSupabaseUrl &&
        supabaseAnonKey != _defaultSupabaseAnonKey &&
        supabaseUrl.startsWith('https://') &&
        supabaseAnonKey.startsWith('eyJ'); // JWT tokens start with eyJ
  }

  /// Get environment-specific configuration
  static bool get isProduction =>
      const bool.fromEnvironment('PRODUCTION', defaultValue: false);

  static bool get isDevelopment => !isProduction;

  /// Base URLs for different environments
  static String get baseDomain =>
      isProduction ? 'your-domain.com' : 'localhost:3000';

  static String get baseUrl =>
      isProduction ? 'https://$baseDomain' : 'http://$baseDomain';

  /// Redirect URLs for OAuth
  static String get authRedirectUrl =>
      isProduction
          ? 'https://$baseDomain/auth-callback.html'
          : 'http://$baseDomain/auth-callback.html';

  /// Validate configuration and throw helpful errors
  static void validateConfig() {
    if (!isConfigured) {
      throw ConfigurationException('''
🚨 CONFIGURATION ERROR: Supabase credentials not configured!

To fix this issue:

1. For Development:
   Copy the template file and add your credentials:
   cp lib/supabase_config.template.dart lib/supabase_config.dart
   
   Then edit lib/supabase_config.dart with your actual Supabase credentials.

2. For Production/CI:
   Use environment variables at build time:
   
   flutter build web --dart-define=SUPABASE_URL=https://your-project.supabase.co \\
                      --dart-define=SUPABASE_ANON_KEY=your-anon-key \\
                      --dart-define=GOOGLE_CLIENT_ID_WEB=your-google-client-id \\
                      --dart-define=PRODUCTION=true

3. Get your credentials from:
   - Supabase: https://supabase.com/dashboard → Settings → API
   - Google: https://console.cloud.google.com → APIs & Services → Credentials

Current values:
- Supabase URL: $supabaseUrl
- Anon Key: ${supabaseAnonKey.substring(0, 20)}...
- Environment: ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'}
''');
    }
  }

  /// Print configuration status (without sensitive data)
  static void printConfigStatus() {
    if (kDebugMode) {
      print('📱 SocialCard Pro Configuration Status:');
      print('   Environment: ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'}');
      print('   Configured: ${isConfigured ? '✅' : '❌'}');
      print(
        '   Supabase URL: ${supabaseUrl.startsWith('https://') ? '✅' : '❌'} $supabaseUrl',
      );
      print(
        '   Anon Key: ${supabaseAnonKey.startsWith('eyJ') ? '✅' : '❌'} ${supabaseAnonKey.substring(0, 20)}...',
      );
      print('   Base URL: $baseUrl');
      print('   Auth Redirect: $authRedirectUrl');
    }
  }
}

/// Exception thrown when configuration is invalid
class ConfigurationException implements Exception {
  final String message;
  const ConfigurationException(this.message);

  @override
  String toString() => 'ConfigurationException: $message';
}
