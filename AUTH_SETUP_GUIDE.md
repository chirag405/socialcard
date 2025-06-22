# 🔐 Authentication Setup Guide - SocialCard Pro

## Prerequisites ✅

- [x] Supabase project created: `jcovcivzcqgfxcxlzjfp`
- [x] Flutter app configured with Supabase
- [x] Code updated for authentication

## Step 1: Supabase Console Setup

### 1.1 Access Your Project

1. Go to https://supabase.com/dashboard
2. Click on your project: **jcovcivzcqgfxcxlzjfp**

### 1.2 Enable Phone Authentication (OTP)

1. **Navigate**: Authentication → Providers
2. **Find "Phone"** in the provider list
3. **Toggle ON**: "Enable Phone provider"
4. **SMS Service**: Use "Supabase SMS" (built-in, limited free tier)
5. **Click "Save"**

### 1.3 Enable Google Authentication

1. **Still in**: Authentication → Providers
2. **Find "Google"** in the provider list
3. **Toggle ON**: "Enable Google provider"
4. **Leave empty for now** (we'll add credentials in Step 2)
5. **Click "Save"**

### 1.4 Configure Authentication Settings

1. **Navigate**: Authentication → Settings
2. **Site URL**: `http://localhost:3000`
3. **Additional Redirect URLs**: Add these one by one:
   ```
   http://localhost:3000/auth/callback
   https://jcovcivzcqgfxcxlzjfp.supabase.co/auth/v1/callback
   ```
4. **Click "Save"**

## Step 2: Google Cloud Console Setup

### 2.1 Create Google Cloud Project

1. Go to https://console.cloud.google.com
2. **Create new project** or select existing
3. **Project name**: "SocialCard Pro" (or any name)

### 2.2 Enable Google+ API

1. **Navigate**: APIs & Services → Library
2. **Search**: "Google+ API"
3. **Click** on it and **Enable**

### 2.3 Create OAuth Credentials

1. **Navigate**: APIs & Services → Credentials
2. **Click**: "Create Credentials" → "OAuth 2.0 Client IDs"
3. **Application type**: Web application
4. **Name**: SocialCard Pro Web
5. **Authorized redirect URIs**: Add both:
   ```
   https://jcovcivzcqgfxcxlzjfp.supabase.co/auth/v1/callback
   http://localhost:3000/auth/callback
   ```
6. **Click "Create"**
7. **📋 COPY** both Client ID and Client Secret

### 2.4 Add Google Credentials to Supabase

1. **Back to Supabase**: Authentication → Providers → Google
2. **Paste your credentials**:
   - **Client ID**: `your-client-id.apps.googleusercontent.com`
   - **Client Secret**: `your-client-secret`
3. **Click "Save"**

## Step 3: Update Flutter App

### 3.1 Update Google Client ID in Code

1. **Open**: `lib/services/supabase_service.dart`
2. **Find line ~17**: `YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com`
3. **Replace** with your actual Client ID from Step 2.3

### 3.2 Build and Test

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Test the app
flutter run -d chrome
```

## Step 4: Create Database Schema

### 4.1 Run Database Schema

1. **Supabase Dashboard**: SQL Editor
2. **Copy and paste** the contents of `supabase_schema.sql`
3. **Click "Run"**

### 4.2 Verify Tables Created

1. **Navigate**: Database → Tables
2. **Should see**:
   - ✅ users
   - ✅ custom_links
   - ✅ qr_configs
   - ✅ qr_visits
   - ✅ qr_presets
   - ✅ saved_contacts

## Step 5: Test Authentication

### 5.1 Test Phone OTP

1. **Run your app**: `flutter run`
2. **Click**: "Sign in with Phone"
3. **Enter**: Your phone number (with country code: +1234567890)
4. **Check**: You receive SMS with OTP code
5. **Enter**: OTP code
6. **Verify**: You're logged in

### 5.2 Test Google Auth

1. **Click**: "Sign in with Google"
2. **Verify**: Google OAuth popup appears
3. **Sign in**: With your Google account
4. **Check**: You're redirected back and logged in

## Step 6: Verify Database

### 6.1 Check User Creation

1. **Supabase Dashboard**: Authentication → Users
2. **Should see**: Your test users listed
3. **Database → Tables → users**: Should have user records

### 6.2 Test Row Level Security

1. **SQL Editor**: Try this query:
   ```sql
   SELECT * FROM users;
   ```
2. **Should see**: Only your own user data (RLS working)

## 🚨 Troubleshooting

### Phone OTP Issues

- **No SMS received**: Check phone number format (+1234567890)
- **Invalid OTP**: Check if OTP expired (usually 5 minutes)
- **Rate limited**: Wait before requesting new OTP

### Google Auth Issues

- **Popup blocked**: Allow popups for localhost
- **Invalid redirect**: Double-check redirect URLs match exactly
- **Client ID error**: Verify Client ID is correct in both Supabase and code

### General Issues

- **CORS errors**: Make sure Site URL is set correctly
- **Database errors**: Check if schema was run successfully
- **RLS blocking**: Verify policies are set up correctly

## ✅ Success Checklist

- [ ] Phone OTP working (SMS received and verified)
- [ ] Google OAuth working (popup and redirect successful)
- [ ] Users created in Supabase Authentication
- [ ] User profiles created in database
- [ ] App navigates to home screen after login
- [ ] No console errors during authentication

## 🔧 Next Steps

After authentication is working:

1. **Production setup**: Update redirect URLs for your domain
2. **SMS provider**: Configure Twilio/MessageBird for production
3. **Security**: Review and tighten RLS policies
4. **Monitoring**: Set up Supabase monitoring and alerts

---

**Need help?** Check the console logs in your browser/app for specific error messages.
