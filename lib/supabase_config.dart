class SupabaseConfig {
  // TODO: Replace with your actual Supabase anon key from your dashboard
  // Get these from your Supabase project dashboard at https://supabase.com/dashboard/project/jcovcivzcqgfxcxlzjfp
  // Go to Settings → API and copy the "anon public" key
  static const String supabaseUrl = 'https://jcovcivzcqgfxcxlzjfp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impjb3ZjaXZ6Y3FnZnhjeGx6amZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1OTQyOTIsImV4cCI6MjA2NjE3MDI5Mn0.vjBWFwyd1tQFbTCWN5K2mouQyVAgMx1AdvNG1CpP5D8'; // Replace this with your real anon key

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

  // Example of what the anon key looks like:
  // static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impjb3ZjaXZ6Y3FnZnhjeGx6amZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDkwNzQ4NjEsImV4cCI6MjAyNDY1MDg2MX0...';
}
