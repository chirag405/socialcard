/// Template configuration file for Supabase
///
/// INSTRUCTIONS:
/// 1. Copy this file to `lib/supabase_config.dart`
/// 2. Replace the placeholder values with your actual Supabase credentials
/// 3. Never commit the actual `lib/supabase_config.dart` file to git
///
/// Get your credentials from:
/// - Supabase URL: https://supabase.com/dashboard → Your Project → Settings → API
/// - Anon Key: https://supabase.com/dashboard → Your Project → Settings → API
/// - Google Client ID: https://console.cloud.google.com → APIs & Services → Credentials

class SupabaseConfig {
  // ⚠️ REPLACE THESE WITH YOUR ACTUAL CREDENTIALS ⚠️

  /// Your Supabase project URL
  /// Example: 'https://abcdefgh12345678.supabase.co'
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';

  /// Your Supabase anonymous/public key
  /// Example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

  /// Google OAuth Web Client ID (for web authentication)
  /// Example: '123456789-abcdefgh.apps.googleusercontent.com'
  static const String googleClientIdWeb = 'YOUR_GOOGLE_CLIENT_ID_HERE';

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
      'https://your-domain.com/auth-callback.html';

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
        supabaseAnonKey.startsWith('eyJ'); // JWT tokens start with eyJ
  }

  /// Validate configuration and throw helpful error if not configured
  static void validateConfig() {
    if (!isConfigured) {
      throw Exception('''
🚨 CONFIGURATION ERROR: Please set up your Supabase credentials!

1. Get your credentials from Supabase Dashboard:
   https://supabase.com/dashboard → Your Project → Settings → API

2. Update this file (lib/supabase_config.dart) with:
   - supabaseUrl: Your project URL
   - supabaseAnonKey: Your anonymous/public key

3. For Google OAuth, get client ID from:
   https://console.cloud.google.com → APIs & Services → Credentials

Current status:
- Supabase URL: ${supabaseUrl.startsWith('https://') ? '✅ Valid' : '❌ Invalid'} 
- Anon Key: ${supabaseAnonKey.startsWith('eyJ') ? '✅ Valid' : '❌ Invalid'}
''');
    }
  }
}
