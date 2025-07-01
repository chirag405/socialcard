#!/bin/bash

set -e

echo "🚀 Installing Flutter for Vercel (Optimized)..."

# Check if Flutter is already installed and cached
if [ -d "/tmp/flutter" ] && [ -x "/tmp/flutter/bin/flutter" ]; then
    echo "✅ Flutter found in cache"
    export PATH="/tmp/flutter/bin:$PATH"
    flutter --version
else
    echo "📦 Installing Flutter..."
    
    # Use a lightweight approach with git clone
    cd /tmp
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    
    export PATH="/tmp/flutter/bin:$PATH"
    export PUB_CACHE="/tmp/.pub_cache"
    
    # Basic Flutter setup
    flutter --disable-root-warning config --no-analytics
    flutter --disable-root-warning config --enable-web
    flutter --disable-root-warning precache --web
    
    echo "✅ Flutter installed successfully"
fi

# Set environment variables
export PATH="/tmp/flutter/bin:$PATH"
export PUB_CACHE="/tmp/.pub_cache"

# Get dependencies
echo "📚 Getting project dependencies..."
flutter --disable-root-warning pub get

echo "✅ Ready to build!"
flutter --disable-root-warning --version 