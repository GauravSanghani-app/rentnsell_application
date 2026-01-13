# Home and Wishlist API Documentation

This document describes all the mock APIs used for the Home screen, Product Detail screen, and Wishlist functionality.

## Table of Contents
1. [Product APIs](#product-apis)
2. [Wishlist APIs](#wishlist-apis)
3. [Request/Response Models](#requestresponse-models)

---

## Product APIs

### 1. GET Products List

**Endpoint:** `GET /api/products`

**Headers:**
```
Authorization: Bearer {jwtToken}
```

**Query Parameters:**
- `type` (required): `'rent'` or `'sell'`
- `page` (optional, default: 1): Page number
- `per_page` (optional, default: 10): Items per page
- `q` (optional): Search query string
- `categoryId` (optional): Filter by category ID
- `subcategoryId` (optional): Filter by subcategory ID
- `gender` (optional): Filter by gender (`'men'`, `'women'`, `'unisex'`)
- `minPrice` (optional): Minimum price filter
- `maxPrice` (optional): Maximum price filter
- `latitude` (optional): User's latitude for distance calculation
- `longitude` (optional): User's longitude for distance calculation

**Example Request:**
```
GET /api/products?type=rent&page=1&per_page=10&latitude=19.0760&longitude=72.8777
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Products retrieved successfully",
  "data": {
    "products": [
      {
        "id": "product_1",
        "type": "rent",
        "title": "Product 1 - groom collection",
        "description": "This is a detailed description for product 1...",
        "price": 150,
        "deposit": 600,
        "categoryId": "cat_groom_collection",
        "subcategoryId": "sub_blazer",
        "imageUrls": [
          "https://picsum.photos/400/400?random=1",
          "https://picsum.photos/400/400?random=101"
        ],
        "location": "Location 1, City",
        "contactPhone": "+1234567891",
        "isContactShow": true,
        "gender": "men",
        "condition": "new",
        "size": "L",
        "color": "Blue",
        "brand": "Brand 1",
        "sellerId": "seller_1",
        "sellerName": "Seller 1",
        "sellerImageUrl": "https://picsum.photos/200/200?random=201",
        "createdAt": "2024-01-15T10:30:00Z",
        "latitude": 19.0860,
        "longitude": 72.8877,
        "isWishlisted": false,
        "distance": 1.2
      }
    ],
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 50,
    "perPage": 10,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

**Notes:**
- Products are filtered by `type` (rent or sell)
- If `latitude` and `longitude` are provided, distance is calculated using Haversine formula
- Products are sorted by distance if coordinates are provided
- Search query (`q`) searches in title, description, and location
- Pagination is handled via `page` and `per_page` parameters

---

### 2. GET Recommended Products

**Endpoint:** `GET /api/products/recommended`

**Headers:**
```
Authorization: Bearer {jwtToken}
```

**Query Parameters:**
- `type` (required): `'rent'` or `'sell'`
- `latitude` (optional): User's latitude
- `longitude` (optional): User's longitude

**Example Request:**
```
GET /api/products/recommended?type=rent&latitude=19.0760&longitude=72.8777
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
[
  {
    "id": "product_1",
    "type": "rent",
    "title": "Product 1 - groom collection",
    "description": "This is a detailed description...",
    "price": 150,
    "deposit": 600,
    "categoryId": "cat_groom_collection",
    "subcategoryId": "sub_blazer",
    "imageUrls": ["https://picsum.photos/400/400?random=1"],
    "location": "Location 1, City",
    "contactPhone": "+1234567891",
    "isContactShow": true,
    "gender": "men",
    "condition": "new",
    "size": "L",
    "color": "Blue",
    "brand": "Brand 1",
    "sellerId": "seller_1",
    "sellerName": "Seller 1",
    "sellerImageUrl": "https://picsum.photos/200/200?random=201",
    "createdAt": "2024-01-15T10:30:00Z",
    "latitude": 19.0860,
    "longitude": 72.8877,
    "isWishlisted": false,
    "distance": 1.2
  }
]
```

**Notes:**
- Returns top 10 recommended products for the specified type
- Distance is calculated if coordinates are provided

---

### 3. GET Product Detail

**Endpoint:** `GET /api/products/{productId}`

**Headers:**
```
Authorization: Bearer {jwtToken}
```

**Example Request:**
```
GET /api/products/product_1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Product retrieved successfully",
  "data": {
    "id": "product_1",
    "type": "rent",
    "title": "Product 1 - groom collection",
    "description": "This is a detailed description for product 1...",
    "price": 150,
    "deposit": 600,
    "categoryId": "cat_groom_collection",
    "subcategoryId": "sub_blazer",
    "imageUrls": [
      "https://picsum.photos/400/400?random=1",
      "https://picsum.photos/400/400?random=101"
    ],
    "location": "Location 1, City",
    "contactPhone": "+1234567891",
    "isContactShow": true,
    "gender": "men",
    "condition": "new",
    "size": "L",
    "color": "Blue",
    "brand": "Brand 1",
    "sellerId": "seller_1",
    "sellerName": "Seller 1",
    "sellerImageUrl": "https://picsum.photos/200/200?random=201",
    "createdAt": "2024-01-15T10:30:00Z",
    "latitude": 19.0860,
    "longitude": 72.8877,
    "isWishlisted": false,
    "distance": 1.2
  }
}
```

---

## Wishlist APIs

### 1. POST Add to Wishlist

**Endpoint:** `POST /api/wishlist/add`

**Headers:**
```
Authorization: Bearer {jwtToken}
Content-Type: application/json
```

**Request Body:**
```json
{
  "productId": "product_1"
}
```

**Example Request:**
```
POST /api/wishlist/add
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

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
    "wishlistId": "wishlist_1705312200000",
    "productId": "product_1",
    "addedAt": "2024-01-15T10:30:00Z"
  }
}
```

---

### 2. DELETE Remove from Wishlist

**Endpoint:** `DELETE /api/wishlist/remove/{productId}`

**Headers:**
```
Authorization: Bearer {jwtToken}
```

**Example Request:**
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
    "wishlistId": "wishlist_1705312200000",
    "productId": "product_1",
    "addedAt": "2024-01-15T10:30:00Z"
  }
}
```

