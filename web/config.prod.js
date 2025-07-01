// 🔐 SocialCard Pro - Production Web Configuration
//
// This file is used for production deployment on Vercel
// Environment variables are injected during build time

window.SocialCardConfig = {
  // Production Supabase configuration (injected via environment variables)
  SUPABASE_URL: process.env.SUPABASE_URL || "https://your-project.supabase.co",
  SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY || "your-anon-key",

  // Environment detection
  IS_PRODUCTION: true,

  // App configuration
  APP_NAME: "SocialCard Pro",
  VERSION: "1.0.0",

  // Base URLs - will be set based on Vercel deployment URL
  get BASE_URL() {
    if (typeof window !== "undefined") {
      return window.location.origin;
    }
    return "https://socialcard-pro.vercel.app";
  },

  // Google OAuth configuration
  GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID || "your-google-client-id",

  // Redirect URLs for authentication
  get AUTH_REDIRECT_URL() {
    return `${this.BASE_URL}/auth-callback.html`;
  },

  // Validation
  isConfigured() {
    return (
      this.SUPABASE_URL !== "https://your-project.supabase.co" &&
      this.SUPABASE_ANON_KEY !== "your-anon-key" &&
      this.SUPABASE_URL.startsWith("https://") &&
      this.SUPABASE_ANON_KEY.startsWith("eyJ")
    );
  },

  // Initialize and validate
  init() {
    console.log("🚀 Initializing SocialCard Pro in PRODUCTION mode");
    console.log("🌐 Base URL:", this.BASE_URL);
    console.log("🔗 Auth Redirect:", this.AUTH_REDIRECT_URL);

    if (!this.isConfigured()) {
      console.error(`
🚨 PRODUCTION CONFIGURATION ERROR!

Environment variables required:
- SUPABASE_URL: Your Supabase project URL
- SUPABASE_ANON_KEY: Your Supabase anonymous key
- GOOGLE_CLIENT_ID: Your Google OAuth client ID

Current status:
- Supabase URL: ${this.SUPABASE_URL}
- Anon Key: ${this.SUPABASE_ANON_KEY.substring(0, 20)}...
- Google Client ID: ${this.GOOGLE_CLIENT_ID}

Set these in your Vercel project settings under Environment Variables.
      `);
      throw new Error("SocialCard Pro production configuration missing");
    }

    console.log(
      "✅ SocialCard Pro production configuration loaded successfully"
    );
    return true;
  },

  // Analytics and monitoring
  ANALYTICS_ENABLED: true,
  ERROR_REPORTING_ENABLED: true,

  // Feature flags
  FEATURES: {
    QR_SCANNING: true,
    CONTACT_SHARING: true,
    SOCIAL_LINKS: true,
    PROFILE_CUSTOMIZATION: true,
    ANALYTICS: true,
  },
};
