// 🔐 SocialCard Pro - Web Configuration Template
//
// INSTRUCTIONS:
// 1. Copy this file to web/config.js
// 2. Replace the placeholder values with your actual credentials
// 3. Add web/config.js to .gitignore to prevent committing credentials
// 4. Use environment variables in production (see deployment guide)

window.SocialCardConfig = {
  // ⚠️ REPLACE THESE WITH YOUR ACTUAL CREDENTIALS ⚠️

  // Your Supabase project configuration
  SUPABASE_URL: "YOUR_SUPABASE_URL_HERE",
  SUPABASE_ANON_KEY: "YOUR_SUPABASE_ANON_KEY_HERE",

  // Environment detection
  IS_PRODUCTION: false, // Set to true for production deployment

  // App configuration
  APP_NAME: "SocialCard Pro",
  VERSION: "1.0.0",

  // Base URLs
  get BASE_URL() {
    return this.IS_PRODUCTION
      ? "https://your-domain.com"
      : "http://localhost:3001";
  },

  // Validation
  isConfigured() {
    return (
      this.SUPABASE_URL !== "YOUR_SUPABASE_URL_HERE" &&
      this.SUPABASE_ANON_KEY !== "YOUR_SUPABASE_ANON_KEY_HERE" &&
      this.SUPABASE_URL.startsWith("https://") &&
      this.SUPABASE_ANON_KEY.startsWith("eyJ")
    );
  },

  // Initialize and validate
  init() {
    if (!this.isConfigured()) {
      console.error(`
🚨 CONFIGURATION ERROR: Web configuration not set up!

1. Copy web/config.template.js to web/config.js
2. Update config.js with your Supabase credentials from:
   https://supabase.com/dashboard → Your Project → Settings → API

3. For production deployment, use environment variables:
   - Set SUPABASE_URL and SUPABASE_ANON_KEY in your hosting platform
   - Update your build process to inject these values

Current status:
- Supabase URL: ${this.SUPABASE_URL}
- Anon Key: ${this.SUPABASE_ANON_KEY.substring(0, 20)}...
- Environment: ${this.IS_PRODUCTION ? "PRODUCTION" : "DEVELOPMENT"}
      `);
      throw new Error("SocialCard Pro configuration not set up");
    }

    console.log("✅ SocialCard Pro configuration loaded successfully");
    return true;
  },
};
