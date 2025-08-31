Write-Host "Starting Recipe App..." -ForegroundColor Green
Write-Host ""
Write-Host "Make sure you have:" -ForegroundColor Yellow
Write-Host "1. Flutter SDK installed and in PATH" -ForegroundColor White
Write-Host "2. Android emulator running or device connected" -ForegroundColor White
Write-Host "3. Backend server running on localhost:3001" -ForegroundColor White
Write-Host ""
Write-Host "Press any key to continue..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "Installing dependencies..." -ForegroundColor Yellow
flutter pub get

Write-Host ""
Write-Host "Launching app..." -ForegroundColor Yellow
flutter run

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
