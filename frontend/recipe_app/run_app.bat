@echo off
echo Starting Recipe App...
echo.
echo Make sure you have:
echo 1. Flutter SDK installed and in PATH
echo 2. Android emulator running or device connected
echo 3. Backend server running on localhost:3001
echo.
echo Press any key to continue...
pause >nul

echo.
echo Installing dependencies...
flutter pub get

echo.
echo Launching app...
flutter run

pause
