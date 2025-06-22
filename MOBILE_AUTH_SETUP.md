# 📱 Mobile Authentication Setup - Android & iOS

## Overview

This guide will help you set up Google OAuth and Phone OTP authentication for both Android and iOS platforms.

## Prerequisites ✅

- [x] Web authentication already working
- [x] Google Cloud project with OAuth credentials
- [x] Supabase project configured

---

## 🤖 Android Setup

### Step 1: Create Android OAuth Credentials

1. **Go to Google Cloud Console**: https://console.cloud.google.com
2. **Navigate**: APIs & Services → Credentials
3. **Click**: "Create Credentials" → "OAuth 2.0 Client IDs"
4. **Application type**: Android
5. **Name**: SocialCard Pro Android
6. **Package name**: `com.example.socialcard`
7. **SHA-1 certificate fingerprint**:

#### Get SHA-1 Fingerprint:

```bash
# For debug builds (development)
cd android
./gradlew signingReport

# Look for SHA1 under "Variant: debug" section
# Copy the SHA1 fingerprint (looks like: 12:34:56:78:90:AB:CD:EF...)
```

8. **Paste the SHA-1** into Google Cloud Console
9. **Click "Create"**
10. **📋 Copy the Client ID** (format: `491082602859-xxxxx.apps.googleusercontent.com`)

### Step 2: Update Android Configuration

1. **Open**: `android/app/google-services.json`
2. **Replace**: `491082602859-android-client-id.apps.googleusercontent.com` with your actual Android Client ID
3. **Replace**: `YOUR_SHA1_FINGERPRINT` with your actual SHA-1 fingerprint

### Step 3: Test Android

```bash
flutter run -d android
```

---

## 🍎 iOS Setup

### Step 1: Create iOS OAuth Credentials

1. **Go to Google Cloud Console**: https://console.cloud.google.com
2. **Navigate**: APIs & Services → Credentials
3. **Click**: "Create Credentials" → "OAuth 2.0 Client IDs"
4. **Application type**: iOS
5. **Name**: SocialCard Pro iOS
6. **Bundle ID**: `com.example.socialcard`
7. **Click "Create"**
8. **📋 Copy the Client ID** (format: `491082602859-yyyyy.apps.googleusercontent.com`)

### Step 2: Update iOS Configuration

1. **Open**: `ios/Runner/GoogleService-Info.plist`
2. **Replace**: `491082602859-ios-client-id.apps.googleusercontent.com` with your actual iOS Client ID
3. **Replace**: `com.googleusercontent.apps.491082602859-ios-client-id` with `com.googleusercontent.apps.YOUR_ACTUAL_IOS_CLIENT_ID`
4. **Replace**: `YOUR_IOS_APP_ID` with your actual iOS App ID from Google Cloud Console

### Step 3: Update URL Scheme in Info.plist

1. **Open**: `ios/Runner/Info.plist`
2. **Find**: `com.googleusercontent.apps.491082602859-ios-client-id`
3. **Replace**: with `com.googleusercontent.apps.YOUR_ACTUAL_IOS_CLIENT_ID`

### Step 4: Test iOS

```bash
flutter run -d ios
```

---

## 🔧 Complete Configuration Files

### Android: `android/app/google-services.json`

```json
{
  "project_info": {
    "project_number": "491082602859",
    "project_id": "project-1-b618d",
    "storage_bucket": "project-1-b618d.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:491082602859:android:81036b316d38e4d522142e",
        "android_client_info": {
          "package_name": "com.example.socialcard"
        }
      },
      "oauth_client": [
        {
          "client_id": "491082602859-5nd8u3ihd7m5guk6e4cqugp1tg0gq31l.apps.googleusercontent.com",
          "client_type": 3
        },
        {
          "client_id": "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 1,
          "android_info": {
            "package_name": "com.example.socialcard",
            "certificate_hash": "YOUR_SHA1_FINGERPRINT"
          }
        }
      ]
    }
  ]
}
```

### iOS: `ios/Runner/GoogleService-Info.plist`

```xml
<key>CLIENT_ID</key>
<string>YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
```

### iOS: `ios/Runner/Info.plist` URL Scheme

```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
</array>
```

---

## 🧪 Testing Guide

### Test Phone OTP (Both Platforms)

1. **Open app** on device/simulator
2. **Tap**: "Sign in with Phone"
3. **Enter**: Phone number with country code (+1234567890)
4. **Check**: SMS received on real device
5. **Enter**: OTP code
6. **Verify**: User logged in successfully

### Test Google OAuth (Both Platforms)

1. **Tap**: "Sign in with Google"
2. **Android**: Google account picker should appear
3. **iOS**: Safari/in-app browser should open Google OAuth
4. **Complete**: OAuth flow
5. **Verify**: Redirected back to app and logged in

---

## 🚨 Troubleshooting

### Android Issues

- **"Sign in failed"**: Check SHA-1 fingerprint is correct
- **"Invalid client"**: Verify package name matches exactly
- **"Network error"**: Check internet connection and API keys

### iOS Issues

- **"No valid redirect"**: Check URL scheme matches reversed client ID
- **"Invalid client"**: Verify bundle ID matches exactly
- **"Safari error"**: Check GoogleService-Info.plist is properly configured

### General Issues

- **No SMS received**:
  - Check phone number format (+1234567890)
  - Verify Supabase SMS provider is enabled
  - Check rate limiting (max 5 SMS per hour on free tier)
- **Database errors**: Ensure `supabase_schema.sql` was run successfully
- **Permission errors**: Check Row Level Security policies in Supabase

---

## 📋 Quick Checklist

### Before Testing:

- [ ] Android OAuth credentials created in Google Cloud Console
- [ ] iOS OAuth credentials created in Google Cloud Console
- [ ] SHA-1 fingerprint added to Android credentials
- [ ] `google-services.json` updated with real Android Client ID
- [ ] `GoogleService-Info.plist` updated with real iOS Client ID
- [ ] `Info.plist` URL scheme updated with real iOS Client ID
- [ ] Supabase providers enabled (Phone + Google)
- [ ] Database schema deployed

### Testing Results:

- [ ] Android Phone OTP working
- [ ] Android Google OAuth working
- [ ] iOS Phone OTP working
- [ ] iOS Google OAuth working
- [ ] Users appearing in Supabase Dashboard
- [ ] User profiles created in database

---

## 🔄 Next Steps

After mobile authentication is working:

1. **Production Setup**:

   - Create production OAuth credentials
   - Update redirect URLs for production domains
   - Configure production SMS provider (Twilio/MessageBird)

2. **App Store Preparation**:

   - Update bundle IDs for production
   - Configure proper signing certificates
   - Test with TestFlight (iOS) and Internal Testing (Android)

3. **Security Hardening**:
   - Review and tighten Supabase RLS policies
   - Implement proper error handling
   - Add rate limiting for authentication attempts

---

**🎯 Goal**: Both Android and iOS apps should have working Google OAuth and Phone OTP authentication, with users properly created in your Supabase database.
