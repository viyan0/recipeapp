# Recipe Search Endpoint

## Overview
This endpoint allows you to search for recipes from TheMealDB API by name. It's a public endpoint that doesn't require authentication.

## Endpoint
```
GET /api/recipes/search
```

## Query Parameters
- `query` (required): The search term for recipe names (e.g., "chicken", "pasta", "cake")

## Example Request
```bash
GET /api/recipes/search?query=chicken
```

## Response Format

### Success Response (200)
```json
{
  "status": "success",
  "message": "Recipes found successfully",
  "data": {
    "query": "chicken",
    "recipes": [
      {
        "id": "52795",
        "title": "Chicken Handi",
        "image": "https://www.themealdb.com/images/media/meals/wyxwsp1486979827.jpg",
        "category": "Chicken",
        "area": "Indian",
        "ingredients": [
          {
            "ingredient": "Chicken",
            "measure": "1kg"
          },
          {
            "ingredient": "Onion",
            "measure": "2 large"
          }
        ],
        "instructions": "Clean and wash the chicken...",
        "tags": ["Chicken", "Indian", "Spicy"],
        "youtube": "https://www.youtube.com/watch?v=example",
        "source": "https://example.com/recipe"
      }
    ],
    "totalResults": 1
  }
}
```

### No Results Found (200)
```json
{
  "status": "success",
  "message": "No recipes found",
  "data": {
    "query": "nonexistentrecipe",
    "recipes": [],
    "totalResults": 0
  }
}
```

### Error Responses

#### Missing Query Parameter (400)
```json
{
  "status": "error",
  "message": "Query parameter is required"
}
```

#### Query Too Long (400)
```json
{
  "status": "error",
  "message": "Query parameter too long (max 100 characters)"
}
```

#### API Timeout (408)
```json
{
  "status": "error",
  "message": "Request timeout - TheMealDB API is taking too long to respond"
}
```

#### API Unavailable (503)
```json
{
  "status": "error",
  "message": "TheMealDB API is currently unavailable"
}
```

#### Server Error (500)
```json
{
  "status": "error",
  "message": "Server error while searching recipes"
}
```

## Features
- **Input Validation**: Validates query parameter length and presence
- **Error Handling**: Comprehensive error handling for various failure scenarios
- **Data Processing**: Extracts and formats ingredients, instructions, and metadata
- **Timeout Protection**: 10-second timeout to prevent hanging requests
- **Clean Data**: Filters out empty ingredients and normalizes instructions

## Rate Limiting
This endpoint is subject to the same rate limiting as other API endpoints (100 requests per 15 minutes per IP by default).

## Dependencies
- `axios`: For making HTTP requests to TheMealDB API
- TheMealDB API: External recipe database

## Notes
- The endpoint is public and doesn't require authentication
- Results are limited to what TheMealDB API returns
- All recipe data comes from TheMealDB and is processed for consistency
- The endpoint automatically handles URL encoding of search queries
