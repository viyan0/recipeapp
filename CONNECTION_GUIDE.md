# 🔗 Complete Connection Guide - Recipe App

This guide will help you connect your Flutter frontend, Node.js backend, and PostgreSQL database together.

## 🏗️ System Architecture

```
┌─────────────────┐    HTTP/JSON    ┌─────────────────┐    SQL    ┌─────────────────┐
│   Flutter App   │ ◄─────────────► │  Node.js Server │ ◄────────► │  PostgreSQL DB  │
│   (Frontend)    │                 │    (Backend)    │           │   (Database)    │
└─────────────────┘                 └─────────────────┘           └─────────────────┘
```

## 🚀 Quick Start (5 minutes)

### 1. Start the Backend Server
```bash
cd backend
npm install
npm start
```

### 2. Test Backend Connection
```bash
cd backend
node test-connection.js
```

### 3. Start the Flutter App
```bash
cd frontend/recipe_app
flutter run
```

## 📋 Prerequisites

- ✅ Node.js (v16+)
- ✅ PostgreSQL database (Neon, local, or cloud)
- ✅ Flutter SDK (v3.2.3+)
- ✅ Android emulator or device

## 🔧 Step-by-Step Setup

### Step 1: Database Setup

Your database is already configured in `backend/config.env`:
```env
DATABASE_URL=postgresql://neondb_owner:npg_gnNz6myRM1Ce@ep-gentle-forest-a7w6iaih-pooler.ap-southeast-2.aws.neon.tech/neondb?sslmode=require&channel_binding=require
```

The backend will automatically:
- Connect to your Neon database
- Create necessary tables (users, recipes, search_history, favourites)
- Add dietary preference support

### Step 2: Backend Configuration

1. **Install dependencies:**
   ```bash
   cd backend
   npm install
   ```

2. **Environment variables are already set in `config.env`**

3. **Start the server:**
   ```bash
   npm start
   ```

4. **Verify it's running:**
   - Visit: http://localhost:3001/health
   - Should see: `{"status":"success","message":"Server is running"}`

### Step 3: Frontend Configuration

1. **Update backend URL for your setup:**

   **For Android Emulator:**
   ```dart
   // frontend/recipe_app/lib/config/app_config.dart
   static const String backendUrl = 'http://10.0.2.2:3000';
   ```

   **For Physical Device (same network):**
   ```dart
   static const String backendUrl = 'http://YOUR_COMPUTER_IP:3000';
   ```

   **For iOS Simulator:**
   ```dart
   static const String backendUrl = 'http://localhost:3001';
   ```

2. **Install Flutter dependencies:**
   ```bash
   cd frontend/recipe_app
   flutter pub get
   ```

## 🔍 Testing the Connection

### Test Backend Endpoints

1. **Health Check:**
   ```bash
   curl http://localhost:3001/health
   ```

2. **Test Signup:**
   ```bash
   curl -X POST http://localhost:3001/api/auth/signup \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser","email":"test@example.com","password":"password123","isVegetarian":true}'
   ```

3. **Test Login:**
   ```bash
   curl -X POST http://localhost:3001/api/auth/login \
     -H "Content-Type: application/json" \
     -d '{"email":"test@example.com","password":"password123"}'
   ```

4. **Test Recipe Search:**
   ```bash
   curl -X POST http://localhost:3001/api/recipes/search \
     -H "Content-Type: application/json" \
     -d '{"ingredients":["onion","tomato"],"maxTimeMinutes":30,"isVegetarian":true}'
   ```

### Run Automated Tests

```bash
cd backend
node test-connection.js
```

## 📱 Flutter App Features

### ✅ What's Working

1. **Welcome Screen** - Clean welcome message
2. **Authentication** - Sign up/login with dietary preferences
3. **Recipe Search** - Search by ingredients and time
4. **Database Integration** - User data persistence
5. **API Communication** - Full backend integration

### 🔄 Data Flow

1. **User Registration:**
   ```
   Flutter App → POST /api/auth/signup → Database (users table)
   ```

2. **User Login:**
   ```
   Flutter App → POST /api/auth/login → Database (verify credentials)
   ```

3. **Recipe Search:**
   ```
   Flutter App → POST /api/recipes/search → TheMealDB API → Filtered Results
   ```

4. **Dietary Preferences:**
   ```
   Flutter App → PUT /api/users/:id/dietary-preference → Database Update
   ```

## 🐛 Troubleshooting

### Common Issues

#### 1. "Backend connection failed"
- **Check:** Is backend server running?
- **Solution:** Run `npm start` in backend directory
- **Verify:** Visit http://localhost:3001/health

#### 2. "Database connection failed"
- **Check:** Is your Neon database accessible?
- **Solution:** Verify DATABASE_URL in `backend/config.env`
- **Test:** Run `node test-connection.js`

#### 3. "Flutter can't connect to backend"
- **Android Emulator:** Use `10.0.2.2:3001`
- **Physical Device:** Use your computer's IP address
- **iOS Simulator:** Use `localhost:3001`

#### 4. "CORS errors"
- **Check:** Backend CORS configuration
- **Solution:** Backend already configured for Flutter app

### Debug Commands

```bash
# Check backend status
curl http://localhost:3001/health

# Check database connection
cd backend && node -e "require('./config/database').testConnection()"

# Test all endpoints
cd backend && node test-connection.js

# Check Flutter dependencies
cd frontend/recipe_app && flutter doctor
```

## 🔒 Security Features

- ✅ Password hashing with bcrypt
- ✅ JWT token authentication
- ✅ Input validation and sanitization
- ✅ Rate limiting
- ✅ CORS protection
- ✅ SQL injection prevention

## 📊 Database Schema

### Users Table
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  is_vegetarian BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Recipes Table
```sql
CREATE TABLE recipes (
  id SERIAL PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  ingredients JSONB NOT NULL,
  cooking_time_minutes INTEGER NOT NULL,
  is_vegetarian BOOLEAN DEFAULT false
);
```

## 🚀 Production Deployment

### Backend
1. Set `NODE_ENV=production`
2. Use environment variables for secrets
3. Deploy to Heroku, Vercel, or AWS

### Database
1. Use production PostgreSQL (AWS RDS, Heroku Postgres)
2. Enable SSL connections
3. Set up automated backups

### Frontend
1. Build release APK: `flutter build apk --release`
2. Deploy to Google Play Store
3. Update backend URL to production domain

## 📞 Support

### Backend Issues
- Check server logs in terminal
- Run `node test-connection.js`
- Verify database connectivity

### Frontend Issues
- Check Flutter console output
- Verify backend URL in `app_config.dart`
- Test API endpoints manually

### Database Issues
- Check Neon dashboard
- Verify connection string
- Test with `psql` client

## 🎯 Next Steps

1. **Test the complete flow:**
   - Sign up → Login → Search recipes → View results

2. **Add more features:**
   - Recipe favorites
   - Search history
   - User profiles

3. **Enhance the UI:**
   - Recipe detail screens
   - Better animations
   - Dark mode

4. **Scale the backend:**
   - Add more recipe sources
   - Implement caching
   - Add analytics

---

## 🎉 Success Checklist

- [ ] Backend server running on port 3000
- [ ] Database connected and tables created
- [ ] All API endpoints responding correctly
- [ ] Flutter app connecting to backend
- [ ] User registration working
- [ ] Recipe search functional
- [ ] Dietary preferences saved

**Congratulations! Your Recipe App is now fully connected and functional! 🍳✨**
