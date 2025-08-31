# Recipe App - Flutter Frontend

A clean and functional Flutter app for discovering recipes based on available ingredients and time constraints.

## Features

- **Welcome Screen**: Clean welcome message with sign up and login options
- **Authentication**: User registration and login with dietary preference selection
- **Recipe Search**: Search recipes based on available ingredients
- **Time Filtering**: Filter recipes by cooking time (10 min, 20 min, 30 min, 1 hour)
- **Ingredient Selection**: Easy ingredient selection with common ingredient chips
- **Dietary Preferences**: Vegetarian/Non-vegetarian preference tracking
- **Clean UI**: Simple, functional design focused on usability

## Screens

### 1. Welcome Screen
- Welcoming message: "Oh, let's make delicious food!"
- Sign Up button
- Log In button
- Clean, centered layout with app icon

### 2. Authentication Screen
- Toggle between Sign Up and Log In modes
- Form validation for all fields
- Dietary preference selection (Vegetarian/Non-vegetarian)
- Error handling and loading states

### 3. Search Screen
- Search bar for custom ingredients
- Time filter selection
- Common ingredient chips for quick selection
- Selected ingredients display with remove functionality
- Recipe search results
- Logout functionality

## Setup Instructions

### Prerequisites
- Flutter SDK (version 3.2.3 or higher)
- Android Studio / VS Code with Flutter extensions
- Android emulator or physical device

### Installation

1. **Navigate to the app directory:**
   ```bash
   cd frontend/recipe_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update backend URL:**
   - Open `lib/services/auth_service.dart`
   - Update the `baseUrl` constant to match your backend server
   - Open `lib/services/recipe_service.dart`
   - Update the `baseUrl` constant to match your backend server

4. **Run the app:**
   ```bash
   flutter run
   ```

## Backend Integration

The app expects the following backend endpoints:

### Authentication
- `POST /api/auth/signup` - User registration
- `POST /api/auth/login` - User login
- `PUT /api/users/:id/dietary-preference` - Update dietary preference

### Recipe Search
- `POST /api/recipes/search` - Search recipes by ingredients and time
- `GET /api/recipes/:id` - Get recipe details
- `GET /api/recipes/popular` - Get popular recipes

## Data Models

### User
- `id`: Unique user identifier
- `email`: User's email address
- `username`: User's display name
- `isVegetarian`: Dietary preference flag
- `createdAt`: Account creation timestamp

## Dependencies

- `flutter`: Core Flutter framework
- `http`: HTTP client for API calls
- `shared_preferences`: Local data storage
- `cupertino_icons`: iOS-style icons

## Project Structure

```
lib/
├── main.dart              # App entry point and theme configuration
├── models/
│   └── user.dart         # User data model
├── screens/
│   ├── welcome_screen.dart    # Welcome screen
│   ├── auth_screen.dart       # Authentication screen
│   └── search_screen.dart     # Recipe search screen
└── services/
    ├── auth_service.dart      # Authentication logic
    └── recipe_service.dart    # Recipe API calls
```

## Customization

### Colors
The app uses an orange color scheme. To change colors:
1. Update `lib/main.dart` theme configuration
2. Modify color values throughout the screens

### Ingredients
To add/remove common ingredients:
1. Edit the `_commonIngredients` list in `lib/screens/search_screen.dart`

### Time Options
To modify time filter options:
1. Edit the `_timeOptions` list in `lib/screens/search_screen.dart`

## Future Enhancements

- Recipe detail screen
- Favorite recipes functionality
- Recipe ratings and reviews
- Shopping list generation
- Recipe sharing
- Offline recipe storage
- Push notifications for new recipes

## Troubleshooting

### Common Issues

1. **Backend Connection Error**
   - Verify backend server is running
   - Check `baseUrl` in service files
   - Ensure backend endpoints match expected format

2. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter version compatibility
   - Verify all dependencies are properly installed

3. **App Not Running**
   - Check device/emulator connection
   - Verify Flutter installation with `flutter doctor`
   - Check for any syntax errors in the code

## Support

For issues or questions:
1. Check the Flutter documentation
2. Review the backend API documentation
3. Ensure all dependencies are up to date

## License

This project is part of the Recipe App backend-frontend system.
