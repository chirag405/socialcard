# SocialCard Pro - Vercel Build Script
Write-Host "🚀 Building SocialCard Pro for Vercel deployment..." -ForegroundColor Green

try {
    # Check Flutter installation
    $flutterPath = Get-Command flutter -ErrorAction SilentlyContinue
    if (-not $flutterPath) {
        Write-Host "❌ Flutter not found in PATH" -ForegroundColor Red
        exit 1
    }

    Write-Host "✅ Flutter found: $($flutterPath.Source)" -ForegroundColor Green

    # Set up Flutter
    Write-Host "⚙️ Setting up Flutter..." -ForegroundColor Blue
    flutter config --no-analytics
    flutter precache --web

    # Clean previous build
    Write-Host "🧹 Cleaning previous build..." -ForegroundColor Blue
    flutter clean

    # Get dependencies
    Write-Host "📚 Getting dependencies..." -ForegroundColor Blue
    flutter pub get

    # Build for web with optimizations
    Write-Host "🔨 Building for web..." -ForegroundColor Blue
    flutter build web `
        --release `
        --web-renderer html `
        --source-maps `
        --tree-shake-icons `
        --dart-define=FLUTTER_WEB_USE_SKIA=false `
        --dart-define=FLUTTER_WEB_AUTO_DETECT=false

    Write-Host "✅ Build completed! Output in build/web/" -ForegroundColor Green

    # List output files for debugging
    Write-Host "📁 Build output:" -ForegroundColor Blue
    Get-ChildItem -Path "build/web" -Force | Format-Table Name, Length, LastWriteTime

    Write-Host "🎉 Ready for Vercel deployment!" -ForegroundColor Green
}
catch {
    Write-Host "❌ Build failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
} 