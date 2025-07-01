/// Production Supabase configuration
/// This file uses environment variables injected during build

class SupabaseConfig {
  /// Get Supabase URL from environment variables (injected via --dart-define)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  /// Get Supabase anonymous key from environment variables (injected via --dart-define)
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key-here',
  );

  /// Get Google Client ID from environment variables (injected via --dart-define)
  static const String googleClientIdWeb = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: 'your-google-client-id-here',
  );

  // ===== ENVIRONMENT CONFIGURATION =====

  /// Production environment
  static const bool isProduction = true;

  /// Production redirect URL - dynamically determined
  static String get redirectUrl {
    // For web deployment, use the current origin
    if (identical(0, 0.0)) {
      // This is a compile-time check for web
      return '${Uri.base.origin}/auth-callback.html';
    }
    return 'https://socialcard-pro.vercel.app/auth-callback.html';
  }

  /// Authentication configuration
  static const Map<String, String> authConfig = {
    'flowType': 'pkce', // More secure than implicit flow
  };

  // ===== VALIDATION =====

  /// Check if configuration is properly set up
  static bool get isConfigured {
    return supabaseUrl != 'https://your-project.supabase.co' &&
        supabaseAnonKey != 'your-anon-key-here' &&
        supabaseUrl.startsWith('https://') &&
        supabaseAnonKey.isNotEmpty;
  }

  /// Validate configuration and print helpful info
  static void validateConfig() {
    print('🔧 Supabase Configuration:');
    print('  URL: ${supabaseUrl.substring(0, 20)}...');
    print('  Key: ${supabaseAnonKey.substring(0, 10)}...');
    print('  Configured: $isConfigured');

    if (!isConfigured) {
      print('⚠️  Warning: Supabase not fully configured');
      print('   This may limit app functionality');
    } else {
      print('✅ Supabase configuration looks good');
    }
  }
}
