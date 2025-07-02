-- SocialCard Pro - Supabase Database Schema
-- Run this in your Supabase SQL Editor

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL DEFAULT '',
    email TEXT NOT NULL DEFAULT '',
    phone TEXT,
    profile_image_url TEXT,
    bio TEXT,
    is_discoverable BOOLEAN DEFAULT TRUE,
    normalized_phone TEXT, -- For phone number queries
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Custom links table
CREATE TABLE custom_links (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    display_name TEXT NOT NULL,
    icon_name TEXT DEFAULT 'link',
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- QR configurations table
CREATE TABLE qr_configs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    link_slug TEXT NOT NULL,
    description TEXT DEFAULT '',
    selected_link_ids TEXT[] DEFAULT '{}',
    qr_customization JSONB DEFAULT '{}',
    expiry_settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    scan_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- QR visits table (for analytics)
CREATE TABLE qr_visits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    config_id UUID REFERENCES qr_configs(id) ON DELETE CASCADE,
    user_agent TEXT,
    ip_address TEXT,
    visited_at TIMESTAMPTZ DEFAULT NOW()
);

-- QR presets table (saved QR configurations)
CREATE TABLE qr_presets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT DEFAULT '',
    selected_link_ids TEXT[] DEFAULT '{}',
    qr_customization JSONB DEFAULT '{}',
    expiry_settings JSONB DEFAULT '{}',
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Saved contacts table
CREATE TABLE saved_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    contact_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    scanned_at TIMESTAMPTZ DEFAULT NOW(),
    last_updated TIMESTAMPTZ,
    has_updates BOOLEAN DEFAULT FALSE,
    notes TEXT,
    UNIQUE(user_id, contact_user_id)
);

-- Unique constraint: prevent user from having multiple active configs with same slug
-- This allows different users to have the same slug, but prevents duplicate active slugs per user
CREATE UNIQUE INDEX idx_qr_configs_user_slug_active 
ON qr_configs(user_id, link_slug) 
WHERE is_active = TRUE;

-- Indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_normalized_phone ON users(normalized_phone);
CREATE INDEX idx_custom_links_user_id ON custom_links(user_id);
CREATE INDEX idx_custom_links_order ON custom_links(user_id, order_index);
CREATE INDEX idx_qr_configs_user_id ON qr_configs(user_id);
CREATE INDEX idx_qr_configs_slug ON qr_configs(link_slug);
CREATE INDEX idx_qr_configs_active ON qr_configs(is_active);
CREATE INDEX idx_qr_visits_config_id ON qr_visits(config_id);
CREATE INDEX idx_qr_visits_date ON qr_visits(visited_at);
CREATE INDEX idx_qr_presets_user_id ON qr_presets(user_id);
CREATE INDEX idx_saved_contacts_user_id ON saved_contacts(user_id);

-- Row Level Security (RLS) Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE qr_presets ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_contacts ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Public profile viewing for active QR configs
CREATE POLICY "Public can view discoverable user profiles" ON users
    FOR SELECT USING (
        is_discoverable = TRUE OR 
        EXISTS (
            SELECT 1 FROM qr_configs 
            WHERE qr_configs.user_id = users.id 
            AND qr_configs.is_active = TRUE
        )
    );

-- Custom links policies
CREATE POLICY "Users can manage their own custom links" ON custom_links
    FOR ALL USING (auth.uid() = user_id);

-- Public can view custom links for active QR configs
CREATE POLICY "Public can view custom links for active QR configs" ON custom_links
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM qr_configs 
            WHERE qr_configs.user_id = custom_links.user_id 
            AND qr_configs.is_active = TRUE
        )
    );

-- QR configs policies
CREATE POLICY "Users can manage their own QR configs" ON qr_configs
    FOR ALL USING (auth.uid() = user_id);

-- Public can view active QR configs
CREATE POLICY "Public can view active QR configs" ON qr_configs
    FOR SELECT USING (is_active = TRUE);

-- QR visits policies
CREATE POLICY "Anyone can create visit records" ON qr_visits
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can view visits for their QR configs" ON qr_visits
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM qr_configs 
            WHERE qr_configs.id = qr_visits.config_id 
            AND qr_configs.user_id = auth.uid()
        )
    );

-- QR presets policies
CREATE POLICY "Users can manage their own QR presets" ON qr_presets
    FOR ALL USING (auth.uid() = user_id);