---

### 3. GET Wishlist List

**Endpoint:** `GET /api/wishlist/list`

**Headers:**
```
Authorization: Bearer {jwtToken}
```

**Example Request:**
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
        "title": "Product 1 - groom collection",
        "description": "This is a detailed description...",
        "price": 150,
        "deposit": 600,
        "categoryId": "cat_groom_collection",
        "subcategoryId": "sub_blazer",
        "imageUrls": ["https://picsum.photos/400/400?random=1"],
        "location": "Location 1, City",
        "contactPhone": "+1234567891",
        "isContactShow": true,
        "gender": "men",
        "condition": "new",
        "size": "L",
        "color": "Blue",
        "brand": "Brand 1",
        "sellerId": "seller_1",
        "sellerName": "Seller 1",
        "sellerImageUrl": "https://picsum.photos/200/200?random=201",
        "createdAt": "2024-01-15T10:30:00Z",
        "latitude": 19.0860,
        "longitude": 72.8877,
        "isWishlisted": true,
        "distance": 1.2
      }
    ],
    "totalItems": 1
  }
}
```

**Notes:**
- Returns all products in the user's wishlist
- Products include full product data
- `isWishlisted` is always `true` for wishlist items

---

## Request/Response Models

### ProductModel
```dart
class ProductModel {
  final String id;
  final String type; // 'rent' or 'sell'
  final String title;
  final String description;
  final double price;
  final double? deposit; // Only for rental items
  final String categoryId;
  final String subcategoryId;
  final List<String> imageUrls;
  final String location;
  final String? contactPhone;
  final bool isContactShow; // Whether to show contact details
  final String gender; // 'men', 'women', 'unisex'
  final String? condition; // 'new', 'like_new', 'good', 'fair'
  final String? size;
  final String? color;
  final String? brand;
  final String sellerId;
  final String? sellerName;
  final String? sellerImageUrl;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final bool isWishlisted;
  final double? distance; // Distance in km
}
```

### WishlistAddRequestModel
```dart
class WishlistAddRequestModel {
  final String productId;
}
```

### ProductListResponseData
```dart
class ProductListResponseData {
  final List<ProductModel> products;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  final bool hasNextPage;
  final bool hasPreviousPage;
}
```

---

## Implementation Notes

1. **Optimistic UI Updates**: Wishlist add/remove operations update the UI immediately, then call the API in the background. If the API call fails, the UI is reverted and an error toast is shown.

2. **Distance Calculation**: Uses the Haversine formula to calculate distance between user's location and product location.

3. **Pagination**: Products are paginated with `page` and `per_page` parameters. Infinite scroll loads more products when the user scrolls to the bottom.

4. **Search**: Search query searches in product title, description, and location fields.

5. **Filters**: Multiple filters can be applied simultaneously (category, subcategory, gender, price range).

6. **Contact Visibility**: The `isContactShow` field determines whether contact details are shown. If `false`, the user is prompted to complete their profile.

7. **Pull-to-Refresh**: Both Home and Wishlist screens support pull-to-refresh to reload data.

8. **JWT Authentication**: All APIs require a JWT token in the Authorization header. If the user is not logged in, an empty token string is sent (for guest mode).

---

## Error Handling

All APIs return a standard response format:
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Error message here",
  "data": null
}
```

Common error codes:
- `400`: Bad Request (invalid parameters)
- `401`: Unauthorized (invalid or missing JWT token)
- `404`: Not Found (product not found)
- `500`: Internal Server Error

---

## Mock Data

The mock API service generates 50 products with the following distribution:
- Types: 50% rent, 50% sell
- Categories: Various categories from the category list
- Locations: Mumbai area (latitude ~19.0760, longitude ~72.8777)
- Contact visibility: ~67% show contact, ~33% don't
- Conditions: Distributed across 'new', 'like_new', 'good', 'fair'
- Genders: Distributed across 'men', 'women', 'unisex'


