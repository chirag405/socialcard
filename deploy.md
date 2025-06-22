# SocialCard Deployment Guide

## Quick Deployment Commands

### 1. Build and Deploy

```bash
# Build the Flutter web app
flutter build web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### 2. One-line Deploy (after initial setup)

```bash
flutter build web && firebase deploy --only hosting
```

## Your Live URLs

- **Main App:** https://project-1-b618d.web.app
- **Firebase Console:** https://console.firebase.google.com/project/project-1-b618d/overview

## Custom Domain Setup

1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Enter your domain name
4. Follow DNS verification steps
5. Update DNS records at your domain registrar

## Firebase Hosting Features (Free Tier)

- ✅ 10 GB storage
- ✅ 125 GB/month transfer
- ✅ Custom domain support
- ✅ SSL certificates (automatic)
- ✅ Global CDN
- ✅ Rollback support

## Troubleshooting

- If build fails: `flutter clean && flutter pub get`
- If deploy fails: Check Firebase project permissions
- For custom domain issues: Verify DNS propagation (can take 24-48 hours)

## Project Configuration

- Project ID: `project-1-b618d`
- Build output: `build/web`
- Firebase config: `firebase.json`
