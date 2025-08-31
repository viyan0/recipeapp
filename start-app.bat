@echo off
echo 🚀 Starting Recipe App - Full Stack
echo ======================================
echo.

echo 📋 Prerequisites Check:
echo - Node.js installed: 
node --version >nul 2>&1 && echo ✅ Found || echo ❌ Not found
echo - Flutter installed: 
flutter --version >nul 2>&1 && echo ✅ Found || echo ❌ Not found
echo.

echo 🔧 Starting Backend Server...
echo.
cd backend
start "Backend Server" cmd /k "npm start"
echo ✅ Backend server started in new window
echo.

echo ⏳ Waiting for backend to initialize...
timeout /t 5 /nobreak >nul

echo 🧪 Testing Backend Connection...
node test-connection.js
echo.

echo 📱 Starting Flutter App...
echo.
cd ..\frontend\recipe_app
start "Flutter App" cmd /k "flutter run"
echo ✅ Flutter app started in new window
echo.

echo 🎉 Recipe App is starting up!
echo.
echo 📊 Backend: http://localhost:3001/health
echo 📱 Frontend: Check the Flutter window
echo.
echo 💡 Tips:
echo - Backend runs on port 3001
echo - Flutter app connects to 10.0.2.2:3001 (Android emulator)
echo - Check CONNECTION_GUIDE.md for troubleshooting
echo.
echo Press any key to exit this launcher...
pause >nul
