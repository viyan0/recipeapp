@echo off
echo Testing Backend Connection...
echo.

echo 1. Testing if backend is running on port 3001...
curl -s http://localhost:3000/health
echo.
echo.

echo 2. Testing auth endpoint...
curl -s http://localhost:3000/api/auth
echo.
echo.

echo 3. Testing recipe endpoint...
curl -s http://localhost:3000/api/recipes
echo.
echo.

echo Connection test completed!
pause
