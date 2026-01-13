# Wishlist API Documentation

This document describes all the APIs used for Wishlist functionality in the app.

## Table of Contents
1. [Add to Wishlist API](#1-add-to-wishlist-api)
2. [Remove from Wishlist API](#2-remove-from-wishlist-api)
3. [Get Wishlist List API](#3-get-wishlist-list-api)
4. [Request/Response Models](#requestresponse-models)
5. [Error Handling](#error-handling)

---

## 1. Add to Wishlist API

### Endpoint
```
POST /api/wishlist/add
```

### Headers
```
Authorization: Bearer {jwtToken}
Content-Type: application/json
```

### Request Body
```json
{
  "productId": "product_1"
}
```

### Request Example
```bash
POST /api/wishlist/add
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "productId": "product_1"
}
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Added to wishlist successfully",
  "data": {
    "wishlistId": "wishlist_1705123456789",
    "productId": "product_1",
    "addedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

### Mock Response Examples

#### Example 1: Successfully Add Product to Wishlist
**Request:**
```json
POST /api/wishlist/add
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "productId": "product_1"
}
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Added to wishlist successfully",
  "data": {
    "wishlistId": "wishlist_1705123456789",
    "productId": "product_1",
    "addedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

#### Example 2: Add Another Product
**Request:**
```json
POST /api/wishlist/add
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "productId": "product_2"
}
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Added to wishlist successfully",
  "data": {
    "wishlistId": "wishlist_1705123457890",
    "productId": "product_2",
    "addedAt": "2024-01-15T10:31:00.000Z"
  }
}
```

### Error Responses

#### Error 1: Missing JWT Token
**Request:**
```json
POST /api/wishlist/add
(No Authorization header)

{
  "productId": "product_1"
}
```

**Response:**
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Authentication required. Please login to add items to wishlist.",
  "data": null
}
```

#### Error 2: Invalid JWT Token
**Request:**
```json
POST /api/wishlist/add
Authorization: Bearer invalid_token

{
  "productId": "product_1"
}
```

**Response:**
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Invalid or expired token. Please login again.",
  "data": null
}
```

#### Error 3: Product Not Found
**Request:**
```json
POST /api/wishlist/add
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "productId": "product_nonexistent"
}
```

**Response:**
```json
{
  "success": false,
  "statusCode": 404,
  "message": "Product not found",
  "data": null
}
```

#### Error 4: Product Already in Wishlist
**Request:**
```json
POST /api/wishlist/add
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "productId": "product_1"
}
```
*(If product_1 is already in wishlist)*

**Response:**
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Product is already in your wishlist",
  "data": null
}
```

---

## 2. Remove from Wishlist API

### Endpoint
```
DELETE /api/wishlist/remove/{productId}
```

### Headers
```
Authorization: Bearer {jwtToken}
```

### Path Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| productId | string | Yes | ID of the product to remove from wishlist |

### Request Example
```bash
DELETE /api/wishlist/remove/product_1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Removed from wishlist successfully",
  "data": {
    "wishlistId": "wishlist_1705123456789",
    "productId": "product_1",
    "removedAt": "2024-01-15T10:35:00.000Z"
  }
}
```

### Mock Response Examples

#### Example 1: Successfully Remove Product from Wishlist
**Request:**
```
DELETE /api/wishlist/remove/product_1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Removed from wishlist successfully",
  "data": {
    "wishlistId": "wishlist_1705123456789",
    "productId": "product_1",
    "removedAt": "2024-01-15T10:35:00.000Z"
  }
}
```

### Error Responses

#### Error 1: Missing JWT Token
**Request:**
```
DELETE /api/wishlist/remove/product_1
(No Authorization header)
```

**Response:**
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Authentication required. Please login to remove items from wishlist.",
  "data": null
}
```

#### Error 2: Product Not in Wishlist
**Request:**
```
DELETE /api/wishlist/remove/product_999
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": false,
  "statusCode": 404,
  "message": "Product not found in wishlist",
  "data": null
}
```

---

## 3. Get Wishlist List API

### Endpoint
```
GET /api/wishlist/list
```

### Headers
```
Authorization: Bearer {jwtToken}
```

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| type | string | No | Filter by product type: `'rent'` or `'sell'` |
| page | number | No | Page number (default: 1) |
| per_page | number | No | Items per page (default: 20) |

### Request Example
```bash
GET /api/wishlist/list?type=rent&page=1&per_page=20
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Wishlist retrieved successfully",
  "data": {
    "products": [
      {
        "id": "product_1",
        "type": "rent",
        "title": "Groom Blazer",
        "description": "Stylish blazer for rent.",
        "price": 500,
        "deposit": 1000,
        "categoryId": "cat_groom_collection",
        "subcategoryId": "sub_blazer",
        "imageUrls": [
          "https://via.placeholder.com/150/FF5733/FFFFFF?text=Blazer1",
          "https://via.placeholder.com/150/C70039/FFFFFF?text=Blazer2"
        ],
        "location": "Mumbai",
        "contactPhone": "+919876543210",
        "isContactShow": true,
        "gender": "men",
        "condition": "like_new",
        "sellerId": "seller_1",
        "sellerName": "John Doe",
        "sellerImageUrl": "https://via.placeholder.com/200/200?text=JD",
        "createdAt": "2024-01-10T10:30:00.000Z",
        "latitude": 19.0760,
        "longitude": 72.8777,
        "isWishlisted": true,
        "distance": 0.5
      }
    ],
    "totalItems": 1,
    "currentPage": 1,
    "totalPages": 1,
    "perPage": 20,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```

### Mock Response Examples

#### Example 1: Get All Wishlist Items
**Request:**
```
GET /api/wishlist/list
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Wishlist retrieved successfully",
  "data": {
    "products": [
      {
        "id": "product_1",
        "type": "rent",
        "title": "Groom Blazer",
        "description": "Stylish blazer for rent.",
        "price": 500,
        "deposit": 1000,
        "categoryId": "cat_groom_collection",
        "subcategoryId": "sub_blazer",
        "imageUrls": [
          "https://via.placeholder.com/150/FF5733/FFFFFF?text=Blazer1",
          "https://via.placeholder.com/150/C70039/FFFFFF?text=Blazer2"
        ],
        "location": "Mumbai",
        "contactPhone": "+919876543210",
        "isContactShow": true,
        "gender": "men",
        "condition": "like_new",
        "sellerId": "seller_1",
        "sellerName": "John Doe",
        "sellerImageUrl": "https://via.placeholder.com/200/200?text=JD",
        "createdAt": "2024-01-10T10:30:00.000Z",
        "latitude": 19.0760,
        "longitude": 72.8777,
        "isWishlisted": true,
        "distance": 0.5
      },
      {
        "id": "product_2",
        "type": "sell",
        "title": "Designer Lehenga",
        "description": "Beautiful designer lehenga for sale.",
        "price": 15000,
        "categoryId": "cat_bride_collection",
        "subcategoryId": "sub_lehenga",
        "imageUrls": [
          "https://via.placeholder.com/150/900C3F/FFFFFF?text=Lehenga1",
          "https://via.placeholder.com/150/581845/FFFFFF?text=Lehenga2"
        ],
        "location": "Delhi",
        "contactPhone": "+919988776655",
        "isContactShow": true,
        "gender": "women",
        "condition": "new",
        "sellerId": "seller_2",
        "sellerName": "Jane Smith",
        "sellerImageUrl": "https://via.placeholder.com/200/200?text=JS",
        "createdAt": "2024-01-05T14:20:00.000Z",
        "latitude": 28.6139,
        "longitude": 77.2090,
        "isWishlisted": true,
        "distance": 2.3
      }
    ],
    "totalItems": 2,
    "currentPage": 1,
    "totalPages": 1,
    "perPage": 20,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```

#### Example 2: Filter by Type (Rent)
**Request:**
```
GET /api/wishlist/list?type=rent
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Wishlist retrieved successfully",
  "data": {
    "products": [
      {
        "id": "product_1",
        "type": "rent",
        "title": "Groom Blazer",
        "description": "Stylish blazer for rent.",
        "price": 500,
        "deposit": 1000,
        "categoryId": "cat_groom_collection",
        "subcategoryId": "sub_blazer",
        "imageUrls": [
          "https://via.placeholder.com/150/FF5733/FFFFFF?text=Blazer1"
        ],
        "location": "Mumbai",
        "contactPhone": "+919876543210",
        "isContactShow": true,
        "gender": "men",
        "condition": "like_new",
        "sellerId": "seller_1",
        "sellerName": "John Doe",
        "sellerImageUrl": "https://via.placeholder.com/200/200?text=JD",
        "createdAt": "2024-01-10T10:30:00.000Z",
        "latitude": 19.0760,
        "longitude": 72.8777,
        "isWishlisted": true,
        "distance": 0.5
      }
    ],
    "totalItems": 1,
    "currentPage": 1,
    "totalPages": 1,
    "perPage": 20,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```

#### Example 3: Filter by Type (Sell)
**Request:**
```
GET /api/wishlist/list?type=sell
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Wishlist retrieved successfully",
  "data": {
    "products": [
      {
        "id": "product_2",
        "type": "sell",
        "title": "Designer Lehenga",
        "description": "Beautiful designer lehenga for sale.",
        "price": 15000,
        "categoryId": "cat_bride_collection",
        "subcategoryId": "sub_lehenga",
        "imageUrls": [
          "https://via.placeholder.com/150/900C3F/FFFFFF?text=Lehenga1"
        ],
        "location": "Delhi",
        "contactPhone": "+919988776655",
        "isContactShow": true,
        "gender": "women",
        "condition": "new",
        "sellerId": "seller_2",
        "sellerName": "Jane Smith",
        "sellerImageUrl": "https://via.placeholder.com/200/200?text=JS",
        "createdAt": "2024-01-05T14:20:00.000Z",
        "latitude": 28.6139,
        "longitude": 77.2090,
        "isWishlisted": true,
        "distance": 2.3
      }
    ],
    "totalItems": 1,
    "currentPage": 1,
    "totalPages": 1,
    "perPage": 20,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```

#### Example 4: Empty Wishlist
**Request:**
```
GET /api/wishlist/list
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Wishlist retrieved successfully",
  "data": {
    "products": [],
    "totalItems": 0,
    "currentPage": 1,
    "totalPages": 1,
    "perPage": 20,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```

### Error Responses

#### Error 1: Missing JWT Token
**Request:**
```
GET /api/wishlist/list
(No Authorization header)
```

**Response:**
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Authentication required. Please login to view wishlist.",
  "data": null
}
```

#### Error 2: Invalid JWT Token
**Request:**
```
GET /api/wishlist/list
Authorization: Bearer invalid_token
```

**Response:**
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Invalid or expired token. Please login again.",
  "data": null
}
```

