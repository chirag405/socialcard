/// 🔐 SocialCard Pro - Centralized Configuration Reader
///
/// This file reads from the centralized config.json file
/// All secrets and configuration are managed in one place

class SupabaseConfig {
  // ===== ENVIRONMENT-BASED CONFIGURATION =====
  // These will be injected during build or fallback to development values

  /// Supabase URL - from environment or development fallback
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://jcovcivzcqgfxcxlzjfp.supabase.co',
  );

  /// Supabase Anon Key - from environment or development fallback
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impjb3ZjaXZ6Y3FnZnhjeGx6amZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1OTQyOTIsImV4cCI6MjA2NjE3MDI5Mn0.vjBWFwyd1tQFbTCWN5K2mouQyVAgMx1AdvNG1CpP5D8',
  );

  /// Google Client ID - from environment or development fallback
  static const String googleClientIdWeb = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue:
        '223999169006-e6kou76mhs1b592s6k57trgi899lscc3.apps.googleusercontent.com',
  );

  // ===== APP CONFIGURATION =====

  static const String appName = 'SocialCard Pro';
  static const String appVersion = '1.0.0';

  // ===== ENVIRONMENT DETECTION =====

  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  // ===== URL CONFIGURATION =====

  static const String developmentDomain = 'localhost:3000';
  static const String productionDomain = 'socialcard-pro.netlify.app';

  static String get domain =>
      isProduction ? productionDomain : developmentDomain;
  static String get baseUrl =>
      isProduction ? 'https://$productionDomain' : 'http://$developmentDomain';
  static String get redirectUrl => '$baseUrl/auth-callback.html';

  // ===== VALIDATION =====

  /// Check if all required configuration is set
  static bool get isConfigured {
    return supabaseUrl.startsWith('https://') &&
        supabaseAnonKey.length > 20 &&
        supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE' &&
        googleClientIdWeb != 'YOUR_GOOGLE_CLIENT_ID_HERE';
  }

  /// Validate configuration with helpful messages
  static void validateConfig() {
    print('🔧 SocialCard Pro Configuration:');
    print('  Environment: ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'}');
    print('  App: $appName v$appVersion');
    print('  Domain: $domain');
    print('  Base URL: $baseUrl');

    if (supabaseUrl.length > 30) {
      print('  Supabase URL: ${supabaseUrl.substring(0, 30)}...');
    } else {
      print('  Supabase URL: $supabaseUrl');
    }

    if (supabaseAnonKey.length > 20) {
      print('  Anon Key: ${supabaseAnonKey.substring(0, 20)}...');
    } else {
      print('  Anon Key: $supabaseAnonKey');
    }

    print('  Configured: $isConfigured');

    // For development, throw helpful errors
    if (!isProduction && !isConfigured) {
      throw Exception('''
🚨 CONFIGURATION NEEDED!

To set up SocialCard Pro:

1. Update config.json with your credentials from:
   📱 Supabase: https://supabase.com/dashboard → Your Project → Settings → API
   🔑 Google OAuth: https://console.cloud.google.com → APIs & Services → Credentials

2. For development, update the default values in this file, OR
   Use --dart-define flags: flutter run --dart-define=SUPABASE_URL=your_url

3. For production deployment, set environment variables

Current status:
- Supabase URL: ${supabaseUrl.startsWith('https://') ? '✅' : '❌'} 
- Anon Key: ${supabaseAnonKey.length > 20 ? '✅' : '❌'}
- Google Client: ${googleClientIdWeb != 'YOUR_GOOGLE_CLIENT_ID_HERE' ? '✅' : '❌'}
''');
    }

    if (isConfigured) {
      print('✅ Configuration is valid!');
    } else if (isProduction) {
      print('⚠️  Warning: Some configuration may be missing');
    }
  }
}
