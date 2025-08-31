# Frontend-Backend Connection Guide

## ✅ What I've Fixed

### 1. Port Configuration
- **Backend**: Running on port 3001 (as configured in `backend/config.env`)
- **Frontend**: Updated to connect to port 3001 (in `frontend/recipe_app/lib/config/app_config.dart`)

### 2. CORS Configuration
- **Backend**: Updated CORS to allow connections from port 3001 and 127.0.0.1:3001
- **Frontend**: Can now connect without CORS issues

### 3. API Endpoints
- **Backend**: Routes are mounted at `/api/auth`, `/api/recipes`, `/api/users`
- **Frontend**: Services correctly construct URLs like `http://localhost:3001/api/auth/signup`

### 4. Error Handling
- Added better error messages for connection issues
- Added debug logging to help troubleshoot problems
- Created connection test utilities

## 🚀 How to Test the Connection

### Step 1: Start Your Backend
```bash
cd backend
npm start
# or
node server.js
```

Your backend should start on port 3001 and show:
```
🚀 Server running on port 3001
📊 Environment: development
```

### Step 2: Test Backend Connection
Run the test script I created:
```bash
test-connection.bat
```

This will test:
- Health endpoint: `http://localhost:3001/health`
- Auth endpoint: `http://localhost:3001/api/auth`
- Recipe endpoint: `http://localhost:3001/api/recipes`

### Step 3: Test Frontend Connection
1. Add the connection test screen to your Flutter app
2. Import and navigate to `ConnectionTestScreen`
3. Use the test buttons to verify each endpoint

## 🔧 Troubleshooting

### Common Issues:

#### 1. "Connection refused" Error
**Cause**: Backend not running or wrong port
**Solution**: 
- Ensure backend is running on port 3001
- Check `backend/config.env` has `PORT=3001`
- Verify no other service is using port 3001

#### 2. CORS Error
**Cause**: Frontend origin not allowed
**Solution**: 
- Backend CORS is already configured correctly
- Ensure you're using `localhost:3001` not `127.0.0.1:3001`

#### 3. "Route not found" Error
**Cause**: Wrong API endpoint
**Solution**: 
- Backend routes are: `/api/auth/*`, `/api/recipes/*`, `/api/users/*`
- Frontend services construct URLs correctly

#### 4. Database Connection Error
**Cause**: Database not accessible
**Solution**: 
- Check `backend/config.env` database URL
- Ensure database is running and accessible

## 📱 Adding Connection Test to Your Flutter App

### 1. Import the Connection Test Screen
```dart
import 'package:your_app/screens/connection_test_screen.dart';
```

### 2. Navigate to Test Screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ConnectionTestScreen()),
);
```

### 3. Add to Your App's Navigation
You can temporarily add this to your main navigation to test the connection.

## 🔍 Debug Information

### Backend Logs
When you make requests from Flutter, you'll see logs like:
```
POST /api/auth/signup 201 - 15.234 ms
GET /api/recipes/search 200 - 8.123 ms
```

### Frontend Logs
The services now include debug prints:
```
Attempting to connect to: http://localhost:3001/api/auth/signup
Response status: 201
Response body: {"status":"success",...}
```

## 🎯 Next Steps

1. **Test the connection** using the provided tools
2. **Verify all endpoints** are working
3. **Test user registration** and login
4. **Test recipe search** functionality
5. **Remove debug logs** once everything is working

## 📞 Need Help?

If you encounter issues:
1. Check the backend console for error messages
2. Use the connection test screen to isolate problems
3. Verify the backend is running and accessible
4. Check that all ports and URLs match

Your frontend and backend should now connect properly! 🎉
