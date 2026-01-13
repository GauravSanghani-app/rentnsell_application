# Category and Product Filtering API Documentation

This document describes the APIs used for Category browsing and Product filtering functionality in the app.

## Table of Contents
1. [Get Categories API](#1-get-categories-api)
2. [Get Subcategories API](#2-get-subcategories-api)
3. [Get Products with Category/Subcategory Filter API](#3-get-products-with-categorysubcategory-filter-api)
4. [Request/Response Models](#requestresponse-models)
5. [API Changes Summary](#api-changes-summary)

---

## 1. Get Categories API

### Endpoint
```
GET /api/categories
```

### Headers
```
Authorization: Bearer {jwtToken} (optional - works in guest mode)
```

### Query Parameters
None

### Request Example
```bash
GET /api/categories
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {
      "id": "cat_men",
      "name": "Men",
      "imageUrl": "https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400"
    }
  ]
}
```

### Mock Response Example
**Request:**
```
GET /api/categories
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {
      "id": "cat_men",
      "name": "Men",
      "imageUrl": "https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400"
    },
    {
      "id": "cat_women",
      "name": "Women",
      "imageUrl": "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400"
    },
    {
      "id": "cat_women_westernwear",
      "name": "Women Westernwear",
      "imageUrl": "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=400"
    },
    {
      "id": "cat_jewellery",
      "name": "Jewellery",
      "imageUrl": "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=400"
    },
    {
      "id": "cat_groom_collection",
      "name": "Groom Collection",
      "imageUrl": "https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400"
    },
    {
      "id": "cat_bride_collection",
      "name": "Bride Collection",
      "imageUrl": "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=400"
    },
    {
      "id": "cat_car",
      "name": "Car",
      "imageUrl": "https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400"
    },
    {
      "id": "cat_bike",
      "name": "Bike",
      "imageUrl": "https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=400"
    },
    {
      "id": "cat_house",
      "name": "House",
      "imageUrl": "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=400"
    },
    {
      "id": "cat_farmhouse",
      "name": "Farmhouse",
      "imageUrl": "https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=400"
    },
    {
      "id": "cat_property",
      "name": "Property",
      "imageUrl": "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=400"
    },
    {
      "id": "cat_partyplot",
      "name": "Party Plot",
      "imageUrl": "https://images.unsplash.com/photo-1511578314322-379afb476865?w=400"
    },
    {
      "id": "cat_baby_boy",
      "name": "Baby Boy Collection",
      "imageUrl": "https://images.unsplash.com/photo-1503454537195-1dcabb73ffb9?w=400"
    },
    {
      "id": "cat_baby_girl",
      "name": "Baby Girl Collection",
      "imageUrl": "https://images.unsplash.com/photo-1515488042361-ee00e0d4d8b6?w=400"
    },
    {
      "id": "cat_cycle",
      "name": "Cycle",
      "imageUrl": "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400"
    },
    {
      "id": "cat_electronic",
      "name": "Electronic",
      "imageUrl": "https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400"
    },
    {
      "id": "cat_mobile",
      "name": "Mobile",
      "imageUrl": "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400"
    },
    {
      "id": "cat_furniture",
      "name": "Furniture",
      "imageUrl": "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400"
    },
    {
      "id": "cat_pets",
      "name": "Pets",
      "imageUrl": "https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=400"
    },
    {
      "id": "cat_fashion",
      "name": "Fashion",
      "imageUrl": "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400"
    }
  ]
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique category identifier |
| name | string | Yes | Category display name |
| imageUrl | string | No | URL of category image (optional, for featured categories) |

---

## 2. Get Subcategories API

### Endpoint
```
GET /api/categories/{categoryId}/subcategories
```

### Headers
```
Authorization: Bearer {jwtToken} (optional - works in guest mode)
```

### Path Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| categoryId | string | Yes | ID of the parent category |

### Request Example
```bash
GET /api/categories/cat_groom_collection/subcategories
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {
      "id": "sub_blazer",
      "name": "Blazer",
      "categoryId": "cat_groom_collection"
    }
  ]
}
```

### Mock Response Examples

#### Example 1: Groom Collection Subcategories
**Request:**
```
GET /api/categories/cat_groom_collection/subcategories
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {
      "id": "sub_blazer",
      "name": "Blazer",
      "categoryId": "cat_groom_collection"
    },
    {
      "id": "sub_suit",
      "name": "Suit",
      "categoryId": "cat_groom_collection"
    },
    {
      "id": "sub_shirt",
      "name": "Shirt",
      "categoryId": "cat_groom_collection"
    },
    {
      "id": "sub_tshirt",
      "name": "T-Shirt",
      "categoryId": "cat_groom_collection"
    },
    {
      "id": "sub_kurtu",
      "name": "Kurtu",
      "categoryId": "cat_groom_collection"
    },
    {
      "id": "sub_indowestern",
      "name": "Indo-Western",
      "categoryId": "cat_groom_collection"
    },
    {
      "id": "sub_jodhpuri",
      "name": "Jodhpuri",
      "categoryId": "cat_groom_collection"
    }
  ]
}
```

#### Example 2: Women Subcategories
**Request:**
```
GET /api/categories/cat_women/subcategories
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {
      "id": "sub_women_dress",
      "name": "Dress",
      "categoryId": "cat_women"
    },
    {
      "id": "sub_women_patiyala",
      "name": "Patiyala Dress",
      "categoryId": "cat_women"
    },
    {
      "id": "sub_women_sherara",
      "name": "Sherara Pair",
      "categoryId": "cat_women"
    },
    {
      "id": "sub_women_petticoat",
      "name": "Petticoat Dress",
      "categoryId": "cat_women"
    },
    {
      "id": "sub_women_kurti",
      "name": "Kurti",
      "categoryId": "cat_women"
    },
    {
      "id": "sub_women_tunic",
      "name": "Tunic",
      "categoryId": "cat_women"
    },
    {
      "id": "sub_women_churidar",
      "name": "Churidar Salwar",
      "categoryId": "cat_women"
    },
    {
      "id": "sub_women_anarkali",
      "name": "Anarkali Salwar Suit",
      "categoryId": "cat_women"
    },
    {
      "id": "sub_women_top",
      "name": "Top",
      "categoryId": "cat_women"
    },
    {
      "id": "sub_women_skirt",
      "name": "Skirt",
      "categoryId": "cat_women"
    },
    {
      "id": "sub_women_jeans",
      "name": "Jeans",
      "categoryId": "cat_women"
    }
  ]
}
```

#### Example 3: Empty Subcategories
**Request:**
```
GET /api/categories/cat_fashion/subcategories
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "data": []
}
```

### Field Descriptions

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique subcategory identifier |
| name | string | Yes | Subcategory display name |
| categoryId | string | Yes | ID of the parent category |

---

## 3. Get Products with Category/Subcategory Filter API

### Endpoint
```
GET /api/products
```

### Headers
```
Authorization: Bearer {jwtToken} (optional - works in guest mode)
```

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| type | string | Yes | Product type: `'rent'` or `'sell'` |
| page | number | No | Page number (default: 1) |
| per_page | number | No | Items per page (default: 10) |
| q | string | No | Search query |
| **categoryId** | string | No | **Filter by category ID** |
| **subcategoryId** | string | No | **Filter by subcategory ID** |
| gender | string | No | Filter by gender: `'men'`, `'women'`, `'unisex'` |
| minPrice | number | No | Minimum price filter |
| maxPrice | number | No | Maximum price filter |
| latitude | number | No | User's latitude for distance calculation |
| longitude | number | No | User's longitude for distance calculation |
| filters | object | No | Additional filters (JSON object) |
| interestedCategoryIds | array | No | User's interested categories (for personalization) |
| interestedActions | array | No | User's interested actions (for personalization) |

### Request Examples

#### Example 1: Filter by Category
```bash
GET /api/products?type=rent&page=1&per_page=10&categoryId=cat_groom_collection&latitude=19.0760&longitude=72.8777
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Example 2: Filter by Category and Subcategory
```bash
GET /api/products?type=rent&page=1&per_page=10&categoryId=cat_groom_collection&subcategoryId=sub_blazer&latitude=19.0760&longitude=72.8777
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Example 3: Filter by Category with Search
```bash
GET /api/products?type=sell&page=1&per_page=10&categoryId=cat_women&q=lehenga&latitude=19.0760&longitude=72.8777
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Format
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

