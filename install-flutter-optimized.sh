#!/bin/bash

set -e

echo "🚀 Installing Flutter for Vercel (Optimized)..."

# Save the current directory (project root)
PROJECT_ROOT=$(pwd)
echo "📁 Working from project root: $PROJECT_ROOT"

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
    flutter config --no-analytics
    flutter config --enable-web
    flutter precache --web
    
    echo "✅ Flutter installed successfully"
fi

# Set environment variables
export PATH="/tmp/flutter/bin:$PATH"
export PUB_CACHE="/tmp/.pub_cache"

# Get dependencies (ensure we're in the project directory)
echo "📚 Getting project dependencies..."
cd "$PROJECT_ROOT"
flutter pub get

echo "✅ Ready to build!"
flutter --version 