-- Saved contacts policies
CREATE POLICY "Users can manage their own saved contacts" ON saved_contacts
    FOR ALL USING (auth.uid() = user_id);

-- Functions for automatic updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_custom_links_updated_at BEFORE UPDATE ON custom_links
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_qr_configs_updated_at BEFORE UPDATE ON qr_configs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_qr_presets_updated_at BEFORE UPDATE ON qr_presets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to increment scan count safely
CREATE OR REPLACE FUNCTION increment_scan_count(config_uuid UUID)
RETURNS void AS $$
BEGIN
    UPDATE qr_configs 
    SET scan_count = scan_count + 1,
        updated_at = NOW()
    WHERE id = config_uuid;
END;
$$ LANGUAGE plpgsql;

-- Function to automatically deactivate expired QR configs
CREATE OR REPLACE FUNCTION deactivate_expired_qr_configs()
RETURNS void AS $$
BEGIN
    -- Deactivate QR configs that have expired based on expiry_settings
    UPDATE qr_configs 
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE is_active = TRUE 
    AND (
        -- Check if expiry date has passed
        (expiry_settings->>'expiryDate' IS NOT NULL 
         AND (expiry_settings->>'expiryDate')::timestamptz < NOW())
        OR
        -- Check if max scans reached
        (expiry_settings->>'maxScans' IS NOT NULL 
         AND scan_count >= (expiry_settings->>'maxScans')::integer)
        OR
        -- Check if one-time use and already scanned
        (expiry_settings->>'isOneTime' = 'true' AND scan_count > 0)
    );
    
    RAISE NOTICE 'Deactivated expired QR configs at %', NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to clean up old expired QR configs (optional - removes after 30 days)
CREATE OR REPLACE FUNCTION cleanup_old_qr_configs()
RETURNS void AS $$
BEGIN
    -- Delete QR configs that have been inactive for more than 30 days
    DELETE FROM qr_configs 
    WHERE is_active = FALSE 
    AND updated_at < NOW() - INTERVAL '30 days';
    
    -- Delete old QR visits for deleted configs (cleanup orphaned data)
    DELETE FROM qr_visits 
    WHERE config_id NOT IN (SELECT id FROM qr_configs);
    
    RAISE NOTICE 'Cleaned up old QR configs at %', NOW();
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to automatically check for expired configs on each scan
CREATE OR REPLACE FUNCTION check_expiry_on_scan()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if this config should be expired after the scan
    IF NEW.scan_count != OLD.scan_count THEN
        -- A scan just happened, check if we need to deactivate
        IF (NEW.expiry_settings->>'maxScans' IS NOT NULL 
            AND NEW.scan_count >= (NEW.expiry_settings->>'maxScans')::integer)
        OR (NEW.expiry_settings->>'isOneTime' = 'true' AND NEW.scan_count > 0) THEN
            NEW.is_active = FALSE;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to qr_configs table
CREATE TRIGGER check_expiry_after_scan
    BEFORE UPDATE ON qr_configs
    FOR EACH ROW
    EXECUTE FUNCTION check_expiry_on_scan();

-- Set up automatic cleanup job (runs every 5 minutes)
-- Note: This requires pg_cron extension to be enabled in Supabase
-- You can enable it in Supabase Dashboard > Database > Extensions
SELECT cron.schedule(
    'deactivate-expired-qr-configs',
    '*/5 * * * *', -- Every 5 minutes
    'SELECT deactivate_expired_qr_configs();'
);

-- Set up daily cleanup of old configs (runs at 2 AM daily)
SELECT cron.schedule(
    'cleanup-old-qr-configs', 
    '0 2 * * *', -- Daily at 2 AM
    'SELECT cleanup_old_qr_configs();'
);

-- View for user profiles with custom links (for easier querying)
CREATE VIEW user_profiles_with_links AS
SELECT 
    u.*,
    COALESCE(
        json_agg(
            json_build_object(
                'id', cl.id,
                'url', cl.url,
                'display_name', cl.display_name,
                'icon_name', cl.icon_name,
                'order_index', cl.order_index
            ) ORDER BY cl.order_index
        ) FILTER (WHERE cl.id IS NOT NULL), 
        '[]'::json
    ) as custom_links
FROM users u
LEFT JOIN custom_links cl ON u.id = cl.user_id
GROUP BY u.id, u.name, u.email, u.phone, u.profile_image_url, u.bio, u.is_discoverable, u.normalized_phone, u.created_at, u.updated_at; 