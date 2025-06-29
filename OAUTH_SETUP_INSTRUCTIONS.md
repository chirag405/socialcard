# 🔧 **CRITICAL: Fix Google OAuth Port Issue**

## **Problem**

You're getting "ERR_CONNECTION_REFUSED" because Google OAuth is trying to redirect to a port that doesn't have a server running.

## **Root Cause**

The Google Cloud Console redirect URIs don't match the current app configuration.

## **IMMEDIATE SOLUTION** 🚨

### **1. Update Google Cloud Console RIGHT NOW**

1. Go to: https://console.cloud.google.com/apis/credentials
2. Find your OAuth 2.0 Client ID: `491082602859-5nd8u3ihd7m5guk6e4cqugp1tg0gq31l.apps.googleusercontent.com`
3. Click **Edit** (pencil icon)
4. **REPLACE ALL** Authorized redirect URIs with EXACTLY these:

```
https://jcovcivzcqgfxcxlzjfp.supabase.co/auth/v1/callback
http://localhost:3001
```

5. **REPLACE ALL** Authorized JavaScript origins with EXACTLY these:

```
http://localhost:3001
https://jcovcivzcqgfxcxlzjfp.supabase.co
```

6. **REMOVE** any other URLs (especially port 3000 ones)
7. Click **Save**

### **2. Test Steps**

1. **Clear browser cache completely** (Ctrl+Shift+Delete)
2. **Restart your Flutter app** (if it's running)
3. **Try OAuth again**

### **3. Current App Configuration**

Your app is configured to:

- Run on: `http://localhost:3001`
- Redirect to: `http://localhost:3001` (after OAuth)
- Use Supabase callback: `https://jcovcivzcqgfxcxlzjfp.supabase.co/auth/v1/callback`

### **4. Expected OAuth Flow**

```
1. Click "Continue with Google"
2. Redirect to Google OAuth ✅
3. User grants permission ✅
4. Google redirects to: http://localhost:3001/?code=XXXX ✅
5. App processes the code ✅
6. User authenticated and goes to home screen ✅
```

### **5. Debug Information**

If you're still having issues, check browser console for:

- `🔗 SupabaseService: Redirect URL: http://localhost:3001`
- `🔗 AuthBloc: Current URL: http://localhost:3001/?code=XXXX`
- `🔗 AuthBloc: Found authorization code: XXXX`

### **6. If Still Not Working**

Try these steps:

1. **Kill all Chrome processes** completely
2. **Restart Flutter app**: `flutter run -d chrome --web-port=3001`
3. **Clear all browser data** for localhost
4. **Try OAuth flow again**

---

**🎯 This MUST work once Google Console is updated correctly!**
