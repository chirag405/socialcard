# 🔧 Fix Authentication Redirect Issue

## Problem

You're getting `ERR_CONNECTION_REFUSED` because the redirect URL is set to `/auth/callback` but your Flutter app doesn't have that route.

## ✅ Solution Applied

I've updated your configuration to redirect to the root URL instead:

- Changed from: `http://localhost:3000/auth/callback`
- Changed to: `http://localhost:3000/`

## 🚀 Next Steps

### 1. Update Supabase Console Settings

1. **Go to**: https://supabase.com/dashboard/project/jcovcivzcqgfxcxlzjfp
2. **Navigate**: Authentication → Settings
3. **Site URL**: Change to `http://localhost:3000`
4. **Additional Redirect URLs**: Update to:
   ```
   http://localhost:3000/
   https://jcovcivzcqgfxcxlzjfp.supabase.co/auth/v1/callback
   ```
5. **Click "Save"**

### 2. Update Google Cloud Console

1. **Go to**: https://console.cloud.google.com/apis/credentials?project=project-1-b618d
2. **Find your Web OAuth Client**
3. **Edit** the credentials
4. **Authorized redirect URIs**: Update to:
   ```
   https://jcovcivzcqgfxcxlzjfp.supabase.co/auth/v1/callback
   http://localhost:3000/
   ```
5. **Save**

### 3. Test the Fix

1. **Restart** your Flutter web app:
   ```bash
   # Stop the current app (Ctrl+C in terminal)
   flutter run -d chrome --web-port=3000
   ```
2. **Try Google Sign-In** again
3. **Should redirect** to `http://localhost:3000/` instead of `/auth/callback`

## 🎯 Expected Flow

1. Click "Sign in with Google"
2. Google OAuth popup/redirect
3. After authentication, redirect to `http://localhost:3000/`
4. Your app's auth state listener detects the user
5. Automatically navigates to HomeScreen

## 🚨 If Still Having Issues

### Alternative: Add Proper Routing

If you prefer to keep the `/auth/callback` route, I can add proper routing to your Flutter app. Let me know!

### Check These:

- [ ] Supabase redirect URLs updated
- [ ] Google Cloud redirect URLs updated
- [ ] Flutter app running on port 3000
- [ ] No browser cache issues (try incognito mode)

---

**🎯 The redirect issue should be fixed after updating the Supabase and Google Cloud Console settings!**
