# 🔄 Automatic QR Code Cleanup System

## Overview

Your SocialCard app now includes an automatic cleanup system that manages expired QR codes and keeps your database clean. This system runs automatically in the background without any manual intervention required.

## ✨ New Features

### 1. **Default 5-minute Expiry**

- All new QR codes now default to **5 minutes expiry** from creation time
- Quick preset buttons available: 5min, 1hour, 1day, 1week
- Date & time picker for custom expiry times
- Shows precise expiry time including hours and minutes

### 2. **All Links Selected by Default**

- When creating a QR code, all your social links are automatically selected
- No need to manually check each link you want to share
- You can still unselect specific links if needed

### 3. **Automatic Database Cleanup**

- **Every 5 minutes**: System checks for expired QR codes and deactivates them
- **Daily at 2 AM**: Removes old inactive QR codes (older than 30 days)
- **Instant expiry**: QR codes expire immediately when max scans reached or one-time use triggered

## 🛠 Technical Implementation

### Database Functions

```sql
-- Deactivates expired QR configs based on expiry settings
deactivate_expired_qr_configs()

-- Cleans up old inactive QR configs (30+ days old)
cleanup_old_qr_configs()

-- Checks expiry conditions on each scan
check_expiry_on_scan()
```

### Automatic Triggers

- **Scan Trigger**: Automatically deactivates QR codes when max scans reached
- **Scheduled Jobs**: Uses pg_cron extension for periodic cleanup
- **Real-time Expiry**: Checks expiry date on every access

## 📊 Expiry Conditions

A QR code will be automatically deactivated when:

1. **Date Expiry**: Current time passes the set expiry date
2. **Max Scans**: Number of scans reaches the maximum limit
3. **One-time Use**: QR code is scanned once (if one-time use is enabled)

## 🗄 Database Schema Updates

### New Cleanup Functions

- `deactivate_expired_qr_configs()` - Runs every 5 minutes
- `cleanup_old_qr_configs()` - Runs daily at 2 AM
- `check_expiry_on_scan()` - Trigger on scan updates

### Scheduled Jobs

```sql
-- Every 5 minutes: Check for expired configs
SELECT cron.schedule('deactivate-expired-qr-configs', '*/5 * * * *', 'SELECT deactivate_expired_qr_configs();');

-- Daily at 2 AM: Clean up old configs
SELECT cron.schedule('cleanup-old-qr-configs', '0 2 * * *', 'SELECT cleanup_old_qr_configs();');
```

## 🔧 Setup Requirements

### 1. Enable pg_cron Extension

In your Supabase dashboard:

1. Go to **Database** → **Extensions**
2. Search for `pg_cron`
3. Enable the extension
4. Run the updated `supabase_schema.sql`

### 2. Run Updated Schema

Execute the updated `supabase_schema.sql` file in your Supabase SQL editor to add:

- New cleanup functions
- Automatic triggers
- Scheduled cron jobs

## 📱 User Experience

### Creating QR Codes

1. **Default Settings**: 5-minute expiry, all links selected
2. **Quick Presets**: One-click buttons for common durations
3. **Custom Times**: Full date & time picker for precise control
4. **Visual Feedback**: Clear display of selected expiry time

### Automatic Management

- Expired QR codes stop working immediately
- No manual cleanup required
- Database stays optimized automatically
- Old data is safely removed after 30 days

## 🔍 Monitoring

### Logs

The system logs cleanup activities:

- `Deactivated expired QR configs at [timestamp]`
- `Cleaned up old QR configs at [timestamp]`

### Manual Cleanup (Optional)

You can manually trigger cleanup functions:

```sql
-- Manually deactivate expired configs
SELECT deactivate_expired_qr_configs();

-- Manually clean up old configs
SELECT cleanup_old_qr_configs();
```

## 🚀 Benefits

1. **Performance**: Database stays clean and fast
2. **Security**: Expired QR codes stop working immediately
3. **Storage**: Old data is automatically removed
4. **User Experience**: Sensible defaults, easy customization
5. **Maintenance**: Zero manual intervention required

## 📋 Migration Checklist

- [ ] Enable `pg_cron` extension in Supabase
- [ ] Run updated `supabase_schema.sql`
- [ ] Verify cron jobs are scheduled
- [ ] Test QR code creation with new defaults
- [ ] Confirm automatic expiry works

## 🆘 Troubleshooting

### Cron Jobs Not Running

1. Ensure `pg_cron` extension is enabled
2. Check Supabase logs for any errors
3. Verify cron job syntax in database

### QR Codes Not Expiring

1. Check if expiry settings are properly saved
2. Verify triggers are installed correctly
3. Test manual cleanup functions

---

🎉 **Your QR codes now have intelligent automatic management!**

The system will keep your database clean and ensure expired QR codes stop working immediately, all without any manual intervention required.