---

## Request/Response Models

### WishlistAddRequestModel
```json
{
  "productId": "string"  // Required: ID of the product to add
}
```

### WishlistResponseModel (Add/Remove)
```json
{
  "success": boolean,
  "statusCode": number,
  "message": "string",
  "data": {
    "wishlistId": "string",      // Unique wishlist item ID
    "productId": "string",        // Product ID
    "addedAt": "string",          // ISO 8601 timestamp (for add)
    "removedAt": "string"         // ISO 8601 timestamp (for remove)
  }
}
```

### WishlistListResponseModel
```json
{
  "success": boolean,
  "statusCode": number,
  "message": "string",
  "data": {
    "products": [ProductModel],   // Array of ProductModel objects
    "totalItems": number,         // Total number of items in wishlist
    "currentPage": number,        // Current page number
    "totalPages": number,         // Total number of pages
    "perPage": number,            // Items per page
    "hasNextPage": boolean,       // Whether there are more pages
    "hasPreviousPage": boolean    // Whether there are previous pages
  }
}
```

### ProductModel (in Wishlist)
```json
{
  "id": "string",
  "type": "rent" | "sell",
  "title": "string",
  "description": "string",
  "price": number,
  "deposit": number | null,       // Only for rental items
  "categoryId": "string",
  "subcategoryId": "string",
  "imageUrls": ["string"],
  "location": "string",
  "contactPhone": "string" | null,
  "isContactShow": boolean,
  "gender": "men" | "women" | "unisex",
  "condition": "string" | null,
  "size": "string" | null,
  "color": "string" | null,
  "brand": "string" | null,
  "sellerId": "string",
  "sellerName": "string" | null,
  "sellerImageUrl": "string" | null,
  "createdAt": "string",         // ISO 8601 timestamp
  "latitude": number | null,
  "longitude": number | null,
  "isWishlisted": true,           // Always true in wishlist
  "distance": number | null       // Distance in km from user's location
}
```

