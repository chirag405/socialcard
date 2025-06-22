# 🚀 Setup Guide for SocialCard Pro

This guide will help you set up the SocialCard Pro project locally for development.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.7.2 or higher)
- **Dart SDK** (2.19.0 or higher)
- **Git**
- **VS Code** or **Android Studio** with Flutter extensions
- **Chrome** (for web development)

## 🔧 Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/socialcard.git
cd socialcard
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Set Up Supabase

#### Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a free account
2. Click "New Project"
3. Fill in project details:
   - **Name**: SocialCard Pro (or your preferred name)
   - **Database Password**: Choose a strong password
   - **Region**: Select closest to your location
4. Wait for project creation (2-3 minutes)

#### Get Your Supabase Credentials

1. In your Supabase dashboard, go to **Settings** > **API**
2. Copy the following:
   - **Project URL** (looks like: `https://xyzabc123.supabase.co`)
   - **Anon Public Key** (starts with `eyJhbGciOiJIUzI1NiIs...`)

#### Configure Your App

1. Copy the local config file:

   ```bash
   cp lib/supabase_config.local.dart lib/supabase_config.dart
   ```

2. Open `lib/supabase_config.dart` and update:
   ```dart
   static const String supabaseUrl = 'YOUR_PROJECT_URL_HERE';
   static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
   ```

### 4. Set Up Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Copy the entire content from `supabase_schema.sql`
3. Paste it in the SQL Editor and click **Run**
4. Verify tables are created in **Table Editor**

### 5. Configure Google OAuth

#### Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing one
3. Enable the **Google+ API**

#### Set Up OAuth Credentials

1. Go to **APIs & Services** > **Credentials**
2. Click **Create Credentials** > **OAuth 2.0 Client IDs**
3. Configure consent screen if prompted
4. For **Application type**, select **Web application**
5. Add authorized redirect URIs:
   ```
   https://YOUR_SUPABASE_PROJECT_ID.supabase.co/auth/v1/callback
   http://localhost:3000/
   ```
6. Copy the **Client ID** (you'll need this)

#### Configure Supabase Authentication

1. In Supabase dashboard, go to **Authentication** > **Providers**
2. Enable **Google** provider
3. Add your Google **Client ID** and **Client Secret**
4. Set **Site URL** to: `http://localhost:3000`
5. Add **Redirect URLs**:
   ```
   http://localhost:3000/
   https://YOUR_SUPABASE_PROJECT_ID.supabase.co/auth/v1/callback
   ```

### 6. Test Your Setup

#### Run the Web App

```bash
flutter run -d chrome --web-port=3000
```

#### Verify Everything Works

1. **App loads**: Should see the login screen
2. **Google Sign-in**: Click "Sign in with Google" - should work
3. **Database**: After login, profile should be created in Supabase
4. **QR Generation**: Try creating a QR code
5. **Profile viewing**: Test the generated profile URL

## 🛠️ Development Workflow

### Running the App

```bash
# Web development (recommended for testing)
flutter run -d chrome --web-port=3000

# Android (requires Android Studio/emulator)
flutter run -d android

# iOS (requires Xcode on macOS)
flutter run -d ios
```

### Hot Reload

While the app is running:

- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debugging

1. **Browser DevTools**: F12 in Chrome
2. **Flutter Inspector**: Available in VS Code/Android Studio
3. **Supabase Logs**: Check in Supabase dashboard

## 🔍 Troubleshooting

### Common Issues

#### "Supabase initialization failed"

- Check your `supabase_config.dart` has correct URL and key
- Verify internet connection
- Check Supabase project is active

#### "Google Sign-in failed"

- Verify Google OAuth client ID is correct
- Check redirect URIs in Google Cloud Console
- Ensure Supabase Google provider is enabled

#### "QR codes generate localhost URLs"

- This is normal for development
- For production, update `lib/utils/app_config.dart`

#### "Profile page doesn't load"

- Check database schema is properly set up
- Verify RLS policies are created
- Check browser console for errors

### Getting Help

1. **Check the logs**: Both Flutter console and browser console
2. **Supabase Dashboard**: Check logs and table data
3. **GitHub Issues**: Search existing issues or create new one
4. **Discord/Community**: Join Flutter/Supabase communities

## 📱 Platform-Specific Setup

### Android Development

1. **Install Android Studio**
2. **Set up Android SDK**
3. **Create virtual device** or connect physical device
4. **Enable USB debugging** on physical device

### iOS Development (macOS only)

1. **Install Xcode** from App Store
2. **Set up iOS Simulator**
3. **For physical device**: Set up Apple Developer account

## 🚀 Ready to Develop!

Once everything is set up, you're ready to:

- 🎨 Customize the UI
- 🔧 Add new features
- 🐛 Fix bugs
- 📚 Improve documentation

## 📚 Next Steps

- Read the [Contributing Guidelines](CONTRIBUTING.md)
- Check the [API Documentation](docs/API.md)
- Review the [Code Architecture](docs/ARCHITECTURE.md)

---

**Happy coding! 🎉**
