# 🚀 SocialCard Pro - Vercel Deployment Guide

This guide will help you deploy your SocialCard Pro Flutter web app to Vercel.

## 📋 Prerequisites

1. **Vercel Account**: Sign up at [vercel.com](https://vercel.com)
2. **Supabase Project**: Set up your database at [supabase.com](https://supabase.com)
3. **Google OAuth** (optional): Configure at [console.cloud.google.com](https://console.cloud.google.com)
4. **Flutter SDK**: Ensure Flutter is installed locally for testing

## 🔧 Setup Steps

### 1. Prepare Your Supabase Configuration

1. Go to your Supabase Dashboard
2. Navigate to **Settings** → **API**
3. Copy your:
   - **Project URL** (e.g., `https://abcdefgh.supabase.co`)
   - **Anon/Public Key** (starts with `eyJ...`)

### 2. Configure Google OAuth (Optional)

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing one
3. Enable Google+ API
4. Create OAuth 2.0 credentials
5. Add your Vercel domain to authorized origins:
   - `https://your-app-name.vercel.app`
   - `https://your-custom-domain.com` (if using custom domain)

### 3. Deploy to Vercel

#### Method A: Deploy from GitHub (Recommended)

1. **Push to GitHub**:

   ```bash
   git add .
   git commit -m "Add Vercel deployment configuration"
   git push origin main
   ```

2. **Import to Vercel**:

   - Go to [vercel.com/dashboard](https://vercel.com/dashboard)
   - Click "New Project"
   - Import your GitHub repository
   - Vercel will auto-detect the configuration from `vercel.json`

3. **Set Environment Variables** in Vercel Dashboard:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   GOOGLE_CLIENT_ID=123456789-abcdef.apps.googleusercontent.com
   ```

#### Method B: Deploy via Vercel CLI

1. **Install Vercel CLI**:

   ```bash
   npm i -g vercel
   ```

2. **Login to Vercel**:

   ```bash
   vercel login
   ```

3. **Deploy**:
   ```bash
   vercel --prod
   ```

### 4. Configure Environment Variables

In your Vercel project dashboard:

1. Go to **Settings** → **Environment Variables**
2. Add the following variables:

| Variable            | Value                                      | Description                 |
| ------------------- | ------------------------------------------ | --------------------------- |
| `SUPABASE_URL`      | `https://your-project.supabase.co`         | Your Supabase project URL   |
| `SUPABASE_ANON_KEY` | `eyJhbG...`                                | Your Supabase anonymous key |
| `GOOGLE_CLIENT_ID`  | `123456789-abc.apps.googleusercontent.com` | Google OAuth client ID      |

### 5. Update Supabase Redirect URLs

1. Go to Supabase Dashboard → **Authentication** → **URL Configuration**
2. Add your Vercel URLs to **Redirect URLs**:
   ```
   https://your-app-name.vercel.app/auth-callback.html
   https://your-custom-domain.com/auth-callback.html
   ```

## 🔧 Local Development

To test your app locally before deploying:

1. **Create local config**:

   ```bash
   cp web/config.template.js web/config.js
   ```

2. **Update config.js** with your actual credentials

3. **Run locally**:
   ```bash
   flutter run -d chrome
   ```

## 🚀 Build and Deploy

### Automatic Deployment

- Every push to `main` branch will trigger automatic deployment
- Vercel will run the build command defined in `vercel.json`

### Manual Build (for testing)

```bash
# Windows
./build_vercel.ps1

# Linux/Mac
./build_vercel.sh
```

## 🔍 Troubleshooting

### Common Issues

1. **Build Fails**:

   - Check Flutter version compatibility
   - Ensure all dependencies are properly specified in `pubspec.yaml`

2. **Configuration Errors**:

   - Verify environment variables are set correctly in Vercel
   - Check browser console for configuration errors

3. **Authentication Issues**:

   - Ensure redirect URLs are configured in Supabase
   - Verify Google OAuth settings match your domain

4. **Performance Issues**:
   - Web renderer is set to HTML for better compatibility
   - Consider enabling CanvasKit for better performance (update `vercel.json`)

### Debug Steps

1. **Check Vercel Function Logs**:

   - Go to Vercel Dashboard → Your Project → Functions tab

2. **Browser Console**:

   - Open developer tools
   - Check console for configuration errors

3. **Network Tab**:
   - Monitor API calls to Supabase
   - Check for CORS issues

## 🌐 Custom Domain (Optional)

1. **Add Domain in Vercel**:

   - Go to Project Settings → Domains
   - Add your custom domain

2. **Update DNS**:

   - Point your domain to Vercel's nameservers
   - Or add CNAME record to `cname.vercel-dns.com`

3. **Update Configurations**:
   - Add new domain to Supabase redirect URLs
   - Update Google OAuth authorized origins

## 📊 Monitoring

- **Analytics**: Built-in Vercel Analytics
- **Performance**: Use Vercel Speed Insights
- **Errors**: Monitor in browser console and Vercel logs

## 🎉 Success!

Your SocialCard Pro app should now be live at:

- `https://your-app-name.vercel.app`
- `https://your-custom-domain.com` (if configured)

## 📞 Support

If you encounter issues:

1. Check Vercel documentation
2. Review Supabase guides
3. Check Flutter web deployment guides
4. Open an issue in the project repository

---

**Happy Deploying! 🚀**
