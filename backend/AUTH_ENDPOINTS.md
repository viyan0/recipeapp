# Authentication Endpoints Documentation

This document describes the user authentication endpoints for the Recipe App backend.

## Base URL
- **Development**: `http://localhost:3000`
- **Production**: `https://yourdomain.com`

## Endpoints

### 1. User Signup
**POST** `/signup`

Creates a new user account.

#### Request Body
```json
{
  "username": "johndoe",
  "email": "john@example.com",
  "password": "password123"
}
```

#### Validation Rules
- `username`: 3-50 characters, alphanumeric and underscores only
- `email`: Valid email format
- `password`: Minimum 6 characters

#### Response

**Success (201 Created)**
```json
{
  "status": "success",
  "message": "User created successfully",
  "data": {
    "user": {
      "id": 1,
      "username": "johndoe",
      "email": "john@example.com",
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  }
}
```

**Error (400 Bad Request)**
```json
{
  "status": "error",
  "message": "Email already exists"
}
```

**Error (400 Bad Request - Validation)**
```json
{
  "status": "error",
  "message": "Validation failed",
  "errors": [
    {
      "type": "field",
      "value": "jo",
      "msg": "Username must be between 3 and 50 characters",
      "path": "username",
      "location": "body"
    }
  ]
}
```

### 2. User Login
**POST** `/login`

Authenticates a user and returns a JWT token.

#### Request Body
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

#### Validation Rules
- `email`: Valid email format
- `password`: Required field

#### Response

**Success (200 OK)**
```json
{
  "status": "success",
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "username": "johndoe",
      "email": "john@example.com"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error (401 Unauthorized)**
```json
{
  "status": "error",
  "message": "Invalid credentials"
}
```

**Error (400 Bad Request - Validation)**
```json
{
  "status": "error",
  "message": "Validation failed",
  "errors": [
    {
      "type": "field",
      "value": "invalid-email",
      "msg": "Please provide a valid email",
      "path": "email",
      "location": "body"
    }
  ]
}
```

## Security Features

### Password Hashing
- Passwords are hashed using bcrypt with a salt round of 10
- Original passwords are never stored in the database

### JWT Authentication
- JWT tokens are generated upon successful login
- Token expiration is configurable via `JWT_EXPIRES_IN` environment variable
- Default expiration: 24 hours

### Input Validation
- All inputs are validated using express-validator
- SQL injection protection through parameterized queries
- XSS protection through helmet middleware

### Rate Limiting
- API endpoints are protected by rate limiting
- Default: 100 requests per 15 minutes per IP

## Error Handling

All endpoints use consistent error response format:
- `status`: Always "error" for error responses
- `message`: Human-readable error description
- `errors`: Array of validation errors (when applicable)

## Testing

You can test these endpoints using the provided test file:

```bash
# Install dependencies
npm install

# Start the server
npm start

# In another terminal, run tests
node test-endpoints.js
```

## Environment Variables

Make sure these environment variables are set in your `config.env`:

```env
DATABASE_URL=your_postgresql_connection_string
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=24h
```

## Database Schema

The endpoints work with the following users table structure:

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name VARCHAR(100),
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
