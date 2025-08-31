# Quick Start Guide - Recipe App Frontend

## 🚀 Get Started in 5 Minutes

### 1. Prerequisites
- Flutter SDK installed (version 3.2.3+)
- Android Studio or VS Code with Flutter extensions
- Android emulator running or physical device connected

### 2. Quick Setup
```bash
# Navigate to the app directory
cd frontend/recipe_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### 3. Alternative: Use Launch Scripts
- **Windows**: Double-click `run_app.bat`
- **PowerShell**: Right-click `run_app.ps1` → "Run with PowerShell"

## 🔧 Configuration

### Update Backend URL
If your backend is not running on `localhost:3000`, update the URL in:
```
lib/config/app_config.dart
```

Change this line:
```dart
static const String backendUrl = 'http://localhost:3000';
```

## 📱 App Features

### Welcome Screen
- Clean welcome message: "Oh, let's make delicious food!"
- Sign Up and Log In buttons

### Authentication
- User registration with dietary preference selection
- Login functionality
- Form validation and error handling

### Recipe Search
- Search bar for custom ingredients
- Time filter (10 min, 20 min, 30 min, 1 hour)
- Common ingredient chips (onion, garlic, tomato, etc.)
- Recipe search results display

## 🏗️ Project Structure
```
lib/
├── main.dart              # App entry point
├── config/
│   └── app_config.dart   # Configuration settings
├── models/
│   └── user.dart         # User data model
├── screens/
│   ├── welcome_screen.dart
│   ├── auth_screen.dart
│   └── search_screen.dart
└── services/
    ├── auth_service.dart
    └── recipe_service.dart
```

## 🔗 Backend Integration

The app expects these backend endpoints:
- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User login
- `POST /api/recipes/search` - Recipe search
- `GET /api/recipes/:id` - Recipe details

## 🐛 Troubleshooting

### Common Issues
1. **"flutter: command not found"**
   - Install Flutter SDK and add to PATH

2. **"No supported devices connected"**
   - Start Android emulator or connect physical device

3. **"Backend connection failed"**
   - Check if backend server is running
   - Verify backend URL in `app_config.dart`

### Commands
```bash
# Check Flutter installation
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get

# Check connected devices
flutter devices
```

## 📖 Next Steps

1. **Customize Colors**: Update theme in `main.dart`
2. **Add Ingredients**: Edit `_commonIngredients` in `search_screen.dart`
3. **Modify Time Options**: Update `availableTimeOptions` in `app_config.dart`
4. **Add Recipe Details**: Implement recipe detail screen
5. **Enhance UI**: Add animations and better styling

## 📞 Need Help?

- Check Flutter documentation: https://docs.flutter.dev/
- Review the main README.md for detailed information
- Ensure all dependencies are properly installed

---

**Happy Cooking! 🍳**
