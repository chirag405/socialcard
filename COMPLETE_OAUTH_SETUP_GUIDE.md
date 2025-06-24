# 🚀 Complete Google OAuth Setup Guide - All Platforms

## ⚠️ Your Project Was Deleted - Here's the Complete Recovery Process

Since you accidentally deleted your Google Cloud Platform project, we need to recreate everything from scratch. Follow this guide **step by step**.

---

## 📋 **Step 1: Create New Google Cloud Project**

1. **Go to**: https://console.cloud.google.com/
2. **Click**: "Select a project" dropdown → **NEW PROJECT**
3. **Project name**: `SocialCard Pro` (or your preferred name)
4. **Click**: **CREATE**
5. **Select your new project** from the dropdown

---

## 🔧 **Step 2: Enable Required APIs**

1. **Go to**: APIs & Services → Library
2. **Enable these APIs**:
   - Search **"Google+ API"** → Click **ENABLE**
   - Search **"Google Sign-In API"** → Click **ENABLE**

---

## 👥 **Step 3: Configure OAuth Consent Screen**

1. **Go to**: APIs & Services → **OAuth consent screen**
2. **User Type**: Select **External** → Click **CREATE**
3. **Fill out the required fields**:
   - **App name**: `SocialCard Pro`
   - **User support email**: Your email address
   - **Developer contact information**: Your email address
4. **Click**: **SAVE AND CONTINUE** through all steps
5. **Add Test Users** (for development): Add your email

---

## 🔑 **Step 4: Create OAuth Credentials (All Platforms)**

### **4.1 Web Application Credentials**

1. **Go to**: APIs & Services → **Credentials**
2. **Click**: **+ CREATE CREDENTIALS** → **OAuth 2.0 Client IDs**
3. **Application type**: **Web application**
4. **Name**: `SocialCard Pro Web`
5. **Authorized redirect URIs**: Add these **exactly**:
   ```
   https://jcovcivzcqgfxcxlzjfp.supabase.co/auth/v1/callback
   http://localhost:3000/
   ```
6. **Click**: **CREATE**
7. **📝 COPY THE CLIENT ID** - You'll need this for your code!

### **4.2 iOS Application Credentials**

1. **Click**: **+ CREATE CREDENTIALS** → **OAuth 2.0 Client IDs**
2. **Application type**: **iOS**
3. **Name**: `SocialCard Pro iOS`
4. **Bundle ID**: `com.example.socialcard`
5. **Click**: **CREATE**
6. **📝 COPY THE CLIENT ID** - You'll need this for iOS!

### **4.3 Android Application Credentials**

1. **Click**: **+ CREATE CREDENTIALS** → **OAuth 2.0 Client IDs**
2. **Application type**: **Android**
3. **Name**: `SocialCard Pro Android`
4. **Package name**: `com.example.socialcard`
5. **SHA-1 certificate fingerprint**: `85:3B:6A:3C:FE:90:07:D9:84:EC:CD:2E:FC:5B:77:D6:F6:04:7B:26`
6. **Click**: **CREATE**

---

## 📱 **Step 5: Download Configuration Files**

### **For Android:**

1. **Find your Android OAuth client** in the credentials list
2. **Click the download icon** (⬇️) next to it
3. **Download** `google-services.json`
4. **Place it at**: `android/app/google-services.json`

### **For iOS:**

1. **Find your iOS OAuth client** in the credentials list
2. **Click the download icon** (⬇️) next to it
3. **Download** `GoogleService-Info.plist`
4. **Place it at**: `ios/Runner/GoogleService-Info.plist`

---

## 💻 **Step 6: Update Your Code**

### **6.1 Update Web Client ID**

1. **Open**: `lib/services/supabase_service.dart`
2. **Find this line**:
   ```dart
   ? 'YOUR_NEW_WEB_CLIENT_ID.apps.googleusercontent.com' // Replace with your new web client ID from Google Cloud Console
   ```
3. **Replace** `YOUR_NEW_WEB_CLIENT_ID` with your **actual web client ID** from Step 4.1

### **6.2 Update iOS Configuration**

1. **Open**: `ios/Runner/Info.plist`
2. **Find**: `CFBundleURLSchemes` section
3. **Replace** the old client ID with your **new iOS client ID** from Step 4.2

---

## 🌐 **Step 7: Update Supabase Console**

1. **Go to**: https://supabase.com/dashboard/project/jcovcivzcqgfxcxlzjfp
2. **Navigate**: Authentication → Providers
3. **Find**: Google provider
4. **Enable it** and configure:
   - **Client ID**: Your **web client ID** from Step 4.1
   - **Client Secret**: Get this from Google Cloud Console (same credentials page)

---

## 🚀 **Step 8: Test Everything**

### **Test Web Authentication:**

```bash
flutter run -d chrome --web-port=3000
```

### **Test Android Authentication:**

```bash
flutter run -d android
```

### **Test iOS Authentication:**

```bash
flutter run -d ios
```

---

## 📝 **Summary - What You Need to Replace:**

1. **In `lib/services/supabase_service.dart`**:

   - Replace `YOUR_NEW_WEB_CLIENT_ID` with your web client ID

2. **In `ios/Runner/Info.plist`**:

   - Replace the old iOS client ID with your new one

3. **In Supabase Console**:

   - Add your web client ID and secret to Google provider

4. **File Placement**:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`

---

## 🆘 **If You Get Stuck:**

1. **Check console logs** in browser/device for specific errors
2. **Verify redirect URLs** match exactly in Google Cloud Console
3. **Ensure all APIs are enabled** in Google Cloud Console
4. **Double-check file placements** for config files

---

## ✅ **Success Indicators:**

- ✅ Google Sign-In popup appears (web)
- ✅ No "deleted_client" errors
- ✅ User successfully signs in
- ✅ User appears in Supabase Authentication dashboard
- ✅ User profile created in your database

---

**🎯 Next**: After you complete these steps, your Google OAuth will work on all platforms!
