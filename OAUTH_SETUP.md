# 🔑 Google OAuth Setup Guide

## Current Status: ❌ **Google OAuth Not Configured**

Your Supabase credentials are working, but Google OAuth needs to be set up for authentication to work properly.

## 🚀 **Quick Setup Steps**

### **Step 1: Get Google OAuth Client ID**

1. **Go to Google Cloud Console**: https://console.cloud.google.com
2. **Create or select a project**
3. **Enable Google Sign-In API**:
   - Navigation Menu → APIs & Services → Library
   - Search for "Google+ API" → Click → Enable
4. **Create OAuth credentials**:
   - APIs & Services → Credentials → "Create Credentials" → "OAuth 2.0 Client IDs"
   - Application type: **Web application**
   - Name: `SocialCard Pro Web`
5. **Add authorized origins**:
   ```
   http://localhost:3000
   https://socialcard-pro.netlify.app
   ```
6. **Add redirect URIs**:

   ```
   http://localhost:3000/auth-callback.html
   https://socialcard-pro.netlify.app/auth-callback.html
   ```

7. **Copy the Client ID** (looks like: `123456789-abc123.apps.googleusercontent.com`)

### **Step 2: Update Your Configuration**

**A. Update Flutter config** (`lib/supabase_config.dart` line ~27):

```dart
defaultValue: 'PASTE_YOUR_CLIENT_ID_HERE', // Replace with actual ID
```

**B. Update Web config** (`web/config.js` line ~13):

```javascript
GOOGLE_CLIENT_ID: "PASTE_YOUR_CLIENT_ID_HERE", // Replace with actual ID
```

### **Step 3: Verify Configuration**

Run the checker:

```bash
dart check-config.dart
```

You should see all ✅ green checkmarks!

## 📱 **Mobile OAuth Setup (Optional)**

For mobile apps, you also need:

### **Android** (`android/app/google-services.json`):

- ✅ **Already exists** (good!)
- Download from Firebase Console if you need to update it

### **iOS** (`ios/Runner/GoogleService-Info.plist`):

- ✅ **Already exists** (good!)
- Download from Firebase Console if you need to update it

## 🔍 **Troubleshooting**

### **Common Issues:**

**1. "Invalid Client" error:**

- Check that your domains are added to authorized origins
- Verify redirect URIs are exactly correct

**2. "Redirect URI mismatch":**

- Make sure redirect URIs include `/auth-callback.html`
- Check spelling of your domain

**3. OAuth popup blocked:**

- Test in incognito mode
- Check browser popup blocker settings

### **Testing OAuth:**

1. **Development**: `http://localhost:3000` → try Google sign-in
2. **Production**: `https://socialcard-pro.netlify.app` → try Google sign-in

## 🎯 **What Happens After Setup**

Once configured, users can:

- ✅ Sign in with Google (web & mobile)
- ✅ Create QR codes linked to their profile
- ✅ Share contact info via QR scanning
- ✅ Manage custom social links

## 📋 **Configuration Checklist**

- [ ] Google Cloud project created
- [ ] Google+ API enabled
- [ ] OAuth 2.0 client ID created
- [ ] Authorized origins added
- [ ] Redirect URIs added
- [ ] Client ID copied
- [ ] Flutter config updated (`lib/supabase_config.dart`)
- [ ] Web config updated (`web/config.js`)
- [ ] Configuration checker passes
- [ ] OAuth tested in development
- [ ] OAuth tested in production

---

## 🔗 **Quick Links**

- **Google Cloud Console**: https://console.cloud.google.com
- **API Library**: https://console.cloud.google.com/apis/library
- **Credentials**: https://console.cloud.google.com/apis/credentials
- **Supabase Dashboard**: https://supabase.com/dashboard

Once you complete these steps, run `dart check-config.dart` again to verify everything is set up correctly! 🎉