### Mock Response Examples

#### Example 1: Products Filtered by Category (Groom Collection)
**Request:**
```
GET /api/products?type=rent&page=1&per_page=10&categoryId=cat_groom_collection&latitude=19.0760&longitude=72.8777
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
        "id": "product_0",
        "type": "rent",
        "title": "Product 1 - groom collection",
        "description": "This is a detailed description for product 1. It is in excellent condition and ready to use.",
        "price": 100,
        "deposit": 500,
        "categoryId": "cat_groom_collection",
        "subcategoryId": "sub_blazer",
        "imageUrls": [
          "https://picsum.photos/400/400?random=0",
          "https://picsum.photos/400/400?random=100"
        ],
        "location": "Location 1, City",
        "contactPhone": "+1234567890",
        "isContactShow": true,
        "gender": "men",
        "condition": "new",
        "size": "S",
        "color": "Red",
        "brand": "Brand 1",
        "sellerId": "seller_0",
        "sellerName": "Seller 1",
        "sellerImageUrl": "https://picsum.photos/200/200?random=200",
        "createdAt": "2024-01-15T10:30:00Z",
        "latitude": 19.0760,
        "longitude": 72.8777,
        "isWishlisted": false,
        "distance": 0.0
      },
      {
        "id": "product_6",
        "type": "rent",
        "title": "Product 7 - groom collection",
        "description": "This is a detailed description for product 7. It is in excellent condition and ready to use.",
        "price": 400,
        "deposit": 1100,
        "categoryId": "cat_groom_collection",
        "subcategoryId": "sub_suit",
        "imageUrls": [
          "https://picsum.photos/400/400?random=6",
          "https://picsum.photos/400/400?random=106"
        ],
        "location": "Location 7, City",
        "contactPhone": "+1234567896",
        "isContactShow": true,
        "gender": "men",
        "condition": "good",
        "size": "XL",
        "color": "Red",
        "brand": "Brand 1",
        "sellerId": "seller_6",
        "sellerName": "Seller 7",
        "sellerImageUrl": "https://picsum.photos/200/200?random=206",
        "createdAt": "2024-01-15T10:30:00Z",
        "latitude": 19.1360,
        "longitude": 72.9377,
        "isWishlisted": false,
        "distance": 3.0
      }
    ],
    "currentPage": 1,
    "totalPages": 1,
    "totalItems": 2,
    "perPage": 10,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```

