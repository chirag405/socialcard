# 🚀 SocialCard Pro - Deployment Guide

## Quick Start Deployment

### 1. Set Up Configuration

**First time setup:**

1. **Update `config.json`** with your actual credentials:

   ```json
   {
     "supabase": {
       "url": "https://your-project.supabase.co",
       "anonKey": "your-actual-anon-key-here"
     },
     "auth": {
       "googleClientId": "your-google-client-id"
     }
   }
   ```

2. **Update Flutter config** (`lib/supabase_config.dart`):

   - Replace the `defaultValue` strings with your actual credentials
   - Or use environment variables for production

3. **Update web config** (`web/config.js`):
   - Replace the credential values to match your Flutter config

### 2. Deploy to Netlify

**Option A: Automatic (Recommended)**

```bash
./deploy.sh
```

**Option B: Manual**

```bash
# Build the app
flutter build web --release --dart-define=PRODUCTION=true

# Upload build/web folder to Netlify dashboard
```

**Option C: Git-based deployment**

1. Push your code to GitHub
2. Connect your repo to Netlify
3. Set build command: `flutter build web --release --dart-define=PRODUCTION=true`
4. Set publish directory: `build/web`

### 3. Environment Variables

Set these in **Netlify Dashboard → Site Settings → Environment Variables**:

| Variable            | Value                     | Example                                    |
| ------------------- | ------------------------- | ------------------------------------------ |
| `SUPABASE_URL`      | Your Supabase project URL | `https://abc123.supabase.co`               |
| `SUPABASE_ANON_KEY` | Your Supabase anon key    | `eyJhbGciOiJIUzI1...`                      |
| `GOOGLE_CLIENT_ID`  | Google OAuth client ID    | `123456789-abc.apps.googleusercontent.com` |
| `PRODUCTION`        | `true`                    | `true`                                     |

## Architecture

### Single Deployment, Dual Purpose

Your app serves **two functions** from one deployment:

1. **Main Flutter App** (`/`)

   - User registration, profile management, QR creation
   - URL: `https://socialcard-pro.netlify.app/`

2. **QR Profile Pages** (`/profile.html`)
   - Lightweight profile viewing when QR codes are scanned
   - URL: `https://socialcard-pro.netlify.app/profile.html?slug=abc123`

### Smart URL Routing

The `netlify.toml` file handles these URL patterns:

- `/profile/abc123` → `/profile.html?slug=abc123`
- `/qr/abc123` → `/profile.html?slug=abc123`

## Configuration Management

### Centralized Secrets ✅

All configuration is managed in **one place**:

```
📁 config.json          ← Master configuration
📁 lib/supabase_config.dart  ← Flutter reads from here
📁 web/config.js         ← Web pages read from here
```

### Environment Detection ✅

The app automatically detects:

- **Development**: `localhost` URLs, debug logging
- **Production**: Live domain, optimized performance

## Troubleshooting

### Build Fails

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web --release
```

### Configuration Errors

1. Check that all values in `config.json` are filled
2. Verify Supabase credentials are correct
3. Ensure Google OAuth is set up properly

### QR Links Don't Work

1. Verify QR config exists in Supabase
2. Check that profile data is properly saved
3. Test with `https://your-domain.com/profile.html?slug=test-slug`

## Security

- ✅ All sensitive files are in `.gitignore`
- ✅ Environment variables for production
- ✅ Security headers configured
- ✅ HTTPS enforced

## Performance

- ✅ Static asset caching (1 year)
- ✅ Gzip compression enabled
- ✅ Optimized Flutter web build
- ✅ Lightweight profile pages (no Flutter overhead)

---

## Quick Commands

```bash
# Development
flutter run -d web-server --web-port 3000

# Build for production
flutter build web --release --dart-define=PRODUCTION=true

# Deploy (if you have Netlify CLI)
netlify deploy --prod --dir=build/web
```

🎉 **That's it!** Your app is now deployed and ready to use.
