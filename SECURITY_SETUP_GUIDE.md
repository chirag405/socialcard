# 🔐 Security Setup Guide - SocialCard Pro

This guide explains how to securely configure Supabase credentials without exposing sensitive data in your git repository.

## 🚨 Security Overview

**NEVER commit real API keys to git!** This project uses multiple layers of security:

1. **Template-based configuration** - Real config files are git-ignored
2. **Environment variables** - Production uses build-time environment variables
3. **Validation** - Automatic detection of placeholder vs real credentials
4. **Separation** - Different approaches for development vs production

## 🛠️ Development Setup

### Step 1: Get Your Supabase Credentials

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Open your project (or create a new one)
3. Navigate to **Settings** → **API**
4. Copy these values:
   - **Project URL** (e.g., `https://abcdefgh12345678.supabase.co`)
   - **Anon/Public Key** (starts with `eyJhbGciOiJIUzI1NiIs...`)

### Step 2: Configure Flutter App

```bash
# Copy the template to create your config file
cp lib/supabase_config.template.dart lib/supabase_config.dart
```

Edit `lib/supabase_config.dart` and replace the placeholder values:

```dart
class SupabaseConfig {
  // Replace these with your actual credentials
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIs...your-actual-key...';
  static const String googleClientIdWeb = 'your-google-client-id.apps.googleusercontent.com';

  // ... rest of the file stays the same
}
```

### Step 3: Configure Web Files

```bash
# Copy the web config template
cp web/config.template.js web/config.js
```

Edit `web/config.js` and replace the credentials:

```javascript
window.SocialCardConfig = {
  SUPABASE_URL: "https://your-project.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIs...your-actual-key...",
  IS_PRODUCTION: false, // Set to true for production
  // ... rest stays the same
};
```

### Step 4: Test Your Setup

```bash
flutter run
```

The app will validate your configuration and show a status report in the console.

## 🚀 Production Deployment

### Method 1: Environment Variables (Recommended)

Build with environment variables to avoid storing credentials in files:

```bash
flutter build web \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=GOOGLE_CLIENT_ID_WEB=your-google-client-id \
  --dart-define=PRODUCTION=true
```

### Method 2: CI/CD Pipeline

Example GitHub Actions configuration:

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.7.2"

      - name: Build Web App
        run: |
          flutter build web \
            --dart-define=SUPABASE_URL=${{ secrets.SUPABASE_URL }} \
            --dart-define=SUPABASE_ANON_KEY=${{ secrets.SUPABASE_ANON_KEY }} \
            --dart-define=GOOGLE_CLIENT_ID_WEB=${{ secrets.GOOGLE_CLIENT_ID_WEB }} \
            --dart-define=PRODUCTION=true

      - name: Deploy to Hosting
        # Your deployment step here
```

Set these secrets in your repository:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `GOOGLE_CLIENT_ID_WEB`

### Method 3: Hosting Platform Environment Variables

#### Vercel

```bash
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
vercel env add GOOGLE_CLIENT_ID_WEB
```

#### Netlify

Set environment variables in: Site Settings → Environment Variables

#### Firebase Hosting

```bash
firebase functions:config:set \
  supabase.url="your-url" \
  supabase.anon_key="your-key"
```

## 🔍 Configuration Validation

The app automatically validates your configuration:

### ✅ Valid Configuration

```
📱 SocialCard Pro Configuration Status:
   Environment: DEVELOPMENT
   Configured: ✅
   Supabase URL: ✅ https://your-project.supabase.co
   Anon Key: ✅ eyJhbGciOiJIUzI1NiIs...
   Base URL: http://localhost:3000
   Auth Redirect: http://localhost:3000/auth-callback.html
```

### ❌ Invalid Configuration

```
🚨 CONFIGURATION ERROR: Supabase credentials not configured!

To fix this issue:
1. Copy lib/supabase_config.template.dart to lib/supabase_config.dart
2. Add your actual Supabase credentials
3. For production, use environment variables

Current values:
- Supabase URL: YOUR_SUPABASE_URL_HERE
- Anon Key: YOUR_SUPABASE_ANON_KEY...
```

## 🛡️ Security Best Practices

### 1. Git Security

- ✅ Configuration files are git-ignored
- ✅ Only template files are committed
- ✅ No real credentials in source code

### 2. Environment Separation

- ✅ Development uses local config files
- ✅ Production uses environment variables
- ✅ Different redirect URLs per environment

### 3. Validation

- ✅ Automatic validation on app start
- ✅ Clear error messages for setup issues
- ✅ Configuration status logging

### 4. Supabase Security

- ✅ Use Row Level Security (RLS) policies
- ✅ Restrict API access with proper policies
- ✅ Monitor usage in Supabase dashboard
- ✅ Rotate keys periodically

## 🐛 Troubleshooting

### "Configuration not set up" Error

- Check that you copied and edited the config files
- Verify credentials are not placeholder values
- Ensure URLs start with `https://` and keys start with `eyJ`

### "Connection failed" Error

- Verify Supabase URL is correct
- Check that your Supabase project is active
- Confirm anon key has correct permissions

### Web Files Not Loading

- Ensure `web/config.js` exists and is configured
- Check browser console for JavaScript errors
- Verify HTML files are loading config.js correctly

### Build Errors in Production

- Confirm all environment variables are set
- Check that variable names match exactly
- Verify build command includes all required --dart-define flags

## 📚 Related Documentation

- [Supabase Authentication Guide](https://supabase.com/docs/guides/auth)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Environment Variables in Flutter](https://docs.flutter.dev/deployment/flavors)

## 🆘 Need Help?

If you encounter issues:

1. Check the configuration validation output
2. Verify all credentials are correct in Supabase dashboard
3. Ensure environment variables are set correctly
4. Review the security best practices above

Remember: **Never commit real API keys to git!** Always use the template system or environment variables.
