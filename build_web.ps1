# Flutter Web Build Script
Write-Host "Building Flutter Web App..." -ForegroundColor Green

# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build for web
flutter build web --release --web-renderer html

Write-Host "Build completed! Files are in build/web/" -ForegroundColor Green
Write-Host "You can test locally with: flutter run -d chrome" -ForegroundColor Yellow 