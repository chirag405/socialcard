# Copy APK to Flutter's expected location
New-Item -ItemType Directory -Path "build\app\outputs\flutter-apk" -Force | Out-Null
Copy-Item "android\app\build\outputs\apk\debug\app-debug.apk" "build\app\outputs\flutter-apk\app-debug.apk" -Force
Write-Host "APK copied to Flutter's expected location!" 