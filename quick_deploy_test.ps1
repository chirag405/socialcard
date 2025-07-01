# Quick Deploy Test - SocialCard Pro
Write-Host "🧪 Testing SocialCard Pro build for Vercel deployment..." -ForegroundColor Cyan

try {
    # Check if Flutter is available
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Flutter not found. Please install Flutter and add it to PATH." -ForegroundColor Red
        exit 1
    }

    Write-Host "✅ Flutter is available" -ForegroundColor Green

    # Check if web config exists for local testing
    if (-not (Test-Path "web/config.js")) {
        Write-Host "⚠️  Local config not found. Creating from template..." -ForegroundColor Yellow
        Copy-Item "web/config.template.js" "web/config.js"
        Write-Host "📝 Please edit web/config.js with your Supabase credentials before testing locally" -ForegroundColor Yellow
    }

    # Run the build
    Write-Host "🔨 Building for web..." -ForegroundColor Blue
    flutter build web --release --web-renderer html

    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Build successful!" -ForegroundColor Green
        Write-Host "📁 Build output is in: build/web/" -ForegroundColor Blue
        
        # Check key files
        $keyFiles = @("index.html", "main.dart.js", "flutter_service_worker.js")
        foreach ($file in $keyFiles) {
            if (Test-Path "build/web/$file") {
                $size = (Get-Item "build/web/$file").Length
                Write-Host "  ✓ $file ($('{0:N0}' -f $size) bytes)" -ForegroundColor Green
            } else {
                Write-Host "  ❌ $file missing" -ForegroundColor Red
            }
        }
        
        Write-Host "`n🚀 Ready for Vercel deployment!" -ForegroundColor Green
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "1. Push to GitHub: git add . && git commit -m 'Add Vercel config' && git push" -ForegroundColor White
        Write-Host "2. Import to Vercel from GitHub" -ForegroundColor White
        Write-Host "3. Set environment variables in Vercel dashboard" -ForegroundColor White
        Write-Host "4. Deploy! 🎉" -ForegroundColor White
        
    } else {
        Write-Host "❌ Build failed. Check errors above." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "❌ Error during build test: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}