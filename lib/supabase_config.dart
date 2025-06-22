class SupabaseConfig {
  // TODO: Replace with your actual Supabase URL and anon key
  // Get these from your Supabase project dashboard at https://supabase.com/dashboard
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

  // Authentication configuration
  static const Map<String, String> authConfig = {
    'redirectTo': 'http://localhost:3000/',
    'flowType': 'pkce', // More secure than implicit flow
  };

  // Development settings
  static const bool isDevelopment = true;
  static const String developmentRedirectUrl = 'http://localhost:3000/';
  static const String productionRedirectUrl = 'https://your-domain.com/';

  // Get the appropriate redirect URL based on environment
  static String get redirectUrl =>
      isDevelopment ? developmentRedirectUrl : productionRedirectUrl;

  // Example:
  // static const String supabaseUrl = 'https://xyzcompany.supabase.co';
  // static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
}
