#!/bin/bash

set -e

echo "🔍 Debug Build - Finding Compilation Issues..."

# Get the project root directory
PROJECT_ROOT=$(pwd)
echo "📁 Project root: $PROJECT_ROOT"

# Install Flutter if needed
if ! command -v flutter &> /dev/null; then
    echo "📦 Installing Flutter..."
    cd /tmp
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="/tmp/flutter/bin:$PATH"
    export PUB_CACHE="/tmp/.pub_cache"
    flutter config --no-analytics
    flutter config --enable-web
    cd "$PROJECT_ROOT"
else
    echo "✅ Flutter already available"
fi

# Set environment
export PATH="/tmp/flutter/bin:$PATH"
export PUB_CACHE="/tmp/.pub_cache"

# Check Flutter setup
echo "🔧 Flutter version:"
flutter --version

# Check dependencies
echo "📚 Getting dependencies..."
flutter pub get

# Analyze code for issues
echo "🔍 Analyzing code..."
flutter analyze --no-fatal-infos

# Try to compile with verbose output
echo "🔨 Attempting compilation with verbose output..."
flutter build web \
    --debug \
    --verbose \
    --dart-define=SUPABASE_URL=https://placeholder.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=placeholder-key \
    --dart-define=GOOGLE_CLIENT_ID=placeholder-client-id 