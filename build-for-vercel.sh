#!/bin/bash

set -e

echo "🚀 Building SocialCard Pro for Vercel..."

# Get the project root directory
PROJECT_ROOT=$(pwd)
echo "📁 Project root: $PROJECT_ROOT"

# Install Flutter
bash ./install-flutter-optimized.sh

# Export Flutter to PATH
export PATH="/tmp/flutter/bin:$PATH"
export PUB_CACHE="/tmp/.pub_cache"

# Ensure we're in the project directory
cd "$PROJECT_ROOT"

# Build the web app with environment variables
echo "🔨 Building Flutter web app..."
flutter build web \
    --release \
    --dart-define=SUPABASE_URL=$SUPABASE_URL \
    --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
    --dart-define=GOOGLE_CLIENT_ID=$GOOGLE_CLIENT_ID

echo "✅ Build completed successfully!"
echo "📁 Output directory: build/web/" 