# 🚀 Deployment Guide for SocialCard Pro

This guide covers deploying SocialCard Pro to various platforms for production use.

## 🌐 Web Deployment

### Option 1: Netlify (Recommended)

Netlify offers free hosting with automatic deployments from GitHub.

#### Steps:

1. **Build your app:**

   ```bash
   flutter build web --release
   ```

2. **Update configuration for production:**

   ```dart
   // In lib/utils/app_config.dart
   static const String baseDomain = 'your-app-name.netlify.app';
   static const String baseUrl = 'https://$baseDomain';
   ```

3. **Deploy to Netlify:**

   - Go to [netlify.com](https://netlify.com) and sign up
   - Drag and drop your `build/web` folder
   - Or connect your GitHub repository for auto-deployment

4. **Configure custom domain (optional):**
   - In Netlify dashboard: Site settings > Domain management
   - Add your custom domain and configure DNS

#### Netlify Configuration File

Create `netlify.toml` in your project root:

```toml
[build]
  publish = "build/web"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200

[build.environment]
  FLUTTER_WEB = "true"
```

### Option 2: Vercel

1. **Install Vercel CLI:**

   ```bash
   npm install -g vercel
   ```

2. **Build and deploy:**
   ```bash
   flutter build web --release
   vercel --prod build/web
   ```

### Option 3: Firebase Hosting

1. **Install Firebase CLI:**

   ```bash
   npm install -g firebase-tools
   ```

2. **Initialize Firebase:**

   ```bash
   firebase init hosting
   ```

3. **Configure firebase.json:**

   ```json
   {
     "hosting": {
       "public": "build/web",
       "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
       "rewrites": [
         {
           "source": "**",
           "destination": "/index.html"
         }
       ]
     }
   }
   ```

4. **Deploy:**
   ```bash
   flutter build web --release
   firebase deploy
   ```

## 📱 Mobile App Deployment

### Android (Google Play Store)

#### Prerequisites:

- Google Play Console account ($25 one-time fee)
- Android keystore for signing

#### Steps:

1. **Create a keystore:**

   ```bash
   keytool -genkey -v -keystore ~/socialcard-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias socialcard
   ```

2. **Configure signing in `android/key.properties`:**

   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=socialcard
   storeFile=../socialcard-key.jks
   ```

3. **Update `android/app/build.gradle`:**

   ```gradle
   android {
       ...
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

4. **Build release APK:**

   ```bash
   flutter build apk --release
   ```

5. **Build App Bundle (recommended):**

   ```bash
   flutter build appbundle --release
   ```

6. **Upload to Google Play Console**

### iOS (Apple App Store)

#### Prerequisites:

- Apple Developer account ($99/year)
- macOS with Xcode

#### Steps:

1. **Open iOS project in Xcode:**

   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Configure signing:**

   - Select your team in Xcode
   - Configure bundle identifier
   - Enable automatic signing

3. **Build for release:**

   ```bash
   flutter build ios --release
   ```

4. **Archive and upload via Xcode**

## 🔧 Production Configuration

### Environment-Specific Settings

Create different configurations for development and production:

```dart
// lib/utils/app_config.dart
class AppConfig {
  static const bool isProduction = bool.fromEnvironment('PRODUCTION', defaultValue: false);

  static String get baseDomain => isProduction
    ? 'socialcard-pro.com'
    : 'localhost:3000';

  static String get baseUrl => isProduction
    ? 'https://$baseDomain'
    : 'http://$baseDomain';
}
```

Build with production flag:

```bash
flutter build web --release --dart-define=PRODUCTION=true
```

### Supabase Production Setup

1. **Update redirect URLs in Supabase:**

   - Add your production domain
   - Update OAuth provider settings

2. **Configure RLS policies for production:**

   - Review and tighten security policies
   - Enable audit logging

3. **Set up monitoring:**
   - Enable Supabase monitoring
   - Set up alerts for errors

## 🔒 Security Considerations

### API Keys and Secrets

1. **Never commit sensitive data:**

   - Use environment variables
   - Keep `.env` files in `.gitignore`

2. **Supabase security:**

   - Use Row Level Security (RLS)
   - Rotate API keys regularly
   - Monitor usage and logs

3. **OAuth configuration:**
   - Use HTTPS in production
   - Restrict redirect URIs
   - Enable PKCE flow

### Content Security Policy

Add to your web app's `index.html`:

```html
<meta
  http-equiv="Content-Security-Policy"
  content="default-src 'self'; 
               script-src 'self' 'unsafe-inline' 'unsafe-eval' https://unpkg.com;
               style-src 'self' 'unsafe-inline';
               img-src 'self' data: https:;
               connect-src 'self' https://*.supabase.co;"
/>
```

## 📊 Monitoring and Analytics

### Error Monitoring

1. **Sentry integration:**

   ```yaml
   dependencies:
     sentry_flutter: ^7.0.0
   ```

2. **Initialize Sentry:**
   ```dart
   await SentryFlutter.init(
     (options) => options.dsn = 'YOUR_SENTRY_DSN',
   );
   ```

### Performance Monitoring

1. **Firebase Performance:**

   ```yaml
   dependencies:
     firebase_performance: ^0.9.0
   ```

2. **Custom metrics:**
   ```dart
   final trace = FirebasePerformance.instance.newTrace('qr_generation');
   await trace.start();
   // Your code here
   await trace.stop();
   ```

## 🚀 CI/CD Pipeline

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.7.2"

      - name: Install dependencies
        run: flutter pub get

      - name: Build web
        run: flutter build web --release --dart-define=PRODUCTION=true

      - name: Deploy to Netlify
        uses: nwtgck/actions-netlify@v2.0
        with:
          publish-dir: "./build/web"
          production-branch: main
          github-token: ${{ secrets.GITHUB_TOKEN }}
          deploy-message: "Deploy from GitHub Actions"
        env:
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

## 📋 Pre-Deployment Checklist

### Technical Checklist

- [ ] All API keys configured for production
- [ ] Database schema is up to date
- [ ] RLS policies are properly configured
- [ ] OAuth redirect URLs updated
- [ ] Error monitoring set up
- [ ] Performance monitoring enabled
- [ ] SSL certificates configured
- [ ] Domain name configured
- [ ] CDN configured (if needed)

### Testing Checklist

- [ ] Authentication flows work
- [ ] QR code generation works
- [ ] Profile viewing works on mobile
- [ ] All features tested on production domain
- [ ] Performance tested under load
- [ ] Security scan completed
- [ ] Accessibility testing done

### Legal Checklist

- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] GDPR compliance verified
- [ ] App store guidelines reviewed
- [ ] Copyright notices included

## 🆘 Troubleshooting

### Common Deployment Issues

1. **CORS errors:**

   - Check Supabase CORS settings
   - Verify domain configuration

2. **OAuth not working:**

   - Check redirect URLs
   - Verify client IDs

3. **Assets not loading:**

   - Check base href in index.html
   - Verify CDN configuration

4. **Performance issues:**
   - Enable web compression
   - Optimize images
   - Use lazy loading

### Rollback Strategy

1. **Keep previous builds:**

   ```bash
   # Tag releases
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. **Quick rollback:**
   - Use Netlify's instant rollback
   - Or redeploy previous build

## 📈 Post-Deployment

### Monitoring

1. **Set up alerts:**

   - Error rate monitoring
   - Performance degradation
   - Usage spikes

2. **Regular maintenance:**
   - Update dependencies
   - Security patches
   - Performance optimization

### User Feedback

1. **Analytics:**

   - User behavior tracking
   - Feature usage metrics
   - Conversion rates

2. **Support:**
   - Set up help documentation
   - Create feedback channels
   - Monitor app store reviews

---

**🎉 Congratulations! Your app is now live in production!**
