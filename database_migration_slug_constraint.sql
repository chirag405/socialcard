-- Migration: Update slug constraints to allow same slug across different users
-- Run this in your Supabase SQL Editor to update existing databases

-- Step 1: Drop the existing unique constraint on link_slug
-- Note: This will temporarily allow duplicate slugs globally
ALTER TABLE qr_configs DROP CONSTRAINT IF EXISTS qr_configs_link_slug_key;

-- Step 2: Create new partial unique index that only applies to active configs per user
-- This allows different users to have the same slug, but prevents duplicate active slugs per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_qr_configs_user_slug_active 
ON qr_configs(user_id, link_slug) 
WHERE is_active = TRUE;

-- Step 3: Add a comment for documentation
COMMENT ON INDEX idx_qr_configs_user_slug_active IS 
'Ensures each user can only have one active QR config per slug, but allows same slug across different users';

-- Verify the migration worked
DO $$
BEGIN
    -- Check if the old constraint is gone
    IF EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'qr_configs_link_slug_key' 
        AND table_name = 'qr_configs'
    ) THEN
        RAISE WARNING 'Old unique constraint still exists on link_slug';
    ELSE
        RAISE NOTICE 'Old unique constraint successfully removed';
    END IF;
    
    -- Check if the new index exists
    IF EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE indexname = 'idx_qr_configs_user_slug_active'
    ) THEN
        RAISE NOTICE 'New partial unique index successfully created';
    ELSE
        RAISE WARNING 'New partial unique index was not created';
    END IF;
END $$; 