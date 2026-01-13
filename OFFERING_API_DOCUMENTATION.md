# Offering API Documentation

This document describes the Offering APIs used in the application.

## 1. GET Subcategories API

### Endpoint
```
GET /api/categories/{categoryId}/subcategories
```

### Headers
```
Authorization: Bearer {jwtToken}
Content-Type: application/json
```

### Description
Retrieves subcategories for a selected category. Requires JWT token in the Authorization header.

### Request Parameters
- `categoryId` (path parameter): The ID of the selected category (e.g., "cat_groom_collection")

### Response

#### Success Response (200 OK)
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

#### Example for Different Categories

**For "cat_bride_collection":**
```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {"id": "sub_lehenga", "name": "Lehenga", "categoryId": "cat_bride_collection"},
    {"id": "sub_saree", "name": "Saree", "categoryId": "cat_bride_collection"},
    {"id": "sub_gown", "name": "Gown", "categoryId": "cat_bride_collection"},
    {"id": "sub_anarkali", "name": "Anarkali", "categoryId": "cat_bride_collection"}
  ]
}
```

**For "cat_car":**
```json
{
  "success": true,
  "statusCode": 200,
  "data": [
    {"id": "sub_sedan", "name": "Sedan", "categoryId": "cat_car"},
    {"id": "sub_suv", "name": "SUV", "categoryId": "cat_car"},
    {"id": "sub_hatchback", "name": "Hatchback", "categoryId": "cat_car"},
    {"id": "sub_luxury", "name": "Luxury", "categoryId": "cat_car"}
  ]
}
```

---

## 2. CREATE Offering API

### Endpoint
```
POST /api/offerings
```

### Headers
```
Authorization: Bearer {jwtToken}
Content-Type: application/json
```

### Description
Creates a new offering (sell or rental item). Requires JWT token in the Authorization header.

### Request Body

#### For Sell Type
```json
{
  "type": "sell",
  "categoryId": "cat_groom_collection",
  "subcategoryId": "sub_blazer",
  "images": [
    "iVBORw0KGgoAAAANSUhEUgAA... (base64 encoded image 1)",
    "iVBORw0KGgoAAAANSUhEUgAA... (base64 encoded image 2)",
    "iVBORw0KGgoAAAANSUhEUgAA... (base64 encoded image 3)"
  ],
  "imageNames": [
    "IMG_20240101_123456.jpg",
    "IMG_20240101_123457.jpg",
    "IMG_20240101_123458.jpg"
  ],
  "imageTypes": [
    "image/jpeg",
    "image/jpeg",
    "image/jpeg"
  ],
  "title": "Premium Blazer for Groom",
  "description": "Beautiful designer blazer in excellent condition. Perfect for wedding occasions.",
  "price": 5000.00,
  "gender": "men",
  "condition": "like_new",
  "size": "L",
  "color": "Navy Blue",
  "brand": "Designer Brand",
  "location": "Mumbai, Maharashtra",
  "contactPhone": "+919876543210"
}
```

#### For Rental Type
```json
{
  "type": "rental",
  "categoryId": "cat_groom_collection",
  "subcategoryId": "sub_suit",
  "images": [
    "iVBORw0KGgoAAAANSUhEUgAA... (base64 encoded image 1)",
    "iVBORw0KGgoAAAANSUhEUgAA... (base64 encoded image 2)"
  ],
  "imageNames": [
    "IMG_20240101_123456.jpg",
    "IMG_20240101_123457.jpg"
  ],
  "imageTypes": [
    "image/jpeg",
    "image/jpeg"
  ],
  "title": "Designer Suit for Rent",
  "description": "Elegant designer suit available for rent. Perfect for special occasions.",
  "price": 500.00,
  "deposit": 2000.00,
  "gender": "men",
  "condition": "good",
  "size": "M",
  "color": "Black",
  "brand": "Premium Brand",
  "location": "Delhi, NCR",
  "contactPhone": "+919876543210"
}
```

### Request Model Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | String | Yes | "sell" or "rental" |
| `categoryId` | String | Yes | Selected category ID |
| `subcategoryId` | String | Yes | Selected subcategory ID |
| `images` | Array[String] | Yes | Array of base64 encoded images |
| `imageNames` | Array[String] | Yes | Array of image file names |
| `imageTypes` | Array[String] | Yes | Array of image MIME types |
| `title` | String | Yes | Item title |
| `description` | String | Yes | Item description |
| `price` | Number | Yes | Price (for sell) or rent per day (for rental) |
| `deposit` | Number | Optional | Deposit amount (for rental only) |
| `gender` | String | Yes | "men", "women", or "unisex" |
| `condition` | String | Optional | "new", "like_new", "good", or "fair" |
| `size` | String | Optional | Item size (e.g., "M", "L", "XL") |
| `color` | String | Optional | Item color |
| `brand` | String | Optional | Brand name |
| `location` | String | Optional | Location/address |
| `contactPhone` | String | Optional | Contact phone number |

