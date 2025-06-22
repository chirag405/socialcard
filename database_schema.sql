-- Database Schema for SocialCard Pro Backend

-- Users table
CREATE TABLE users (
    id VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255),
    photo_url TEXT,
    phone_number VARCHAR(50),
    bio TEXT,
    is_discoverable BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Custom links table
CREATE TABLE custom_links (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    url TEXT NOT NULL,
    icon_name VARCHAR(100),
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_order (user_id, order_index)
);

-- QR configurations table
CREATE TABLE qr_configs (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    link_slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    selected_link_ids JSON,
    qr_customization JSON,
    expiry_settings JSON,
    is_active BOOLEAN DEFAULT true,
    scan_count INTEGER DEFAULT 0,
    max_scans INTEGER,
    expires_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_slug (link_slug),
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_expiry (expires_at)
);

-- Visit tracking table (optional)
CREATE TABLE qr_visits (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    config_id VARCHAR(255) NOT NULL,
    visited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    user_agent TEXT,
    ip_address VARCHAR(45),
    country VARCHAR(100),
    city VARCHAR(100),
    FOREIGN KEY (config_id) REFERENCES qr_configs(id) ON DELETE CASCADE,
    INDEX idx_config_date (config_id, visited_at)
);

-- Saved contacts table
CREATE TABLE saved_contacts (
    id VARCHAR(255) PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    contact_user_id VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(50),
    email VARCHAR(255),
    avatar_url TEXT,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (contact_user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user_saved (user_id, saved_at)
); 