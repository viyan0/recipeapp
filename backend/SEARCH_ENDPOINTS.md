# Search Endpoints Documentation

This document describes the comprehensive search functionality for the Recipe App backend, including search history management and analytics.

## Base URL
- **Development**: `http://localhost:3000`
- **Production**: `https://yourdomain.com`

## Overview

The search system provides:
- **Secure search storage** for authenticated users only
- **Duplicate prevention** to avoid spam and improve data quality
- **Search history management** with pagination and filtering
- **Comprehensive validation** and security measures
- **Analytics support** for search patterns and user behavior

## Endpoints

### 1. Save Search Query
**POST** `/api/recipes/search`

Saves a user's search query to the search history table. Authentication required.

#### Request Body
```json
{
  "search_query": "chicken pasta recipes",
  "search_filters": {
    "cuisine": "italian",
    "difficulty": "easy",
    "cooking_time": "30min",
    "dietary": ["vegetarian", "gluten-free"]
  },
  "results_count": 15
}
```

#### Field Descriptions
- **`search_query`** (required): The actual search term (1-500 characters)
- **`search_filters`** (optional): JSON object containing search parameters
- **`results_count`** (optional): Number of results returned (0-10000)

#### Authentication
- **Required**: Must include valid JWT token
- **User Linking**: Search is linked to user account

#### Response

**Success (201 Created)**
```json
{
  "status": "success",
  "message": "Search query saved successfully",
  "data": {
    "searchId": 123,
    "searchQuery": "chicken pasta recipes",
    "searchTimestamp": "2024-01-01T12:00:00.000Z",
    "resultsCount": 15,
            "userId": 456
  }
}
```

**Duplicate Search (200 OK)**
```json
{
  "status": "success",
  "message": "Search query updated",
  "data": {
    "searchId": 123,
    "searchQuery": "chicken pasta recipes",
    "isDuplicate": true,
    "updatedAt": "2024-01-01T12:05:00.000Z"
  }
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
      "value": "",
      "msg": "Search query cannot be empty",
      "path": "search_query",
      "location": "body"
    }
  ]
}
```

### 2. Get Search History
**GET** `/api/recipes/search/history`

Retrieves the authenticated user's search history with pagination support.

#### Query Parameters
- **`limit`** (optional): Number of results per page (default: 20, max: 100)
- **`offset`** (optional): Number of results to skip (default: 0)

#### Authentication
- **Required**: Must include valid JWT token

#### Response

**Success (200 OK)**
```json
{
  "status": "success",
  "data": {
    "searches": [
      {
        "id": 123,
        "search_query": "chicken pasta recipes",
        "search_filters": {
          "cuisine": "italian",
          "difficulty": "easy"
        },
        "results_count": 15,
        "search_timestamp": "2024-01-01T12:00:00.000Z"
      }
    ],
    "pagination": {
      "total": 45,
      "limit": 20,
      "offset": 0,
      "hasMore": true
    }
  }
}
```

**Error (401 Unauthorized)**
```json
{
  "status": "error",
  "message": "Not authorized, no token"
}
```

### 3. Delete Search History Item
**DELETE** `/api/recipes/search/history/:id`

Deletes a specific search from the user's history.

#### Path Parameters
- **`id`**: The search history record ID to delete

#### Authentication
- **Required**: Must include valid JWT token

#### Response

**Success (200 OK)**
```json
{
  "status": "success",
  "message": "Search deleted successfully"
}
```

**Error (404 Not Found)**
```json
{
  "status": "error",
  "message": "Search not found or not authorized to delete"
}
```

## Advanced Features

### Duplicate Prevention
- **Time Window**: 5 minutes for duplicate detection
- **Smart Handling**: Updates timestamp instead of creating duplicates
- **User-Specific**: Only prevents duplicates for the same user

### Search Filters
- **Flexible Structure**: JSON object for any search parameters
- **Validation**: Ensures valid JSON format
- **Storage**: Stored as JSONB in PostgreSQL for efficient querying

### Authentication Required
- **Secure Access**: All searches require valid JWT token
- **User Tracking**: Every search is linked to a specific user account
- **Data Privacy**: Users can only access their own search history

