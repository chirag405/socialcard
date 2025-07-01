/// Configuration file for Supabase
/// Supports both environment variables (production) and static values (development)
///
/// INSTRUCTIONS:
/// 1. Replace the placeholder values with your actual Supabase credentials
/// 2. Never commit this file to git (should be in .gitignore)
///
/// Get your credentials from:
/// - Supabase URL: https://supabase.com/dashboard → Your Project → Settings → API
/// - Anon Key: https://supabase.com/dashboard → Your Project → Settings → API
/// - Google Client ID: https://console.cloud.google.com → APIs & Services → Credentials

class SupabaseConfig {
  // ===== ENVIRONMENT-BASED CONFIGURATION =====

  /// Get Supabase URL from environment variables (production) or fallback (development)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'YOUR_SUPABASE_URL_HERE',
  );

  /// Get Supabase anonymous key from environment variables (production) or fallback (development)
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE',
  );

  /// Get Google Client ID from environment variables (production) or fallback (development)
  static const String googleClientIdWeb = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: 'YOUR_GOOGLE_CLIENT_ID_HERE',
  );

  // ===== ENVIRONMENT CONFIGURATION =====

  /// Set to true for production builds
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  /// Development settings
  static const String developmentRedirectUrl =
      'http://localhost:3000/auth-callback.html';
  static const String productionRedirectUrl =
      'https://socialcard-pro.vercel.app/auth-callback.html';

  /// Get the appropriate redirect URL based on environment
  static String get redirectUrl =>
      isProduction ? productionRedirectUrl : developmentRedirectUrl;

  /// Authentication configuration
  static const Map<String, String> authConfig = {
    'flowType': 'pkce', // More secure than implicit flow
  };

  // ===== VALIDATION =====

  /// Check if configuration is properly set up
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE' &&
        supabaseUrl.startsWith('https://') &&
        supabaseAnonKey.length > 10; // Basic validation
  }

  /// Validate configuration with environment-aware error handling
  static void validateConfig() {
    // For production builds, always allow the build to continue but log status
    if (isProduction) {
      print('🔧 Production Supabase Configuration:');
      if (supabaseUrl.length > 20) {
        print('  URL: ${supabaseUrl.substring(0, 20)}...');
      } else {
        print('  URL: $supabaseUrl');
      }
      if (supabaseAnonKey.length > 20) {
        print('  Key: ${supabaseAnonKey.substring(0, 10)}...');
      } else {
        print('  Key: $supabaseAnonKey');
      }
      print('  Configured: $isConfigured');

      if (!isConfigured) {
        print('⚠️  Warning: Supabase not fully configured for production');
        print('   Make sure environment variables are set in Vercel');
      } else {
        print('✅ Supabase configuration looks good');
      }
      return; // Don't throw errors in production
    }

    // For development builds, provide helpful setup instructions
    if (!isConfigured) {
      throw Exception('''
🚨 DEVELOPMENT SETUP: Please set up your Supabase credentials!

1. Get your credentials from Supabase Dashboard:
   https://supabase.com/dashboard → Your Project → Settings → API

2. Either:
   a) Update this file (lib/supabase_config.dart) with actual values, OR
   b) Use --dart-define flags when running:
      flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key

3. For Google OAuth, get client ID from:
   https://console.cloud.google.com → APIs & Services → Credentials

Current status:
- Environment: Development
- Supabase URL: ${supabaseUrl.startsWith('https://') ? '✅ Valid' : '❌ Not configured'} 
- Anon Key: ${supabaseAnonKey.length > 20 ? '✅ Valid' : '❌ Not configured'}
''');
    }
  }
}
