#!/bin/bash

# 🚀 SocialCard Pro - Simple Deployment Script
# 
# This script builds and deploys your app to Netlify
# Make sure you have the Netlify CLI installed: npm install -g netlify-cli

set -e  # Exit on any error

echo "🚀 SocialCard Pro Deployment Script"
echo "===================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "💡 Install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Netlify CLI is installed (optional)
if ! command -v netlify &> /dev/null; then
    echo "⚠️  Netlify CLI not found. Install with: npm install -g netlify-cli"
    echo "   You can still deploy manually by uploading the build/web folder"
fi

echo "📋 Current directory: $(pwd)"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
rm -rf build/web

# Get dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build for web
echo "🔨 Building Flutter web app..."
echo "   Environment: PRODUCTION"
echo "   Target: Web"

# Build with production flag
flutter build web \
    --release \
    --dart-define=PRODUCTION=true \
    --web-renderer html

# Check if build succeeded
if [ ! -d "build/web" ]; then
    echo "❌ Build failed - build/web directory not found"
    exit 1
fi

echo "✅ Build completed successfully!"
echo "📁 Build output: build/web"
echo "📊 Build size:"
du -sh build/web

# Optional: Deploy to Netlify if CLI is available
if command -v netlify &> /dev/null; then
    echo ""
    echo "🌐 Deploy to Netlify?"
    echo "   1. Deploy draft (preview)"
    echo "   2. Deploy to production"
    echo "   3. Skip deployment"
    
    read -p "Choose option (1-3): " choice
    
    case $choice in
        1)
            echo "🚀 Deploying draft to Netlify..."
            netlify deploy --dir=build/web
            ;;
        2)
            echo "🚀 Deploying to production..."
            netlify deploy --prod --dir=build/web
            ;;
        3)
            echo "⏭️  Skipping deployment"
            ;;
        *)
            echo "❌ Invalid choice"
            ;;
    esac
else
    echo ""
    echo "📤 Manual Deployment Instructions:"
    echo "   1. Go to your Netlify dashboard"
    echo "   2. Drag and drop the 'build/web' folder"
    echo "   3. Or use Git-based deployment"
fi

echo ""
echo "✨ Deployment script completed!"
echo "🔗 Your app will be available at: https://socialcard-pro.netlify.app"
echo ""
echo "🔧 Don't forget to set environment variables in Netlify:"
echo "   - SUPABASE_URL"
echo "   - SUPABASE_ANON_KEY" 
echo "   - GOOGLE_CLIENT_ID" 