#### Example 2: Products Filtered by Category and Subcategory
**Request:**
```
GET /api/products?type=rent&page=1&per_page=10&categoryId=cat_groom_collection&subcategoryId=sub_blazer&latitude=19.0760&longitude=72.8777
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
        "id": "product_0",
        "type": "rent",
        "title": "Product 1 - groom collection",
        "description": "This is a detailed description for product 1. It is in excellent condition and ready to use.",
        "price": 100,
        "deposit": 500,
        "categoryId": "cat_groom_collection",
        "subcategoryId": "sub_blazer",
        "imageUrls": [
          "https://picsum.photos/400/400?random=0",
          "https://picsum.photos/400/400?random=100"
        ],
        "location": "Location 1, City",
        "contactPhone": "+1234567890",
        "isContactShow": true,
        "gender": "men",
        "condition": "new",
        "size": "S",
        "color": "Red",
        "brand": "Brand 1",
        "sellerId": "seller_0",
        "sellerName": "Seller 1",
        "sellerImageUrl": "https://picsum.photos/200/200?random=200",
        "createdAt": "2024-01-15T10:30:00Z",
        "latitude": 19.0760,
        "longitude": 72.8777,
        "isWishlisted": false,
        "distance": 0.0
      }
    ],
    "currentPage": 1,
    "totalPages": 1,
    "totalItems": 1,
    "perPage": 10,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```

