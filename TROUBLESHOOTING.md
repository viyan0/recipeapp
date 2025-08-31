# Troubleshooting Guide - Recipe App Connection Issues

## Problem: "Client failed to fetch" Error during Signup

If you're experiencing connection issues when trying to sign up, follow these steps to diagnose and fix the problem.

## Step 1: Check if Backend is Running

### Option A: Using the test script
```bash
cd backend
npm run test:server
```

### Option B: Manual check
1. Open a new terminal/command prompt
2. Navigate to the backend folder: `cd backend`
3. Start the server: `npm run dev`
4. You should see: `🚀 Server running on port 3001`

## Step 2: Verify Port Configuration

The backend should be running on port 3001. Check these files:

- `backend/config.env` should have: `PORT=3001`
- `backend/server.js` should use: `const PORT = process.env.PORT || 3001;`
- `frontend/recipe_app/lib/config/app_config.dart` should have: `static const String backendUrl = 'http://localhost:3001';`

## Step 3: Test Backend Endpoints

### Health Check
```bash
curl http://localhost:3001/health
```
Expected response: `{"status":"success","message":"Server is running"}`

### Auth Endpoint Test
```bash
curl -X POST http://localhost:3001/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"testpass123","isVegetarian":false}'
```

## Step 4: Common Issues and Solutions

### Issue 1: Backend not starting
**Symptoms:** "Cannot connect to server" error
**Solution:** 
1. Check if Node.js is installed: `node --version`
2. Install dependencies: `cd backend && npm install`
3. Check database connection in `config.env`
4. Start server: `npm run dev`

### Issue 2: Port already in use
**Symptoms:** "EADDRINUSE" error
**Solution:**
1. Find process using port 3001: `netstat -ano | findstr :3001` (Windows) or `lsof -i :3001` (Mac/Linux)
2. Kill the process or change port in `config.env`

### Issue 3: CORS issues
**Symptoms:** "CORS policy" errors in browser console
**Solution:** 
1. Backend CORS is already configured for Flutter
2. Ensure backend is running on the correct port
3. Check if firewall is blocking connections

### Issue 4: Database connection issues
**Symptoms:** Backend starts but database queries fail
**Solution:**
1. Check database credentials in `config.env`
2. Test database connection: `npm run db:test`
3. Ensure database is accessible from your network

## Step 5: Flutter App Testing

### Test Connection Screen
Use the connection test screen in your Flutter app to verify:
- Backend connectivity
- Auth endpoint accessibility
- Recipe endpoint accessibility

### Debug Logs
Check the console output for:
- Connection attempts
- Response status codes
- Error messages

## Step 6: Network Configuration

### Localhost Issues
If localhost doesn't work:
1. Try using `127.0.0.1:3001` instead of `localhost:3001`
2. Check Windows hosts file: `C:\Windows\System32\drivers\etc\hosts`
3. Ensure no antivirus/firewall is blocking localhost

### Flutter Web Issues
If testing on Flutter web:
1. Use `http://127.0.0.1:3001` in `app_config.dart`
2. Ensure CORS allows your web port

## Quick Fix Commands

```bash
# Stop any existing backend processes
taskkill /F /IM node.exe  # Windows
pkill node                 # Mac/Linux

# Start fresh backend
cd backend
npm install
npm run dev

# Test in new terminal
npm run test:server
```

## Still Having Issues?

1. Check the backend console for error messages
2. Verify all environment variables are set correctly
3. Ensure database is running and accessible
4. Test with a simple curl command first
5. Check if the issue is specific to Flutter or general network connectivity

## Contact Support

If none of these steps resolve the issue, please provide:
- Backend console output
- Flutter app error messages
- Network configuration details
- Operating system and Flutter version
