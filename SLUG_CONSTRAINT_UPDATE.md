# Slug Constraint Update

## Overview

Updated the QR code slug validation system to allow different users to use the same custom slug, while preventing individual users from having duplicate active slugs.

## Changes Made

### 1. Database Schema Updates

#### Before:

- Global unique constraint on `link_slug` column
- No user could use a slug that any other user was already using

#### After:

- Removed global unique constraint on `link_slug`
- Added partial unique index: `idx_qr_configs_user_slug_active`
- Users can now reuse slugs that other users have, but cannot have duplicate active slugs themselves

### 2. Application Logic Updates

#### `SupabaseService.isSlugAvailable()` (lib/services/supabase_service.dart)

- **Before**: Checked if ANY user had the slug
- **After**: Only checks if the CURRENT user already has an active QR config with that slug
- Added authentication check to ensure user is logged in

#### Error Handling (lib/blocs/qr_link/qr_link_bloc.dart)

- Updated error message to be more user-friendly
- Changed from "This custom link is already taken" to "You already have an active QR code with this custom link"

#### UI Updates (lib/screens/qr/qr_create_screen.dart)

- Updated SnackBar action condition to match new error message

### 3. Database Migration

#### For New Installations:

- Use the updated `supabase_schema.sql`

#### For Existing Databases:

- Run `database_migration_slug_constraint.sql` to:
  1. Drop old unique constraint
  2. Add new partial unique index
  3. Verify migration success

### 4. Technical Details

#### New Database Constraint:

```sql
CREATE UNIQUE INDEX idx_qr_configs_user_slug_active
ON qr_configs(user_id, link_slug)
WHERE is_active = TRUE;
```

This constraint ensures:

- ✅ Different users can use the same slug (e.g., both user A and user B can have slug "abc")
- ✅ Same user can reuse slugs from their inactive QR codes
- ❌ Same user cannot have multiple active QR codes with the same slug

#### Benefits:

1. **User-friendly**: No more "slug already taken" errors when another user has the same slug
2. **Flexible**: Users can reuse popular slug names
3. **Consistent**: Still prevents user confusion from duplicate active slugs per user
4. **Scalable**: Reduces slug namespace conflicts as the user base grows

## Testing

To test the changes:

1. Create a QR code with a custom slug (e.g., "test123")
2. Have another user create a QR code with the same slug - should succeed
3. Try to create another active QR code with the same slug as the same user - should fail with user-friendly error
4. Deactivate the first QR code and create a new one with the same slug - should succeed

### 5. URL Structure Changes

#### New URL Format:

To properly handle multiple users with the same slug, URLs now include user identification:

**Before:**

- `https://yourdomain.com/profile.html?slug=abc`

**After:**

- `https://yourdomain.com/profile.html?slug=abc&user=user-id-123`

#### Impact:

- **Different users can now use the same slug without conflicts**
- **QR codes generated with the new system include user context**
- **Scanner properly resolves to the correct user's profile**

#### Legacy Support:

- Old QR codes without user ID still work (first-found basis)
- New QR codes include user ID for guaranteed accuracy

## Backwards Compatibility

The changes are backwards compatible with existing QR codes:

- ✅ Existing QR codes continue to work (uses first-found matching slug)
- ✅ Users immediately benefit from relaxed constraints
- ✅ No data migration needed for existing records
- ✅ New QR codes include user context for guaranteed accuracy
