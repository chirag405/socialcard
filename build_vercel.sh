#!/bin/bash

set -e

echo "🚀 Building SocialCard Pro for Vercel deployment..."

# Install Flutter if not available
if ! command -v flutter &> /dev/null; then
    echo "📦 Installing Flutter..."
    git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
    export PATH="$PATH:/opt/flutter/bin"
    flutter doctor
fi

# Set up Flutter
echo "⚙️ Setting up Flutter..."
flutter config --no-analytics
flutter precache --web

# Get dependencies
echo "📚 Getting dependencies..."
flutter pub get

# Build for web with optimizations
echo "🔨 Building for web..."
flutter build web \
    --release \
    --web-renderer html \
    --source-maps \
    --tree-shake-icons \
    --dart-define=FLUTTER_WEB_USE_SKIA=false \
    --dart-define=FLUTTER_WEB_AUTO_DETECT=false

echo "✅ Build completed! Output in build/web/"

# List output files for debugging
echo "📁 Build output:"
ls -la build/web/

echo "🎉 Ready for deployment!" 