# 🎯 Your Specific Mobile Setup Details

## ✅ What's Already Configured

### Your SHA-1 Fingerprint (Android Debug)

```
85:3B:6A:3C:FE:90:07:D9:84:EC:CD:2E:FC:5B:77:D6:F6:04:7B:26
```

✅ **Already added** to `android/app/google-services.json`

### Your Google Project Details

- **Project ID**: `project-1-b618d`
- **Project Number**: `491082602859`
- **Web Client ID**: `491082602859-5nd8u3ihd7m5guk6e4cqugp1tg0gq31l.apps.googleusercontent.com` ✅
- **Package Name**: `com.example.socialcard`
- **Bundle ID**: `com.example.socialcard`

---

## 🚀 Next Action Items

### 1. Create Android OAuth Credentials

1. Go to: https://console.cloud.google.com/apis/credentials?project=project-1-b618d
2. Click "Create Credentials" → "OAuth 2.0 Client IDs"
3. **Application type**: Android
4. **Name**: SocialCard Pro Android
5. **Package name**: `com.example.socialcard`
6. **SHA-1 certificate fingerprint**: `85:3B:6A:3C:FE:90:07:D9:84:EC:CD:2E:FC:5B:77:D6:F6:04:7B:26`
7. Click "Create"
8. **📋 Copy the Android Client ID** (will be like: `491082602859-xxxxxxx.apps.googleusercontent.com`)

### 2. Update Android Configuration

Replace this line in `android/app/google-services.json`:

```json
"client_id": "491082602859-android-client-id.apps.googleusercontent.com"
```

With your actual Android Client ID:

```json
"client_id": "491082602859-YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com"
```

### 3. Create iOS OAuth Credentials

1. Go to: https://console.cloud.google.com/apis/credentials?project=project-1-b618d
2. Click "Create Credentials" → "OAuth 2.0 Client IDs"
3. **Application type**: iOS
4. **Name**: SocialCard Pro iOS
5. **Bundle ID**: `com.example.socialcard`
6. Click "Create"
7. **📋 Copy the iOS Client ID** (will be like: `491082602859-yyyyyyy.apps.googleusercontent.com`)

### 4. Update iOS Configuration

#### A. Update `ios/Runner/GoogleService-Info.plist`:

Replace these lines:

```xml
<key>CLIENT_ID</key>
<string>491082602859-ios-client-id.apps.googleusercontent.com</string>
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.491082602859-ios-client-id</string>
```

With your actual iOS Client ID:

```xml
<key>CLIENT_ID</key>
<string>491082602859-YOUR_IOS_CLIENT_ID.apps.googleusercontent.com</string>
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.491082602859-YOUR_IOS_CLIENT_ID</string>
```

#### B. Update `ios/Runner/Info.plist`:

Replace this line:

```xml
<string>com.googleusercontent.apps.491082602859-ios-client-id</string>
```

With:

```xml
<string>com.googleusercontent.apps.491082602859-YOUR_IOS_CLIENT_ID</string>
```

---

## 🧪 Testing Commands

### Test Android

```bash
flutter run -d android
```

### Test iOS

```bash
flutter run -d ios
```

### Test Web (Already Working)

```bash
flutter run -d chrome
```

---

## 📋 Final Checklist

- [ ] Android OAuth credentials created in Google Cloud Console
- [ ] Android Client ID updated in `google-services.json`
- [ ] iOS OAuth credentials created in Google Cloud Console
- [ ] iOS Client ID updated in `GoogleService-Info.plist`
- [ ] iOS URL scheme updated in `Info.plist`
- [ ] Supabase authentication providers enabled
- [ ] Database schema deployed (`supabase_schema.sql`)

### Testing Results:

- [ ] Android Phone OTP working
- [ ] Android Google OAuth working
- [ ] iOS Phone OTP working
- [ ] iOS Google OAuth working
- [ ] Users created in Supabase Dashboard

---

## 🔗 Quick Links

- **Google Cloud Console**: https://console.cloud.google.com/apis/credentials?project=project-1-b618d
- **Supabase Dashboard**: https://jcovcivzcqgfxcxlzjfp.supabase.co
- **Your Project**: D:\2025\socialcard

---

**🎯 After completing these steps, your SocialCard Pro app will have full authentication working on Web, Android, and iOS with both Google OAuth and Phone OTP!**
