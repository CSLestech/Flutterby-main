@echo off
echo ===== Flutter Build Fix Script =====
echo.
echo This script will attempt to fix your APK build issues by:
echo 1. Cleaning the build directory
echo 2. Checking Flutter installation
echo 3. Rebuilding the APK with verbose output
echo.
echo Starting process...
echo.

echo Step 1: Cleaning the build directory...
call flutter clean
echo.

echo Step 2: Checking Flutter installation...
call flutter doctor
echo.

echo Step 3: Updating dependencies...
call flutter pub get
echo.

echo Step 4: Clearing Gradle cache (this may help with build issues)...
cd android
call gradlew cleanBuildCache
cd ..
echo.

echo Step 5: Rebuilding the APK...
call flutter build apk --release
echo.

echo Process completed. If the build was successful, the APK will be at:
echo build\app\outputs\flutter-apk\app-release.apk
echo.
echo If the build still fails, try running:
echo flutter build apk --release --verbose
echo.
pause