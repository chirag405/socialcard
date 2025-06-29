/// Supabase configuration for SocialCard Pro
///
/// This configuration uses local development credentials.
/// For production, use environment variables.
class SupabaseConfig {
  // Local development credentials
  static const String supabaseUrl = 'https://jcovcivzcqgfxcxlzjfp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impjb3ZjaXZ6Y3FnZnhjeGx6amZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1OTQyOTIsImV4cCI6MjA2NjE3MDI5Mn0.vjBWFwyd1tQFbTCWN5K2mouQyVAgMx1AdvNG1CpP5D8';
  static const String googleClientIdWeb =
      '491082602859-5nd8u3ihd7m5guk6e4cqugp1tg0gq31l.apps.googleusercontent.com';

  // Environment detection
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );
  static bool get isDevelopment => !isProduction;

  // URLs
  static String get baseUrl =>
      isProduction ? 'https://your-domain.com' : 'http://localhost:3001';
  static String get redirectUrl =>
      isProduction ? 'https://your-domain.com' : 'http://localhost:3001';

  // Authentication configuration
  static const Map<String, String> authConfig = {
    'flowType': 'pkce', // More secure than implicit flow
  };

  /// Initialize and validate configuration
  static void initialize() {
    // Configuration is now embedded, so just print status
    if (isDevelopment) {
      print('📱 SocialCard Pro - Development Mode');
      print('   Supabase URL: $supabaseUrl');
      print('   Configured: ✅');
    }
  }

  /// Check if configuration is properly set up
  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.startsWith('eyJ');
}