---

## Error Handling

### HTTP Status Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 400 | Bad Request (e.g., product already in wishlist) |
| 401 | Unauthorized (missing or invalid JWT token) |
| 404 | Not Found (product not found or not in wishlist) |
| 500 | Internal Server Error |

### Error Response Format
```json
{
  "success": false,
  "statusCode": number,
  "message": "string",
  "data": null
}
```

---

## Implementation Notes

1. **Authentication**: All wishlist APIs require a valid JWT token in the Authorization header. Guest users cannot access wishlist features.

2. **Optimistic UI**: The app implements optimistic UI updates - the UI updates immediately when adding/removing items, and reverts if the API call fails.

3. **Filtering**: The wishlist list API supports filtering by product type (`rent` or `sell`).

4. **Pagination**: The wishlist list API supports pagination with `page` and `per_page` parameters.

5. **Response Time**: Mock API simulates network delay with 500-600ms delay.

6. **Wishlist State**: The wishlist state is maintained in memory for the mock API. In a real app, this would be persisted on the server.

---

## Usage Examples

### Add Product to Wishlist
```dart
// Request
POST /api/wishlist/add
Authorization: Bearer {jwtToken}
{
  "productId": "product_1"
}

// Response
{
  "success": true,
  "statusCode": 200,
  "message": "Added to wishlist successfully",
  "data": {
    "wishlistId": "wishlist_1705123456789",
    "productId": "product_1",
    "addedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

### Remove Product from Wishlist
```dart
// Request
DELETE /api/wishlist/remove/product_1
Authorization: Bearer {jwtToken}

// Response
{
  "success": true,
  "statusCode": 200,
  "message": "Removed from wishlist successfully",
  "data": {
    "wishlistId": "wishlist_1705123456789",
    "productId": "product_1",
    "removedAt": "2024-01-15T10:35:00.000Z"
  }
}
```

### Get Wishlist Items
```dart
// Request
GET /api/wishlist/list?type=rent
Authorization: Bearer {jwtToken}

// Response
{
  "success": true,
  "statusCode": 200,
  "message": "Wishlist retrieved successfully",
  "data": {
    "products": [...],
    "totalItems": 5,
    "currentPage": 1,
    "totalPages": 1,
    "perPage": 20,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```