#### Example 3: Products Filtered by Women Category
**Request:**
```
GET /api/products?type=rent&page=1&per_page=10&categoryId=cat_women&latitude=19.0760&longitude=72.8777
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
        "id": "product_3",
        "type": "rent",
        "title": "Product 4 - women",
        "description": "This is a detailed description for product 4. It is in excellent condition and ready to use.",
        "price": 250,
        "deposit": 800,
        "categoryId": "cat_women",
        "subcategoryId": "sub_women_dress",
        "imageUrls": [
          "https://picsum.photos/400/400?random=3",
          "https://picsum.photos/400/400?random=103"
        ],
        "location": "Location 4, City",
        "contactPhone": "+1234567893",
        "isContactShow": true,
        "gender": "unisex",
        "condition": "fair",
        "size": "M",
        "color": "Black",
        "brand": "Brand 4",
        "sellerId": "seller_3",
        "sellerName": "Seller 4",
        "sellerImageUrl": "https://picsum.photos/200/200?random=203",
        "createdAt": "2024-01-15T10:30:00Z",
        "latitude": 19.1060,
        "longitude": 72.9077,
        "isWishlisted": false,
        "distance": 1.5
      }
    ],
    "currentPage": 1,
    "totalPages": 1,
    "totalItems": 1,
    "perPage": 10,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```

#### Example 4: No Products Found
**Request:**
```
GET /api/products?type=rent&page=1&per_page=10&categoryId=cat_nonexistent&latitude=19.0760&longitude=72.8777
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Products retrieved successfully",
  "data": {
    "products": [],
    "currentPage": 1,
    "totalPages": 1,
    "totalItems": 0,
    "perPage": 10,
    "hasNextPage": false,
    "hasPreviousPage": false
  }
}
```

---

## Request/Response Models

### CategoryModel
```json
{
  "id": "string",           // Unique category identifier
  "name": "string",         // Category display name
  "imageUrl": "string | null"  // Optional category image URL
}
```

### SubcategoryModel
```json
{
  "id": "string",           // Unique subcategory identifier
  "name": "string",         // Subcategory display name
  "categoryId": "string"    // Parent category ID
}
```

### ProductModel (with Category/Subcategory)
```json
{
  "id": "string",
  "type": "rent" | "sell",
  "title": "string",
  "description": "string",
  "price": number,
  "deposit": number | null,
  "categoryId": "string",      // Category ID (required)
  "subcategoryId": "string",   // Subcategory ID (required)
  "imageUrls": ["string"],
  "location": "string",
  "contactPhone": "string",
  "isContactShow": boolean,
  "gender": "men" | "women" | "unisex",
  "condition": "new" | "like_new" | "good" | "fair",
  "size": "string",
  "color": "string",
  "brand": "string",
  "sellerId": "string",
  "sellerName": "string",
  "sellerImageUrl": "string",
  "createdAt": "string",
  "latitude": number,
  "longitude": number,
  "isWishlisted": boolean,
  "distance": number
}
```

---

## API Changes Summary

### 1. Category API Changes

#### Added Field to Category Model
- **`imageUrl`** (optional): URL of category image for featured display

**Before:**
```json
{
  "id": "cat_men",
  "name": "men"
}
```

**After:**
```json
{
  "id": "cat_men",
  "name": "Men",
  "imageUrl": "https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400"
}
```

