# Notification API Documentation

This document describes all the APIs used for Notification functionality in the app.

## Table of Contents
1. [Get Notifications List API](#1-get-notifications-list-api)
2. [Mark Notification as Read API](#2-mark-notification-as-read-api)
3. [Mark All Notifications as Read API](#3-mark-all-notifications-as-read-api)
4. [Delete Notification API](#4-delete-notification-api)
5. [Request/Response Models](#requestresponse-models)
6. [Notification Types](#notification-types)
7. [Error Handling](#error-handling)

---

## 1. Get Notifications List API

### Endpoint
```
GET /api/notifications
```

### Headers
```
Authorization: Bearer {jwtToken} (optional - works in guest mode)
```

### Query Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | number | No | Page number (default: 1) |
| per_page | number | No | Items per page (default: 20) |
| type | string | No | Filter by notification type: `'app_update'`, `'category_added'`, `'product_added'`, `'offer'`, `'general'`, `'order'` |
| isRead | boolean | No | Filter by read status: `true` or `false` |

### Request Example
```bash
GET /api/notifications?page=1&per_page=20&type=product_added
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [
      {
        "id": "notif_1",
        "type": "app_update",
        "title": "App Update Available",
        "message": "A new version of the app is available. Update now to enjoy new features and improvements!",
        "imageUrl": "https://via.placeholder.com/150/4CAF50/FFFFFF?text=Update",
        "actionType": "app_update",
        "actionId": null,
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-15T08:30:00.000Z",
        "metadata": {
          "version": "2.0.0",
          "updateUrl": "https://play.google.com/store/apps/details?id=com.rentnsell"
        }
      }
    ],
    "unreadCount": 5,
    "totalCount": 8,
    "currentPage": 1,
    "totalPages": 1,
    "hasNextPage": false
  }
}
```

### Mock Response Examples

#### Example 1: Get All Notifications
**Request:**
```
GET /api/notifications
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [
      {
        "id": "notif_1",
        "type": "app_update",
        "title": "App Update Available",
        "message": "A new version of the app is available. Update now to enjoy new features and improvements!",
        "imageUrl": "https://via.placeholder.com/150/4CAF50/FFFFFF?text=Update",
        "actionType": "app_update",
        "actionId": null,
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-15T08:30:00.000Z",
        "metadata": {
          "version": "2.0.0",
          "updateUrl": "https://play.google.com/store/apps/details?id=com.rentnsell"
        }
      },
      {
        "id": "notif_2",
        "type": "category_added",
        "title": "New Category Added",
        "message": "Check out our new \"Wedding Accessories\" category with amazing products!",
        "imageUrl": "https://via.placeholder.com/150/FF9800/FFFFFF?text=Category",
        "actionType": "category",
        "actionId": "cat_wedding_accessories",
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-15T05:30:00.000Z",
        "metadata": {
          "categoryName": "Wedding Accessories",
          "categoryId": "cat_wedding_accessories"
        }
      },
      {
        "id": "notif_3",
        "type": "product_added",
        "title": "New Product Available for Rent",
        "message": "A new designer lehenga is now available for rent in your area!",
        "imageUrl": "https://via.placeholder.com/150/E91E63/FFFFFF?text=Product",
        "actionType": "product",
        "actionId": "product_new_lehenga",
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-15T02:30:00.000Z",
        "metadata": {
          "productId": "product_new_lehenga",
          "productType": "rent",
          "productTitle": "Designer Lehenga"
        }
      },
      {
        "id": "notif_4",
        "type": "product_added",
        "title": "New Product Available for Sale",
        "message": "Check out this amazing groom blazer now available for sale!",
        "imageUrl": "https://via.placeholder.com/150/2196F3/FFFFFF?text=Sale",
        "actionType": "product",
        "actionId": "product_new_blazer",
        "actionUrl": null,
        "isRead": true,
        "createdAt": "2024-01-14T10:30:00.000Z",
        "metadata": {
          "productId": "product_new_blazer",
          "productType": "sell",
          "productTitle": "Groom Blazer"
        }
      },
      {
        "id": "notif_5",
        "type": "offer",
        "title": "Special Offer",
        "message": "Get 20% off on all rental items this weekend! Use code WEEKEND20",
        "imageUrl": "https://via.placeholder.com/150/9C27B0/FFFFFF?text=Offer",
        "actionType": "url",
        "actionId": null,
        "actionUrl": "/offers/weekend-sale",
        "isRead": false,
        "createdAt": "2024-01-13T10:30:00.000Z",
        "metadata": {
          "offerCode": "WEEKEND20",
          "discount": 20,
          "validUntil": "2024-01-20T23:59:59Z"
        }
      },
      {
        "id": "notif_6",
        "type": "general",
        "title": "Welcome to Rent N Sell!",
        "message": "Thank you for joining us. Start exploring amazing products for rent and sale!",
        "imageUrl": "https://via.placeholder.com/150/00BCD4/FFFFFF?text=Welcome",
        "actionType": null,
        "actionId": null,
        "actionUrl": null,
        "isRead": true,
        "createdAt": "2024-01-12T10:30:00.000Z",
        "metadata": null
      },
      {
        "id": "notif_7",
        "type": "category_added",
        "title": "New Category: Electronics",
        "message": "We've added a new Electronics category. Browse through amazing gadgets!",
        "imageUrl": "https://via.placeholder.com/150/607D8B/FFFFFF?text=Electronics",
        "actionType": "category",
        "actionId": "cat_electronics",
        "actionUrl": null,
        "isRead": true,
        "createdAt": "2024-01-11T10:30:00.000Z",
        "metadata": {
          "categoryName": "Electronics",
          "categoryId": "cat_electronics"
        }
      },
      {
        "id": "notif_8",
        "type": "product_added",
        "title": "New Rental Product Near You",
        "message": "A luxury car is now available for rent just 2km away from your location!",
        "imageUrl": "https://via.placeholder.com/150/FF5722/FFFFFF?text=Car",
        "actionType": "product",
        "actionId": "product_luxury_car",
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-10T10:30:00.000Z",
        "metadata": {
          "productId": "product_luxury_car",
          "productType": "rent",
          "productTitle": "Luxury Car",
          "distance": 2.0
        }
      }
    ],
    "unreadCount": 5,
    "totalCount": 8,
    "currentPage": 1,
    "totalPages": 1,
    "hasNextPage": false
  }
}
```

#### Example 2: Filter by Type (Product Added)
**Request:**
```
GET /api/notifications?type=product_added
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [
      {
        "id": "notif_3",
        "type": "product_added",
        "title": "New Product Available for Rent",
        "message": "A new designer lehenga is now available for rent in your area!",
        "imageUrl": "https://via.placeholder.com/150/E91E63/FFFFFF?text=Product",
        "actionType": "product",
        "actionId": "product_new_lehenga",
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-15T02:30:00.000Z",
        "metadata": {
          "productId": "product_new_lehenga",
          "productType": "rent",
          "productTitle": "Designer Lehenga"
        }
      },
      {
        "id": "notif_4",
        "type": "product_added",
        "title": "New Product Available for Sale",
        "message": "Check out this amazing groom blazer now available for sale!",
        "imageUrl": "https://via.placeholder.com/150/2196F3/FFFFFF?text=Sale",
        "actionType": "product",
        "actionId": "product_new_blazer",
        "actionUrl": null,
        "isRead": true,
        "createdAt": "2024-01-14T10:30:00.000Z",
        "metadata": {
          "productId": "product_new_blazer",
          "productType": "sell",
          "productTitle": "Groom Blazer"
        }
      },
      {
        "id": "notif_8",
        "type": "product_added",
        "title": "New Rental Product Near You",
        "message": "A luxury car is now available for rent just 2km away from your location!",
        "imageUrl": "https://via.placeholder.com/150/FF5722/FFFFFF?text=Car",
        "actionType": "product",
        "actionId": "product_luxury_car",
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-10T10:30:00.000Z",
        "metadata": {
          "productId": "product_luxury_car",
          "productType": "rent",
          "productTitle": "Luxury Car",
          "distance": 2.0
        }
      }
    ],
    "unreadCount": 2,
    "totalCount": 3,
    "currentPage": 1,
    "totalPages": 1,
    "hasNextPage": false
  }
}
```

#### Example 3: Filter by Unread Status
**Request:**
```
GET /api/notifications?isRead=false
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [
      {
        "id": "notif_1",
        "type": "app_update",
        "title": "App Update Available",
        "message": "A new version of the app is available. Update now to enjoy new features and improvements!",
        "imageUrl": "https://via.placeholder.com/150/4CAF50/FFFFFF?text=Update",
        "actionType": "app_update",
        "actionId": null,
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-15T08:30:00.000Z",
        "metadata": {
          "version": "2.0.0",
          "updateUrl": "https://play.google.com/store/apps/details?id=com.rentnsell"
        }
      },
      {
        "id": "notif_2",
        "type": "category_added",
        "title": "New Category Added",
        "message": "Check out our new \"Wedding Accessories\" category with amazing products!",
        "imageUrl": "https://via.placeholder.com/150/FF9800/FFFFFF?text=Category",
        "actionType": "category",
        "actionId": "cat_wedding_accessories",
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-15T05:30:00.000Z",
        "metadata": {
          "categoryName": "Wedding Accessories",
          "categoryId": "cat_wedding_accessories"
        }
      },
      {
        "id": "notif_3",
        "type": "product_added",
        "title": "New Product Available for Rent",
        "message": "A new designer lehenga is now available for rent in your area!",
        "imageUrl": "https://via.placeholder.com/150/E91E63/FFFFFF?text=Product",
        "actionType": "product",
        "actionId": "product_new_lehenga",
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-15T02:30:00.000Z",
        "metadata": {
          "productId": "product_new_lehenga",
          "productType": "rent",
          "productTitle": "Designer Lehenga"
        }
      },
      {
        "id": "notif_5",
        "type": "offer",
        "title": "Special Offer",
        "message": "Get 20% off on all rental items this weekend! Use code WEEKEND20",
        "imageUrl": "https://via.placeholder.com/150/9C27B0/FFFFFF?text=Offer",
        "actionType": "url",
        "actionId": null,
        "actionUrl": "/offers/weekend-sale",
        "isRead": false,
        "createdAt": "2024-01-13T10:30:00.000Z",
        "metadata": {
          "offerCode": "WEEKEND20",
          "discount": 20,
          "validUntil": "2024-01-20T23:59:59Z"
        }
      },
      {
        "id": "notif_8",
        "type": "product_added",
        "title": "New Rental Product Near You",
        "message": "A luxury car is now available for rent just 2km away from your location!",
        "imageUrl": "https://via.placeholder.com/150/FF5722/FFFFFF?text=Car",
        "actionType": "product",
        "actionId": "product_luxury_car",
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-10T10:30:00.000Z",
        "metadata": {
          "productId": "product_luxury_car",
          "productType": "rent",
          "productTitle": "Luxury Car",
          "distance": 2.0
        }
      }
    ],
    "unreadCount": 5,
    "totalCount": 5,
    "currentPage": 1,
    "totalPages": 1,
    "hasNextPage": false
  }
}
```

#### Example 4: Filter by Category Added
**Request:**
```
GET /api/notifications?type=category_added
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [
      {
        "id": "notif_2",
        "type": "category_added",
        "title": "New Category Added",
        "message": "Check out our new \"Wedding Accessories\" category with amazing products!",
        "imageUrl": "https://via.placeholder.com/150/FF9800/FFFFFF?text=Category",
        "actionType": "category",
        "actionId": "cat_wedding_accessories",
        "actionUrl": null,
        "isRead": false,
        "createdAt": "2024-01-15T05:30:00.000Z",
        "metadata": {
          "categoryName": "Wedding Accessories",
          "categoryId": "cat_wedding_accessories"
        }
      },
      {
        "id": "notif_7",
        "type": "category_added",
        "title": "New Category: Electronics",
        "message": "We've added a new Electronics category. Browse through amazing gadgets!",
        "imageUrl": "https://via.placeholder.com/150/607D8B/FFFFFF?text=Electronics",
        "actionType": "category",
        "actionId": "cat_electronics",
        "actionUrl": null,
        "isRead": true,
        "createdAt": "2024-01-11T10:30:00.000Z",
        "metadata": {
          "categoryName": "Electronics",
          "categoryId": "cat_electronics"
        }
      }
    ],
    "unreadCount": 1,
    "totalCount": 2,
    "currentPage": 1,
    "totalPages": 1,
    "hasNextPage": false
  }
}
```

#### Example 5: Empty Notifications
**Request:**
```
GET /api/notifications
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [],
    "unreadCount": 0,
    "totalCount": 0,
    "currentPage": 1,
    "totalPages": 1,
    "hasNextPage": false
  }
}
```

---

## 2. Mark Notification as Read API

### Endpoint
```
PUT /api/notifications/{notificationId}/read
```

### Headers
```
Authorization: Bearer {jwtToken} (optional)
```

### Path Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| notificationId | string | Yes | ID of the notification to mark as read |

### Request Example
```bash
PUT /api/notifications/notif_1/read
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Notification marked as read",
  "data": {
    "notificationId": "notif_1",
    "isRead": true
  }
}
```

### Mock Response Example
**Request:**
```
PUT /api/notifications/notif_1/read
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Notification marked as read",
  "data": {
    "notificationId": "notif_1",
    "isRead": true
  }
}
```

---

## 3. Mark All Notifications as Read API

### Endpoint
```
PUT /api/notifications/read-all
```

### Headers
```
Authorization: Bearer {jwtToken} (optional)
```

### Request Example
```bash
PUT /api/notifications/read-all
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "message": "All notifications marked as read",
  "data": {
    "markedCount": 5
  }
}
```

### Mock Response Example
**Request:**
```
PUT /api/notifications/read-all
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "All notifications marked as read",
  "data": {
    "markedCount": 5
  }
}
```

---

## 4. Delete Notification API

### Endpoint
```
DELETE /api/notifications/{notificationId}
```

### Headers
```
Authorization: Bearer {jwtToken} (optional)
```

### Path Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| notificationId | string | Yes | ID of the notification to delete |

### Request Example
```bash
DELETE /api/notifications/notif_1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Response Format
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Notification deleted successfully",
  "data": {
    "notificationId": "notif_1"
  }
}
```

### Mock Response Example
**Request:**
```
DELETE /api/notifications/notif_1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Notification deleted successfully",
  "data": {
    "notificationId": "notif_1"
  }
}
```

---

## Request/Response Models

### NotificationModel
```json
{
  "id": "string",                    // Unique notification identifier
  "type": "string",                  // Notification type (see Notification Types below)
  "title": "string",                 // Notification title
  "message": "string",               // Notification message/body
  "imageUrl": "string | null",      // Optional image URL
  "actionType": "string | null",    // Action type: 'product', 'category', 'app_update', 'url', null
  "actionId": "string | null",      // ID for action (productId, categoryId, etc.)
  "actionUrl": "string | null",     // Custom URL for navigation
  "isRead": boolean,                 // Read status
  "createdAt": "string",            // ISO 8601 timestamp
  "metadata": {                      // Additional data (optional)
    // Varies by notification type
  }
}
```

### NotificationListResponseModel
```json
{
  "success": boolean,
  "statusCode": number,
  "message": "string",
  "data": {
    "notifications": [NotificationModel],
    "unreadCount": number,
    "totalCount": number,
    "currentPage": number,
    "totalPages": number,
    "hasNextPage": boolean
  }
}
```

---

## Notification Types

### 1. App Update (`app_update`)
- **Purpose**: Notify users about app updates
- **Action Type**: `app_update`
- **Metadata**: 
  ```json
  {
    "version": "2.0.0",
    "updateUrl": "https://play.google.com/store/apps/details?id=com.rentnsell"
  }
  ```

### 2. Category Added (`category_added`)
- **Purpose**: Notify users about new categories
- **Action Type**: `category`
- **Action ID**: Category ID
- **Metadata**:
  ```json
  {
    "categoryName": "Wedding Accessories",
    "categoryId": "cat_wedding_accessories"
  }
  ```

### 3. Product Added (`product_added`)
- **Purpose**: Notify users about new products available for rent or sale
- **Action Type**: `product`
- **Action ID**: Product ID
- **Metadata**:
  ```json
  {
    "productId": "product_new_lehenga",
    "productType": "rent" | "sell",
    "productTitle": "Designer Lehenga",
    "distance": 2.0  // Optional: distance in km
  }
  ```

### 4. Offer (`offer`)
- **Purpose**: Notify users about special offers and discounts
- **Action Type**: `url`
- **Action URL**: Offer page URL
- **Metadata**:
  ```json
  {
    "offerCode": "WEEKEND20",
    "discount": 20,
    "validUntil": "2024-01-20T23:59:59Z"
  }
  ```

### 5. General (`general`)
- **Purpose**: General notifications (welcome messages, announcements, etc.)
- **Action Type**: `null`
- **Metadata**: `null` or custom data

### 6. Order (`order`)
- **Purpose**: Notify users about order updates (if order functionality exists)
- **Action Type**: `order` or `url`
- **Action ID**: Order ID
- **Metadata**: Order details

---

## Error Handling

### HTTP Status Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 400 | Bad Request (invalid parameters) |
| 401 | Unauthorized (invalid or missing JWT token) |
| 404 | Not Found (notification not found) |
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

#### Error 1: Notification Not Found
**Request:**
```
PUT /api/notifications/notif_nonexistent/read
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": false,
  "statusCode": 404,
  "message": "Notification not found",
  "data": null
}
```

#### Error 2: Invalid Notification Type
**Request:**
```
GET /api/notifications?type=invalid_type
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Invalid notification type",
  "data": null
}
```

---

## Implementation Notes

1. **Authentication**: All notification APIs work in guest mode (JWT token is optional). However, read/unread status and user-specific notifications require authentication.

2. **Pagination**: The notifications list API supports pagination with `page` and `per_page` parameters.

3. **Filtering**: Notifications can be filtered by:
   - Type (app_update, category_added, product_added, offer, general, order)
   - Read status (isRead: true/false)

4. **Sorting**: Notifications are sorted by `createdAt` in descending order (newest first).

5. **Action Handling**: When a notification is tapped:
   - If `actionType` is `product` and `actionId` is provided, navigate to Product Detail screen
   - If `actionType` is `category` and `actionId` is provided, navigate to Category screen
   - If `actionType` is `app_update`, show app update dialog or open app store
   - If `actionUrl` is provided, navigate to the URL
   - Otherwise, just mark as read

6. **Read Status**: Notifications are automatically marked as read when tapped.

7. **Unread Count**: The API returns the total unread count in the response, which is used to show badge on notification icon.

8. **Response Time**: Mock API simulates network delay with 300-600ms delay.

9. **Metadata**: The `metadata` field contains type-specific additional data that can be used for custom handling.

---

## Usage Examples

### Get All Notifications
```dart
// Request
GET /api/notifications
Authorization: Bearer {jwtToken}

// Response
{
  "success": true,
  "statusCode": 200,
  "message": "Notifications retrieved successfully",
  "data": {
    "notifications": [...],
    "unreadCount": 5,
    "totalCount": 8,
    "currentPage": 1,
    "totalPages": 1,
    "hasNextPage": false
  }
}
```

### Mark Notification as Read
```dart
// Request
PUT /api/notifications/notif_1/read
Authorization: Bearer {jwtToken}

// Response
{
  "success": true,
  "statusCode": 200,
  "message": "Notification marked as read",
  "data": {
    "notificationId": "notif_1",
    "isRead": true
  }
}
```

### Mark All as Read
```dart
// Request
PUT /api/notifications/read-all
Authorization: Bearer {jwtToken}

// Response
{
  "success": true,
  "statusCode": 200,
  "message": "All notifications marked as read",
  "data": {
    "markedCount": 5
  }
}
```

### Delete Notification
```dart
// Request
DELETE /api/notifications/notif_1
Authorization: Bearer {jwtToken}

// Response
{
  "success": true,
  "statusCode": 200,
  "message": "Notification deleted successfully",
  "data": {
    "notificationId": "notif_1"
  }
}
```

---

## Mock Data

The mock API service includes 8 sample notifications:

1. **App Update** - New version available
2. **Category Added** - Wedding Accessories category
3. **Product Added (Rent)** - Designer Lehenga for rent
4. **Product Added (Sell)** - Groom Blazer for sale
5. **Offer** - Weekend sale with discount code
6. **General** - Welcome message
7. **Category Added** - Electronics category
8. **Product Added (Rent)** - Luxury Car rental near user

All notifications include timestamps, images, and metadata for realistic testing.


