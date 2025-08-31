# Project Structure Documentation

## 📁 Directory Overview

```
backend/
├── 📁 config/                 # Configuration files
│   └── database.js           # Database connection and setup
├── 📁 middleware/            # Custom middleware functions
│   ├── auth.js              # Authentication middleware
│   └── errorHandler.js      # Global error handling
├── 📁 routes/               # API route definitions
│   ├── auth.js             # Authentication routes
│   ├── recipes.js          # Recipe management routes
│   └── users.js            # User management routes
├── 📄 server.js             # Main server entry point
├── 📄 package.json          # Dependencies and scripts
├── 📄 config.env            # Environment variables
├── 📄 README.md             # Main documentation
├── 📄 PROJECT_STRUCTURE.md  # This file
├── 📄 .gitignore            # Git ignore rules
├── 📄 start.bat             # Windows startup script
├── 📄 start.sh              # Unix startup script
└── 📄 test-connection.js    # Database connection test
```

## 🔧 Configuration Files

### `config/database.js`
- **Purpose**: Database connection management
- **Features**:
  - PostgreSQL connection pooling
  - SSL configuration for Neon
  - Automatic table creation
  - Connection testing utilities
- **Key Functions**:
  - `connectDB()`: Initialize database and tables
  - `testConnection()`: Test database connectivity
  - `pool`: Connection pool instance

### `config.env`
- **Purpose**: Environment configuration
- **Contains**:
  - Database connection string
  - JWT secrets
  - Server settings
  - Rate limiting configuration

## 🛡️ Middleware

### `middleware/auth.js`
- **Purpose**: Authentication and authorization
- **Functions**:
  - `protect`: JWT token verification
  - `optionalAuth`: Non-blocking authentication
  - `authorize`: Role-based access control
- **Usage**: Applied to protected routes

### `middleware/errorHandler.js`
- **Purpose**: Global error handling
- **Features**:
  - PostgreSQL error mapping
  - Validation error handling
  - JWT error handling
  - Development vs production error responses

## 🛣️ API Routes

### `routes/auth.js`
- **Endpoints**:
  - `POST /register`: User registration
  - `POST /login`: User authentication
  - `GET /me`: Current user profile
  - `PUT /profile`: Profile updates
- **Features**: Input validation, password hashing, JWT generation

### `routes/recipes.js`
- **Endpoints**:
  - `GET /`: List recipes with filtering
  - `GET /:id`: Get specific recipe
  - `POST /`: Create new recipe
  - `PUT /:id`: Update recipe
  - `DELETE /:id`: Delete recipe
  - `POST /:id/favorite`: Toggle favorite
  - `POST /:id/rate`: Rate recipe
- **Features**: Search, filtering, pagination, user permissions

### `routes/users.js`
- **Endpoints**:
  - `GET /profile`: User profile with stats
  - `GET /recipes`: User's recipes
  - `GET /favorites`: User's favorites
  - `GET /ratings`: User's ratings
  - `GET /:username`: Public user profile
- **Features**: User statistics, recipe management, privacy controls

## 🚀 Server Configuration

### `server.js`
- **Purpose**: Main application entry point
- **Features**:
  - Express server setup
  - Middleware configuration
  - Route registration
  - Error handling
  - Graceful shutdown
- **Middleware Stack**:
  1. Helmet (security headers)
  2. CORS (cross-origin)
  3. Rate limiting
  4. Body parsing
  5. Logging (morgan)
  6. Routes
  7. Error handling

## 📦 Dependencies

### Production Dependencies
- **express**: Web framework
- **pg**: PostgreSQL client
- **cors**: Cross-origin resource sharing
- **helmet**: Security headers
- **morgan**: HTTP request logging
- **express-rate-limit**: Rate limiting
- **bcryptjs**: Password hashing
- **jsonwebtoken**: JWT authentication
- **express-validator**: Input validation

### Development Dependencies
- **nodemon**: Auto-restart on file changes
- **jest**: Testing framework

## 🗄️ Database Schema

### Tables Created Automatically
1. **users**
   - id, username, email, password_hash
   - full_name, avatar_url, timestamps

2. **recipes**
   - id, title, description, ingredients (JSONB)
   - instructions (JSONB), cooking_time, servings
   - difficulty, cuisine_type, tags, image_url
   - user_id, is_public, timestamps

3. **favorites**
   - id, user_id, recipe_id, timestamp

4. **ratings**
   - id, user_id, recipe_id, rating, review, timestamps

## 🔐 Security Features

- **JWT Authentication**: Secure token-based auth
- **Password Hashing**: bcrypt with salt
- **Input Validation**: Request sanitization
- **Rate Limiting**: API abuse prevention
- **CORS**: Controlled cross-origin access
- **Helmet**: Security headers
- **SQL Injection Protection**: Parameterized queries

## 📊 API Response Format

### Success Response
```json
{
  "status": "success",
  "message": "Operation completed",
  "data": { ... }
}
```

### Error Response
```json
{
  "status": "error",
  "message": "Error description",
  "errors": [ ... ]
}
```

## 🚦 Rate Limiting

- **Window**: 15 minutes
- **Limit**: 100 requests per IP
- **Applied**: To all `/api/` routes
- **Response**: 429 Too Many Requests

## 🔍 Search & Filtering

### Recipe Filters
- **Text Search**: Title and description
- **Cuisine**: Specific cuisine type
- **Difficulty**: easy/medium/hard
- **Time**: Maximum cooking time
- **Pagination**: Page and limit

### Query Parameters
- `?search=pasta&cuisine=italian&difficulty=easy&page=1&limit=10`

## 🧪 Testing

### Test Scripts
- `test-connection.js`: Database connectivity test
- `npm test`: Jest test suite
- `npm run test:watch`: Watch mode testing

### Test Coverage
- Database connection
- Table creation
- Basic queries
- Error handling

## 🚀 Deployment

### Environment Setup
1. Set `NODE_ENV=production`
2. Configure production database
3. Set secure JWT secret
4. Configure CORS origins

### Process Management
- PM2 recommended for production
- Environment variable management
- Log rotation
- Health monitoring

## 📝 Development Workflow

1. **Setup**: Install dependencies with `npm install`
2. **Configure**: Set environment variables in `config.env`
3. **Test**: Run `node test-connection.js`
4. **Develop**: Use `npm run dev` for auto-reload
5. **Deploy**: Use `npm start` for production

## 🔧 Troubleshooting

### Common Issues
1. **Database Connection**: Check DATABASE_URL and SSL settings
2. **Port Conflicts**: Verify PORT environment variable
3. **Dependencies**: Ensure `npm install` completed
4. **Permissions**: Check file permissions on startup scripts

### Debug Steps
1. Check server logs
2. Verify environment variables
3. Test database connection
4. Check middleware order
5. Validate request data