### 2. Products API Changes

#### Added Query Parameters
- **`categoryId`** (optional): Filter products by category ID
- **`subcategoryId`** (optional): Filter products by subcategory ID

**Before:**
```
GET /api/products?type=rent&page=1&per_page=10&latitude=19.0760&longitude=72.8777
```

**After:**
```
GET /api/products?type=rent&page=1&per_page=10&categoryId=cat_groom_collection&subcategoryId=sub_blazer&latitude=19.0760&longitude=72.8777
```

#### Filtering Logic
1. If `categoryId` is provided, return only products matching that category
2. If both `categoryId` and `subcategoryId` are provided, return products matching both
3. If only `subcategoryId` is provided (without `categoryId`), return products matching that subcategory (subcategory already contains categoryId)
4. If neither is provided, return all products (existing behavior)

### 3. Response Format
The response format remains the same, but products will be filtered based on the provided `categoryId` and/or `subcategoryId` parameters.

---

## Implementation Notes

1. **Category Images**: Categories with `imageUrl` are displayed as featured cards in a horizontal scrollable section. Categories without images are shown in a vertical list.

2. **Subcategory Loading**: Subcategories are loaded on-demand when a category is expanded. This improves initial load performance.

3. **Product Filtering**: 
   - When a category is selected, products are filtered by `categoryId`
   - When a subcategory is selected, products are filtered by both `categoryId` and `subcategoryId`
   - Products maintain all existing filters (type, search, price, gender, etc.)

4. **Type Toggle**: Users can switch between "Rent" and "Sell" types when viewing products, which updates the `type` parameter in the API call.

5. **Pagination**: Product filtering supports pagination. The `hasNextPage` field indicates if more products are available.

6. **Location**: Products are filtered by user's location (latitude/longitude) for distance calculation, even when filtering by category.

7. **Personalization**: If the user is logged in and has interested categories/actions, products in those categories are prioritized in the results.

8. **Empty States**: When no products match the category/subcategory filter, an empty state is shown with a message.

---

## Error Handling

### HTTP Status Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 400 | Bad Request (invalid parameters) |
| 401 | Unauthorized (invalid or missing JWT token) |
| 404 | Not Found (category/subcategory not found) |
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

### Error Examples

#### Error 1: Category Not Found
**Request:**
```
GET /api/categories/cat_nonexistent/subcategories
```

**Response:**
```json
{
  "success": false,
  "statusCode": 404,
  "message": "Category not found",
  "data": null
}
```

#### Error 2: Invalid Category ID in Products Filter
**Request:**
```
GET /api/products?type=rent&categoryId=invalid_category
```

**Response:**
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Invalid category ID",
  "data": null
}
```

---

## Usage Flow

1. **Load Categories**: User opens Category screen → `GET /api/categories`
2. **Expand Category**: User taps on a category → `GET /api/categories/{categoryId}/subcategories`
3. **Select Category**: User selects a category → `GET /api/products?categoryId={categoryId}&type={type}`
4. **Select Subcategory**: User selects a subcategory → `GET /api/products?categoryId={categoryId}&subcategoryId={subcategoryId}&type={type}`
5. **View Product**: User taps on a product → Navigate to Product Detail screen (existing implementation)
6. **Contact Seller**: User taps Contact button → Show seller contact details (existing implementation)

---

## Testing Checklist

- [ ] Load categories with images
- [ ] Expand/collapse categories to show subcategories
- [ ] Select category and view filtered products
- [ ] Select subcategory and view filtered products
- [ ] Switch between Rent and Sell types
- [ ] Pagination works with category/subcategory filters
- [ ] Search works with category/subcategory filters
- [ ] Empty state shown when no products match
- [ ] Error handling for invalid category/subcategory IDs
- [ ] Product detail navigation works
- [ ] Contact button functionality works
- [ ] Wishlist toggle works on product cards


