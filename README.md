# 🎯 SocialCard Pro

**Create beautiful QR codes for your social profiles** - A modern Flutter app that lets users generate customizable QR codes linking to their social media profiles and contact information.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Web](https://img.shields.io/badge/Web-4285F4?style=for-the-badge&logo=google-chrome&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

## ✨ Features

- 🔐 **Authentication** - Google Sign-in & Phone OTP via Supabase
- 📱 **QR Code Generation** - Create custom QR codes with various styles
- 🎨 **Customization** - Colors, styles, logos, and expiry settings
- 📊 **Analytics** - Track scans and visits
- 👥 **Contact Management** - Save and sync contacts
- 🌐 **Web Profiles** - Shareable profile pages
- 📱 **Cross-Platform** - Web, Android, iOS support
- 🔒 **Privacy First** - User-controlled data sharing

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (3.7.2+)
- Dart SDK
- Supabase account
- Google Cloud Console project (for OAuth)

### 1. Clone & Setup

```bash
git clone https://github.com/yourusername/socialcard.git
cd socialcard
flutter pub get
```

### 2. Configure Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Copy `lib/supabase_config.local.dart` to `lib/supabase_config.dart`
3. Update with your actual Supabase credentials:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

### 3. Setup Database

Run the SQL schema in your Supabase SQL Editor:

```bash
# Copy content from supabase_schema.sql and run in Supabase dashboard
```

### 4. Configure Google OAuth

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create OAuth 2.0 credentials
3. Add authorized redirect URIs:
   - `https://YOUR_SUPABASE_PROJECT.supabase.co/auth/v1/callback`
   - `http://localhost:3000/` (for development)

### 5. Run the App

```bash
# Web development
flutter run -d chrome --web-port=3000

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 📁 Project Structure

```
socialcard/
├── lib/
│   ├── blocs/          # State management (BLoC pattern)
│   ├── models/         # Data models
│   ├── screens/        # UI screens
│   ├── services/       # API & database services
│   ├── utils/          # Utilities & configuration
│   └── widgets/        # Reusable UI components
├── web/
│   ├── profile.html    # Public profile viewer
│   ├── debug-*.html    # Debug tools
│   └── index.html      # Main web entry
├── android/            # Android-specific files
├── ios/               # iOS-specific files
└── assets/            # Images, fonts, icons
```

## 🌐 Deployment

### Web Deployment (Netlify/Vercel)

1. **Build for production:**

   ```bash
   flutter build web --release
   ```

2. **Update configuration:**

   ```dart
   // In lib/utils/app_config.dart
   static const String baseDomain = 'your-app.netlify.app';
   static const String baseUrl = 'https://$baseDomain';
   ```

3. **Deploy:**
   - Upload `build/web` folder to Netlify/Vercel
   - Configure custom domain (optional)

### Mobile Deployment

**Android:**

```bash
flutter build apk --release
# Upload to Google Play Store
```

**iOS:**

```bash
flutter build ios --release
# Upload to Apple App Store
```

## 🔧 Configuration

### Environment Variables

Create these files (not tracked by Git):

**lib/supabase_config.dart:**

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_URL';
  static const String supabaseAnonKey = 'YOUR_KEY';
  // ... other config
}
```

### App Configuration

**lib/utils/app_config.dart:**

- Update domain for production
- Configure social platform URLs
- Set QR code defaults

## 🛠️ Development

### Adding New Features

1. **Models:** Add data models in `lib/models/`
2. **Services:** Add API calls in `lib/services/`
3. **BLoC:** Add state management in `lib/blocs/`
4. **UI:** Add screens in `lib/screens/`

### Database Changes

1. Update `supabase_schema.sql`
2. Run migrations in Supabase dashboard
3. Update Dart models accordingly

### Testing

```bash
# Run tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📱 Features in Detail

### QR Code Generation

- **Custom Styles:** Square, circle, rounded corners
- **Colors:** Foreground, background, gradients
- **Logos:** Upload custom logos
- **Expiry:** Set time limits and scan limits

### Profile Management

- **Rich Profiles:** Name, bio, profile image
- **Custom Links:** Add social media, websites, contact info
- **Privacy Controls:** Choose what to share
- **Link Organization:** Drag & drop reordering

### Analytics

- **Scan Tracking:** See when and where QR codes are scanned
- **Visit Analytics:** Track profile page visits
- **Geographic Data:** Location-based insights (optional)

## 🔒 Security & Privacy

- **Row Level Security (RLS)** enabled on all database tables
- **API keys** stored securely (not in version control)
- **User data** is private by default
- **GDPR compliant** data handling
- **No tracking** without user consent

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation:** Check the `docs/` folder
- **Issues:** Open a GitHub issue
- **Discussions:** Use GitHub Discussions
- **Email:** support@socialcard.pro

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - UI framework
- [Supabase](https://supabase.com) - Backend as a Service
- [QR Flutter](https://pub.dev/packages/qr_flutter) - QR code generation
- [Mobile Scanner](https://pub.dev/packages/mobile_scanner) - QR code scanning

---

**Made with ❤️ using Flutter & Supabase**
