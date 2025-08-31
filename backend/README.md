# Recipe App Backend API

A robust, secure, and scalable backend API for the Recipe App built with Node.js, Express, and PostgreSQL.

## 🚀 Features

- **User Authentication**: JWT-based authentication with secure password hashing
- **Recipe Search**: Integration with TheMealDB API for recipe discovery
- **User Management**: Profile management, dietary preferences, favorites
- **Search History**: Track user search queries and results
- **Security**: Helmet.js, CORS, rate limiting, input validation
- **Database**: PostgreSQL with connection pooling and automatic table creation
- **Error Handling**: Comprehensive error handling with detailed logging
- **Testing**: Automated test suite for all endpoints

## 🛠️ Tech Stack

- **Runtime**: Node.js (v16+)
- **Framework**: Express.js
- **Database**: PostgreSQL with Neon (cloud hosted)
- **Authentication**: JWT + bcryptjs
- **Validation**: express-validator
- **Security**: Helmet.js, CORS, rate limiting
- **HTTP Client**: Axios for external API calls
- **Logging**: Morgan (development)

## 📋 Prerequisites

- Node.js 16.0.0 or higher
- npm 8.0.0 or higher
- PostgreSQL database (or Neon cloud database)

## 🚀 Quick Start

### 1. Clone and Install

```bash
cd backend
npm install
```

### 2. Environment Configuration

Create a `config.env` file in the backend directory:

```env
# Database Configuration
DATABASE_URL=postgresql://username:password@host:port/database?sslmode=require

# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=24h

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### 3. Start the Server

```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

The server will start on `http://localhost:3000`

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch

# Test database connection
npm run db:test

# Check database tables
npm run db:check
```

## 📚 API Endpoints

### Authentication

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/auth/signup` | User registration | No |
| POST | `/api/auth/login` | User login | No |
| GET | `/api/auth/me` | Get current user | Yes |
| PUT | `/api/auth/profile` | Update user profile | Yes |

### Recipes

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/recipes/search` | Search by ingredients | No |
| GET | `/api/recipes/search-recipes` | Search by name | No |
| POST | `/api/recipes/search-history` | Save search query | Yes |
| GET | `/api/recipes/search/history` | Get search history | Yes |
| DELETE | `/api/recipes/search/history/:id` | Delete search | Yes |
| POST | `/api/recipes/:id/favorite` | Toggle favorite | Yes |
| GET | `/api/recipes/favourites` | Get favorites | Yes |

### Users

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/users/profile` | Get user profile with stats | Yes |
| PUT | `/api/users/:id/dietary-preference` | Update dietary preference | Yes |
| GET | `/api/users/favourites` | Get user favorites | Yes |
| GET | `/api/users/search-history` | Get user search history | Yes |
| GET | `/api/users/:username` | Get public user profile | No |

### Health Check

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/health` | Server health status | No |

## 🔐 Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```
Authorization: Bearer <your-jwt-token>
```

## 📊 Database Schema

### Users Table
- `id`: Primary key
- `username`: Unique username
- `email`: Unique email
- `password_hash`: Bcrypt hashed password
- `full_name`: User's full name
- `avatar_url`: Profile picture URL
- `is_vegetarian`: Dietary preference
- `created_at`: Account creation timestamp
- `updated_at`: Last update timestamp

### Recipes Table
- `id`: Primary key
- `title`: Recipe title
- `description`: Recipe description
- `ingredients`: JSONB ingredients array
- `instructions`: JSONB cooking instructions
- `cooking_time_minutes`: Estimated cooking time
- `difficulty_level`: Easy/Medium/Hard
- `servings`: Number of servings
- `is_vegetarian`: Vegetarian flag
- `image_url`: Recipe image URL

### Search History Table
- `id`: Primary key
- `user_id`: Foreign key to users
- `search_query`: Search term
- `search_filters`: JSONB search filters
- `results_count`: Number of results
- `search_timestamp`: Search timestamp

### Favourites Table
- `id`: Primary key
- `user_id`: Foreign key to users
- `recipe_id`: External recipe ID
- `notes`: User notes
- `rating`: User rating (1-5)
- `added_at`: Favorited timestamp

## 🛡️ Security Features

- **Helmet.js**: Security headers
- **CORS**: Cross-origin resource sharing
- **Rate Limiting**: API rate limiting
- **Input Validation**: Request validation
- **Password Hashing**: Bcrypt with salt
- **JWT Security**: Secure token handling
- **SQL Injection Protection**: Parameterized queries

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | Required |
| `PORT` | Server port | 3000 |
| `NODE_ENV` | Environment mode | development |
| `JWT_SECRET` | JWT signing secret | Required |
| `JWT_EXPIRES_IN` | Token expiration time | 24h |
| `RATE_LIMIT_WINDOW_MS` | Rate limit window | 900000 (15 min) |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per window | 100 |

### Database Configuration

The database connection uses connection pooling with the following settings:
- Max connections: 20
- Min connections: 2
- Connection timeout: 10 seconds
- Idle timeout: 30 seconds
- SSL: Required (for cloud databases)

## 📝 Error Handling

The API provides consistent error responses:

```json
{
  "status": "error",
  "message": "Error description",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "path": "/api/endpoint",
  "method": "POST"
}
```

### HTTP Status Codes

- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `408`: Request Timeout
- `429`: Too Many Requests
- `500`: Internal Server Error
- `503`: Service Unavailable

## 🚀 Deployment

### Production Considerations

1. **Environment Variables**: Set `NODE_ENV=production`
2. **JWT Secret**: Use a strong, unique secret
3. **Database**: Use production database with SSL
4. **Rate Limiting**: Adjust limits for production load
5. **Logging**: Implement proper logging service
6. **Monitoring**: Add health checks and monitoring

### Docker (Optional)

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

## 🧪 Development

### Code Structure

```
backend/
├── config/          # Configuration files
├── middleware/      # Express middleware
├── routes/          # API route handlers
├── server.js        # Main server file
├── test-backend.js  # Test suite
└── package.json     # Dependencies
```

### Adding New Endpoints

1. Create route handler in appropriate route file
2. Add input validation using express-validator
3. Implement proper error handling
4. Add tests to test suite
5. Update documentation

## 🤝 Contributing

1. Follow the existing code style
2. Add tests for new features
3. Update documentation
4. Ensure all tests pass

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

For issues and questions:
1. Check the test suite output
2. Review error logs
3. Verify environment configuration
4. Check database connectivity

## 🔄 Changelog

### v1.0.0
- Initial release
- User authentication system
- Recipe search functionality
- User management features
- Comprehensive test suite
- Security implementations
