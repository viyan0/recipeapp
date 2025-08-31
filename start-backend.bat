@echo off
echo ========================================
echo    Recipe App Backend Startup
echo ========================================
echo.

echo Checking if Node.js is installed...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

echo ✅ Node.js found
echo.

echo Checking if backend dependencies are installed...
if not exist "backend\node_modules" (
    echo Installing dependencies...
    cd backend
    npm install
    if %errorlevel% neq 0 (
        echo ❌ Failed to install dependencies
        pause
        exit /b 1
    )
    cd ..
) else (
    echo ✅ Dependencies already installed
)

echo.
echo Starting backend server on port 3001...
echo.
cd backend
npm run dev

pause
