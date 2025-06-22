class AppConfig {
  // App Configuration
  static const String appName = 'SocialCard Pro';
  static const String appVersion = '1.0.0';

  // Domain Configuration
  // For development - using localhost
  static const String baseDomain =
      'localhost:3000'; // Flutter web development port
  static const String baseUrl = 'http://$baseDomain';

  // For production, uncomment and update with your domain:
  // static const String baseDomain = 'socialcard-pro.netlify.app';
  // static const String baseUrl = 'https://$baseDomain';

  // When ready to deploy:
  // 1. Replace the baseDomain with your actual domain
  // 2. Change http to https
  // 3. Run: flutter build web --release

  // Deep Link Configuration
  static const String androidPackageName = 'com.example.socialcard';
  static const String iosAppStoreId =
      '123456789'; // Replace with actual App Store ID
  static const String iosBundleId = 'com.example.socialcard';

  // Link Generation
  static String generateProfileLink(String slug) {
    return '$baseUrl/profile.html?slug=$slug';
  }

  static String generateQrDataUrl(String slug) {
    return '$baseUrl/qr/$slug';
  }

  // App Store Links
  static const String androidAppUrl =
      'https://play.google.com/store/apps/details?id=$androidPackageName';
  static const String iosAppUrl = 'https://apps.apple.com/app/id$iosAppStoreId';

  // Firebase Dynamic Links (if using Firebase Dynamic Links)
  static const String dynamicLinkDomain = 'socialcardpro.page.link';

  static String generateDynamicLink(String slug) {
    return 'https://$dynamicLinkDomain/?link=${Uri.encodeComponent(generateProfileLink(slug))}'
        '&apn=$androidPackageName'
        '&ibi=$iosBundleId'
        '&isi=$iosAppStoreId';
  }

  // Social Media Links
  static const Map<String, String> socialPlatforms = {
    'website': 'https://',
    'email': 'mailto:',
    'phone': 'tel:',
    'whatsapp': 'https://wa.me/',
    'telegram': 'https://t.me/',
    'instagram': 'https://instagram.com/',
    'twitter': 'https://twitter.com/',
    'linkedin': 'https://linkedin.com/in/',
    'facebook': 'https://facebook.com/',
    'youtube': 'https://youtube.com/c/',
    'tiktok': 'https://tiktok.com/@',
    'github': 'https://github.com/',
    'discord': 'https://discord.gg/',
    'snapchat': 'https://snapchat.com/add/',
    'pinterest': 'https://pinterest.com/',
    'reddit': 'https://reddit.com/u/',
  };

  // QR Code Configuration
  static const int qrCodeSize = 300;
  static const int qrCodeMargin = 2;
  static const String defaultQrErrorCorrectLevel = 'M'; // L, M, Q, H

  // Expiry Configuration
  static const Map<String, Duration> expiryDurations = {
    '1 hour': Duration(hours: 1),
    '6 hours': Duration(hours: 6),
    '1 day': Duration(days: 1),
    '3 days': Duration(days: 3),
    '1 week': Duration(days: 7),
    '1 month': Duration(days: 30),
    'Never': Duration(days: 365 * 10), // 10 years
  };

  // Development/Debug Configuration
  static const bool isDebugMode = true; // Set to false for production
  static const bool enableAnalytics = false; // Set to true for production
  static const bool enableCrashReporting = false; // Set to true for production
}