### Pagination
- **Efficient Queries**: Uses LIMIT/OFFSET with proper indexing
- **Count Queries**: Provides total count for UI pagination
- **Bounds Checking**: Prevents negative offsets and excessive limits

## Security Features

### Input Validation
- **Length Limits**: Prevents extremely long queries
- **XSS Protection**: Escapes HTML and script tags
- **Type Validation**: Ensures proper data types
- **Whitespace Handling**: Normalizes and trims input

### Authentication & Authorization
- **JWT Verification**: Secure token-based authentication
- **User Isolation**: Users can only access their own search history
- **Required Auth**: All searches require authentication

### SQL Injection Protection
- **Parameterized Queries**: All database calls use prepared statements
- **Input Sanitization**: Validates and sanitizes all inputs
- **Error Handling**: Graceful handling of database errors

### Rate Limiting
- **Global Protection**: All API endpoints are rate-limited
- **Configurable**: Adjustable limits via environment variables
- **IP-Based**: Prevents abuse from individual sources

## Database Schema

The search system uses the existing `search_history` table:

```sql
CREATE TABLE search_history (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  search_query TEXT NOT NULL,
  search_filters JSONB,
  results_count INTEGER,
  search_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);
```

### Indexes (Recommended)
```sql
-- For efficient user history queries
CREATE INDEX idx_search_history_user_id ON search_history(user_id);

-- For duplicate detection
CREATE INDEX idx_search_history_user_query_time ON search_history(user_id, search_query, search_timestamp);

-- For analytics queries
CREATE INDEX idx_search_history_timestamp ON search_history(search_timestamp);
```

## Error Handling

### HTTP Status Codes
- **200**: Success (GET, duplicate search update)
- **201**: Created (new search saved)
- **400**: Bad Request (validation errors)
- **401**: Unauthorized (missing/invalid token)
- **404**: Not Found (search not found)
- **409**: Conflict (duplicate constraint violation)
- **500**: Internal Server Error (server issues)

### Error Response Format
```json
{
  "status": "error",
  "message": "Human-readable error description",
  "errors": [
    {
      "type": "field",
      "value": "invalid_value",
      "msg": "Specific validation message",
      "path": "field_name",
      "location": "body"
    }
  ]
}
```

## Usage Examples

### Basic Search (Authenticated)
```bash
curl -X POST http://localhost:3000/api/recipes/search \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "search_query": "quick dinner ideas",
    "results_count": 10
  }'
```

### Authenticated Search with Filters
```bash
curl -X POST http://localhost:3000/api/recipes/search \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "search_query": "vegetarian pasta",
    "search_filters": {
      "cuisine": "italian",
      "dietary": ["vegetarian"],
      "cooking_time": "under_30min"
    },
    "results_count": 25
  }'
```

### Get Search History
```bash
curl -X GET "http://localhost:3000/api/recipes/search/history?limit=10&offset=0" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Delete Search Item
```bash
curl -X DELETE http://localhost:3000/api/recipes/search/history/123 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Testing

Run the comprehensive test suite:

```bash
# Install dependencies
npm install

# Start the server
npm start

# In another terminal, run search tests
node test-search-endpoints.js
```

## Performance Considerations

### Database Optimization
- **Connection Pooling**: Efficient database connection management
- **Query Optimization**: Minimal database calls with proper indexing
- **JSONB Storage**: Efficient storage and querying of search filters

### Caching Strategy
- **Search History**: Consider Redis caching for frequently accessed history
- **Popular Searches**: Cache trending search queries
- **User Preferences**: Cache user-specific search patterns

### Monitoring
- **Search Analytics**: Track popular queries and user behavior
- **Performance Metrics**: Monitor response times and database performance
- **Error Tracking**: Log and monitor validation and database errors

## Future Enhancements

### Planned Features
- **Search Analytics**: Dashboard for search patterns and trends
- **Smart Suggestions**: AI-powered search recommendations
- **Search Export**: Download search history as CSV/JSON
- **Bulk Operations**: Delete multiple searches at once
- **Search Categories**: Organize searches by type or topic

### Integration Points
- **Recipe API**: Link searches to actual recipe results
- **User Preferences**: Use search history for personalized recommendations
- **Analytics Platform**: Export data to external analytics tools
- **Machine Learning**: Train models on search patterns
