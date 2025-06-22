# SocialCard Pro - Supabase Migration Checklist

## ✅ Completed (by migration script)

- [x] Updated `pubspec.yaml` dependencies (Firebase → Supabase)
- [x] Created `lib/services/supabase_service.dart`
- [x] Updated `lib/blocs/auth/auth_bloc.dart` for Supabase
- [x] Updated `lib/blocs/profile/profile_bloc.dart` for Supabase
- [x] Updated `lib/blocs/qr_link/qr_link_bloc.dart` for Supabase
- [x] Updated `lib/main.dart` to initialize Supabase
- [x] Created `supabase_schema.sql` database schema
- [x] Created `lib/supabase_config.dart` configuration file
- [x] Updated `web/profile.html` for Supabase (already done)
- [x] Removed old Firebase files
- [x] Created migration documentation

## 🔧 TODO: Complete these steps

### 1. Set up Supabase Project

- [ ] Create account at [supabase.com](https://supabase.com)
- [ ] Create new project named "socialcard-pro"
- [ ] Save database password securely

### 2. Configure Database

- [ ] Go to SQL Editor in Supabase dashboard
- [ ] Copy and run the entire `supabase_schema.sql` file
- [ ] Verify all tables created in Table Editor

### 3. Update Configuration

- [ ] Get Project URL and Anon Key from Settings → API
- [ ] Update `lib/supabase_config.dart`:
  ```dart
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
  ```
- [ ] Update `web/profile.html` with same credentials

### 4. Configure Authentication (Optional)

- [ ] Go to Authentication → Providers
- [ ] Enable Google OAuth with your credentials
- [ ] Enable Phone auth if needed
- [ ] Add redirect URLs

### 5. Test the App

- [ ] Run `flutter run`
- [ ] Test Google sign-in
- [ ] Create a QR code
- [ ] Test profile viewing
- [ ] Verify data saves to Supabase tables

### 6. Deploy

- [ ] Choose hosting platform (Vercel, Netlify, or Firebase Hosting)
- [ ] Build web app: `flutter build web`
- [ ] Deploy and test production

## 🚀 Benefits You'll Get

- **Instant Changes**: No waiting for Firestore indexes
- **Clear Permissions**: PostgreSQL RLS is much clearer
- **Better Errors**: Descriptive error messages
- **Real-time**: Built-in subscriptions
- **SQL Power**: Complex queries, joins, full-text search
- **Cost Effective**: Generous free tier

## 📞 Need Help?

- Read the full `SUPABASE_MIGRATION_GUIDE.md`
- Check [Supabase Documentation](https://supabase.com/docs)
- Join [Supabase Discord](https://discord.supabase.com)

## 🔄 Rollback Plan

If anything goes wrong, you can restore the original Firebase code from git:

```bash
git checkout HEAD~1 -- lib/
git checkout HEAD~1 -- pubspec.yaml
flutter pub get
```

**Estimated Time**: 1-2 hours for complete setup and testing

Good luck! 🎉
