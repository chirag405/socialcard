#!/bin/bash

set -e

echo "🚀 Installing Flutter for Vercel deployment..."

# Set Flutter version
FLUTTER_VERSION="3.24.5"
FLUTTER_TAR="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_TAR}"

# Create Flutter directory
FLUTTER_ROOT="/tmp/flutter"
mkdir -p /tmp

echo "📦 Downloading Flutter ${FLUTTER_VERSION}..."
cd /tmp
curl -o flutter.tar.xz -L "${FLUTTER_URL}"

echo "📂 Extracting Flutter..."
tar xf flutter.tar.xz

echo "⚙️ Setting up Flutter..."
export PATH="${FLUTTER_ROOT}/bin:$PATH"
export PUB_CACHE="/tmp/.pub_cache"

# Configure Flutter
flutter config --no-analytics
flutter --version

echo "🌐 Enabling web support..."
flutter config --enable-web

echo "📚 Getting dependencies..."
flutter pub get

echo "✅ Flutter installation complete!"
echo "Flutter version: $(flutter --version | head -n 1)" 