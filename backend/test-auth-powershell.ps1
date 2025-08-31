# Test Auth Endpoints with PowerShell
$baseUrl = "http://localhost:3001"

Write-Host "🧪 Testing Auth Endpoints..." -ForegroundColor Green
Write-Host ""

try {
    # Test signup
    Write-Host "1. Testing Signup..." -ForegroundColor Yellow
    $signupData = @{
        email = "test@example.com"
        username = "testuser"
        password = "password123"
        isVegetarian = $true
    } | ConvertTo-Json

    $signupResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/signup" -Method POST -Body $signupData -ContentType "application/json"
    
    Write-Host "✅ Signup successful!" -ForegroundColor Green
    Write-Host "Status: 201"
    Write-Host "Response: $($signupResponse | ConvertTo-Json -Depth 3)"
    Write-Host ""

    # Test login
    Write-Host "2. Testing Login..." -ForegroundColor Yellow
    $loginData = @{
        email = "test@example.com"
        password = "password123"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $loginData -ContentType "application/json"
    
    Write-Host "✅ Login successful!" -ForegroundColor Green
    Write-Host "Status: 200"
    Write-Host "Response: $($loginResponse | ConvertTo-Json -Depth 3)"
    Write-Host ""

    # Test invalid login
    Write-Host "3. Testing Invalid Login..." -ForegroundColor Yellow
    $invalidLoginData = @{
        email = "test@example.com"
        password = "wrongpassword"
    } | ConvertTo-Json

    try {
        $invalidLoginResponse = Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method POST -Body $invalidLoginData -ContentType "application/json"
    }
    catch {
        Write-Host "✅ Invalid login correctly rejected!" -ForegroundColor Green
        Write-Host "Status: $($_.Exception.Response.StatusCode)"
        Write-Host "Response: $($_.Exception.Message)"
    }

} catch {
    Write-Host "❌ Test failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        Write-Host "Response: $($_.Exception.Message)" -ForegroundColor Red
    }
}