### Response

#### Success Response (201 Created)
```json
{
  "success": true,
  "statusCode": 201,
  "message": "Offering created successfully",
  "data": {
    "offeringId": "offering_1704067200000",
    "type": "sell",
    "title": "Premium Blazer for Groom",
    "imageUrls": [
      "https://api.example.com/offerings/images/offering_1704067200000_0.jpg",
      "https://api.example.com/offerings/images/offering_1704067200000_1.jpg",
      "https://api.example.com/offerings/images/offering_1704067200000_2.jpg"
    ],
    "createdAt": "2024-01-01T12:00:00.000Z"
  }
}
```

#### Error Response (400 Bad Request)
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Invalid request. Please check your input.",
  "data": null
}
```

#### Error Response (401 Unauthorized)
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Unauthorized. Please login.",
  "data": null
}
```

---

## 3. Mock API Implementation Details

### Mock Subcategory Service
- **File**: `lib/services/mock_subcategory_service.dart`
- **Method**: `getSubcategories(String categoryId)`
- **Returns**: `Future<List<SubcategoryModel>>`
- **Delay**: 500ms (simulated network delay)

### Mock Offering API Service
- **File**: `lib/services/mock_offering_api_service.dart`
- **Method**: `createOffering({required String jwtToken, required OfferingCreateRequestModel request})`
- **Returns**: `Future<OfferingCreateResponseModel>`
- **Delay**: 2 seconds (simulated network delay)

---

## 4. Models

### SubcategoryModel
```dart
class SubcategoryModel {
  final String id;
  final String name;
  final String categoryId;
}
```

### OfferingCreateRequestModel
```dart
class OfferingCreateRequestModel {
  final String type;
  final String categoryId;
  final String subcategoryId;
  final List<String> imageBase64List;
  final List<String> imageNameList;
  final List<String> imageTypeList;
  final String title;
  final String description;
  final double price;
  final double? deposit;
  final String gender;
  final String? condition;
  final String? size;
  final String? color;
  final String? brand;
  final String? location;
  final String? contactPhone;
}
```

### OfferingCreateResponseModel
```dart
class OfferingCreateResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final OfferingCreateResponseData? data;
}

class OfferingCreateResponseData {
  final String offeringId;
  final String type;
  final String title;
  final List<String> imageUrls;
  final DateTime createdAt;
}
```

---

## 5. Image Handling

### Image Upload Process
1. User selects multiple images from gallery or camera
2. Images are compressed (quality: 80%, max dimensions: 1200x1200)
3. Images are converted to Base64 encoding
4. Base64 strings, file names, and MIME types are sent in the request
5. Server processes images and returns URLs

### Supported Image Formats
- JPEG (.jpg, .jpeg)
- PNG (.png)
- GIF (.gif)

### Image Limits
- Maximum dimensions: 1200x1200 pixels
- Quality: 80%
- Multiple images supported (array)

---

## 6. Validation Rules

### Required Fields
- `type`: Must be "sell" or "rental"
- `categoryId`: Must be a valid category ID
- `subcategoryId`: Must be a valid subcategory ID for the selected category
- `images`: At least one image required
- `title`: Non-empty string
- `description`: Non-empty string
- `price`: Valid positive number
- `gender`: Must be "men", "women", or "unisex"

### Optional Fields
- `deposit`: Required only for rental type, must be positive number if provided
- `condition`: "new", "like_new", "good", or "fair"
- `size`: Free text
- `color`: Free text
- `brand`: Free text
- `location`: Free text
- `contactPhone`: Phone number format

### Form Validation
- Submit button is disabled until all required fields are valid
- Price must be a valid positive number
- Deposit (for rental) must be a valid positive number if provided
- At least one image must be selected

---

## 7. UI Flow

1. **Type Selection**: User selects "Sell" or "Rent" (preselected based on navigation)
2. **Category Selection**: User selects a category from available categories
3. **Subcategory Selection**: Subcategories load based on selected category
4. **Image Upload**: User uploads multiple images from gallery or camera
5. **Form Filling**: User fills in all required and optional fields
6. **Validation**: Form validates all inputs
7. **Submission**: User taps "Post for Sell" or "Post for Rent" button
8. **API Call**: Request is sent with JWT token in header
9. **Success**: Success toast shown, user navigated back
10. **Error**: Error toast shown with appropriate message

---

## 8. Error Handling

### Common Errors
- **401 Unauthorized**: User not logged in or invalid JWT token
- **400 Bad Request**: Invalid request data or missing required fields
- **500 Internal Server Error**: Server error during processing

### Error Messages
- All errors are displayed using toast notifications
- User-friendly error messages are shown
- Technical errors are logged for debugging

---

## 9. Notes

- JWT token is automatically retrieved from local storage
- Images are compressed before Base64 encoding to reduce payload size
- Multiple images are supported (array format)
- Deposit field is only relevant for rental type
- All optional fields can be omitted from the request
- Response includes server URLs for uploaded images

