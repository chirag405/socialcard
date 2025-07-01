#!/usr/bin/env dart
// 🔍 SocialCard Pro - Configuration Checker
//
// This script validates all your credentials and OAuth setup
// Run with: dart check-config.dart

import 'dart:io';
import 'dart:convert';

void main() {
  print('🔍 SocialCard Pro - Configuration Checker');
  print('==========================================\n');

  bool hasErrors = false;

  // Check 1: Flutter Configuration
  print('📱 FLUTTER CONFIGURATION');
  print('─────────────────────────');
  hasErrors |= checkFlutterConfig();
  print('');

  // Check 2: Web Configuration
  print('🌐 WEB CONFIGURATION');
  print('──────────────────────');
  hasErrors |= checkWebConfig();
  print('');

  // Check 3: Google OAuth Files
  print('🔑 GOOGLE OAUTH SETUP');
  print('───────────────────────');
  hasErrors |= checkGoogleOAuthFiles();
  print('');

  // Check 4: Centralized Config
  print('⚙️  CENTRALIZED CONFIG');
  print('────────────────────────');
  hasErrors |= checkCentralizedConfig();
  print('');

  // Summary
  print('📋 SUMMARY');
  print('─────────');
  if (hasErrors) {
    print('❌ Configuration has issues that need fixing');
    print('📖 See instructions above to resolve');
    exit(1);
  } else {
    print('✅ All configuration looks good!');
    print('🚀 Ready to deploy');
  }
}

bool checkFlutterConfig() {
  bool hasErrors = false;

  try {
    final file = File('lib/supabase_config.dart');
    if (!file.existsSync()) {
      print('❌ lib/supabase_config.dart not found');
      return true;
    }

    final content = file.readAsStringSync();

    // Check Supabase URL
    if (content.contains('https://jcovcivzcqgfxcxlzjfp.supabase.co')) {
      print('✅ Supabase URL configured');
    } else {
      print('❌ Supabase URL not configured properly');
      hasErrors = true;
    }

    // Check Supabase key
    if (content.contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9')) {
      print('✅ Supabase anon key configured');
    } else {
      print('❌ Supabase anon key not configured properly');
      hasErrors = true;
    }

    // Check Google OAuth
    if (content.contains('YOUR_GOOGLE_CLIENT_ID_HERE')) {
      print('❌ Google OAuth client ID still has placeholder');
      print('   📝 Update lib/supabase_config.dart line ~27');
      hasErrors = true;
    } else {
      print('✅ Google OAuth client ID configured');
    }
  } catch (e) {
    print('❌ Error reading Flutter config: $e');
    hasErrors = true;
  }

  return hasErrors;
}

bool checkWebConfig() {
  bool hasErrors = false;

  try {
    final file = File('web/config.js');
    if (!file.existsSync()) {
      print('❌ web/config.js not found');
      return true;
    }

    final content = file.readAsStringSync();

    // Check if Google OAuth is even mentioned
    if (!content.contains('GOOGLE_CLIENT_ID') &&
        !content.contains('googleClientId')) {
      print('❌ Google OAuth client ID missing entirely from web config');
      print('   📝 Need to add GOOGLE_CLIENT_ID to web/config.js');
      hasErrors = true;
    } else {
      print('⚠️  Google OAuth mentioned but may need verification');
    }

    // Check Supabase config in web
    if (content.contains('https://jcovcivzcqgfxcxlzjfp.supabase.co')) {
      print('✅ Web Supabase URL matches Flutter config');
    } else {
      print('❌ Web Supabase URL doesn\'t match Flutter config');
      hasErrors = true;
    }
  } catch (e) {
    print('❌ Error reading web config: $e');
    hasErrors = true;
  }

  return hasErrors;
}

bool checkGoogleOAuthFiles() {
  bool hasErrors = false;

  // Check Android google-services.json
  final androidFile = File('android/app/google-services.json');
  if (androidFile.existsSync()) {
    print('✅ Android google-services.json exists');
  } else {
    print('⚠️  android/app/google-services.json not found');
    print('   📝 Download from Firebase Console for mobile OAuth');
    hasErrors = true;
  }

  // Check iOS GoogleService-Info.plist
  final iosFile = File('ios/Runner/GoogleService-Info.plist');
  if (iosFile.existsSync()) {
    print('✅ iOS GoogleService-Info.plist exists');
  } else {
    print('⚠️  ios/Runner/GoogleService-Info.plist not found');
    print('   📝 Download from Firebase Console for mobile OAuth');
    hasErrors = true;
  }

  return hasErrors;
}

bool checkCentralizedConfig() {
  bool hasErrors = false;

  try {
    final file = File('config.json');
    if (!file.existsSync()) {
      print('⚠️  config.json not found (template only)');
      return false;
    }

    final content = file.readAsStringSync();
    final config = jsonDecode(content);

    // Check if still has placeholders
    if (config['supabase']?['url'] == 'YOUR_SUPABASE_URL_HERE') {
      print('⚠️  config.json still has Supabase URL placeholder');
    } else {
      print('✅ config.json Supabase URL updated');
    }

    if (config['auth']?['googleClientId'] == 'YOUR_GOOGLE_CLIENT_ID_HERE') {
      print('⚠️  config.json still has Google OAuth placeholder');
    } else {
      print('✅ config.json Google OAuth updated');
    }
  } catch (e) {
    print('⚠️  config.json parse error (this is okay for now): $e');
  }

  return hasErrors;
}
