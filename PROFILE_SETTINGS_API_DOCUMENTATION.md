# Profile Settings API Documentation

This document describes the APIs used in the Profile Settings feature, including logout and delete account functionality.

---

## Table of Contents

1. [Logout API](#logout-api)
2. [Delete Account API](#delete-account-api)
3. [Profile Update API](#profile-update-api) (Reference)
4. [Profile Get API](#profile-get-api) (Reference)

---

## Logout API

### Endpoint
```
POST /api/auth/logout
```

### Description
Logs out the current user and invalidates the JWT token.

### Headers
```
Authorization: Bearer {jwtToken}
Content-Type: application/json
```

### Request Body
No request body required. The JWT token is sent in the Authorization header.

### Response

#### Success Response (200 OK)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Logged out successfully"
}
```

#### Error Response (401 Unauthorized)
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Invalid token"
}
```

#### Error Response (500 Internal Server Error)
```json
{
  "success": false,
  "statusCode": 500,
  "message": "Internal server error"
}
```

### Example Request
```http
POST /api/auth/logout HTTP/1.1
Host: api.rentnsell.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

### Example Response
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Logged out successfully"
}
```

### Implementation Notes
- After successful logout, the client should:
  1. Clear JWT token from local storage
  2. Clear refresh token from local storage
  3. Clear FCM token from local storage
  4. Set `isLoggedIn` flag to `false`
  5. Clear AuthController state
  6. Navigate to login screen

### Mock Implementation
The mock API service (`MockAuthApiService`) simulates a network delay of 800ms and returns a successful response if a valid JWT token is provided.

---

## Delete Account API

### Endpoint
```
DELETE /api/auth/account
```

### Description
Permanently deletes the user's account and all associated data.

### Headers
```
Authorization: Bearer {jwtToken}
Content-Type: application/json
```

### Request Body
No request body required. The JWT token is sent in the Authorization header.

### Response

#### Success Response (200 OK)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Account deleted successfully"
}
```

#### Error Response (401 Unauthorized)
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Invalid token"
}
```

#### Error Response (403 Forbidden)
```json
{
  "success": false,
  "statusCode": 403,
  "message": "Account deletion not allowed"
}
```

#### Error Response (500 Internal Server Error)
```json
{
  "success": false,
  "statusCode": 500,
  "message": "Failed to delete account"
}
```

### Example Request
```http
DELETE /api/auth/account HTTP/1.1
Host: api.rentnsell.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

### Example Response
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Account deleted successfully"
}
```

### Implementation Notes
- After successful account deletion, the client should:
  1. Clear ALL local storage data
  2. Clear AuthController state
  3. Navigate to login screen
- This action is **irreversible** - all user data will be permanently deleted
- The user should be shown a confirmation dialog before deletion

### Mock Implementation
The mock API service (`MockAuthApiService`) simulates a network delay of 1000ms and returns a successful response if a valid JWT token is provided.

---

## Profile Update API

### Endpoint
```
PUT /api/profile
```

### Description
Updates user profile information. This API is used in the Profile Settings screen for updating:
- Profile image
- Phone number
- Address
- Address visibility
- Interested categories
- Interested actions

### Headers
```
Authorization: Bearer {jwtToken}
Content-Type: application/json
```

### Request Body
```json
{
  "phone": "+1234567890",                    // Optional
  "address": "123 Main St, City, State",    // Optional
  "showAddressToAll": true,                  // Optional
  "interestedCategoryIds": ["cat_1", "cat_2"], // Optional
  "interestedActions": ["Sell", "Rent"],    // Optional
  "profileImageBase64": "base64_encoded_image", // Optional
  "profileImageName": "profile.jpg",        // Optional (required if profileImageBase64 is provided)
  "profileImageType": "image/jpeg"          // Optional (required if profileImageBase64 is provided)
}
```

### Response

#### Success Response (200 OK)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Profile updated successfully",
  "data": {
    "profileImageUrl": "https://cdn.example.com/profile/user123.jpg",
    "phone": "+1234567890",
    "address": "123 Main St, City, State",
    "showAddressToAll": true,
    "interestedCategoryIds": ["cat_1", "cat_2"],
    "interestedActions": ["Sell", "Rent"]
  }
}
```

### Example Request
```http
PUT /api/profile HTTP/1.1
Host: api.rentnsell.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "phone": "+1234567890",
  "address": "123 Main St, City, State",
  "showAddressToAll": true
}
```

### Example Response
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Profile updated successfully",
  "data": {
    "profileImageUrl": null,
    "phone": "+1234567890",
    "address": "123 Main St, City, State",
    "showAddressToAll": true,
    "interestedCategoryIds": null,
    "interestedActions": null
  }
}
```

---

## Profile Get API

### Endpoint
```
GET /api/profile
```

### Description
Retrieves the current user's profile information.

### Headers
```
Authorization: Bearer {jwtToken}
Content-Type: application/json
```

### Request Body
No request body required.

### Response

#### Success Response (200 OK)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Profile retrieved successfully",
  "data": {
    "id": "user_123",
    "displayName": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "age": 28,
    "gender": "Male",
    "address": "123 Main St, City, State",
    "photoUrl": "https://lh3.googleusercontent.com/...",
    "profileImageUrl": "https://cdn.example.com/profile/user123.jpg",
    "showAddressToAll": true,
    "interestedCategoryIds": ["cat_1", "cat_2"],
    "interestedActions": ["Sell", "Rent"],
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-20T15:45:00Z"
  }
}
```

### Example Request
```http
GET /api/profile HTTP/1.1
Host: api.rentnsell.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

### Example Response
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Profile retrieved successfully",
  "data": {
    "id": "user_123",
    "displayName": "John Doe",
    "email": "john.doe@example.com",
    "phone": "+1234567890",
    "age": 28,
    "gender": "Male",
    "address": "123 Main St, City, State",
    "photoUrl": "https://lh3.googleusercontent.com/...",
    "profileImageUrl": "https://cdn.example.com/profile/user123.jpg",
    "showAddressToAll": true,
    "interestedCategoryIds": ["cat_men", "cat_women"],
    "interestedActions": ["Sell", "Rent"],
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-20T15:45:00Z"
  }
}
```

---

## Error Handling

All APIs follow a consistent error response format:

```json
{
  "success": false,
  "statusCode": 400 | 401 | 403 | 404 | 500,
  "message": "Error message describing what went wrong"
}
```

### Common Error Codes
- **400 Bad Request**: Invalid request parameters
- **401 Unauthorized**: Missing or invalid JWT token
- **403 Forbidden**: User doesn't have permission
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server error

---

## Authentication

All APIs (except login) require a valid JWT token in the Authorization header:

```
Authorization: Bearer {jwtToken}
```

If the token is missing, invalid, or expired, the API will return a 401 Unauthorized response.

---

## Mock API Service

The mock API service (`MockAuthApiService`) is located at:
- `lib/services/mock_auth_api_service.dart`

### Methods
- `logout({required String jwtToken})`: Simulates logout API call
- `deleteAccount({required String jwtToken})`: Simulates delete account API call

Both methods:
- Simulate network delay (800ms for logout, 1000ms for delete account)
- Validate JWT token presence
- Return appropriate success/error responses

---

## Response Models

### AuthLogoutResponseModel
```dart
class AuthLogoutResponseModel {
  final bool success;
  final int statusCode;
  final String message;
}
```

### AuthDeleteAccountResponseModel
```dart
class AuthDeleteAccountResponseModel {
  final bool success;
  final int statusCode;
  final String message;
}
```

---

## Client Implementation

### Logout Flow
1. User taps "Logout" in Profile Settings
2. Show confirmation dialog
3. Call `POST /api/auth/logout` with JWT token
4. On success:
   - Clear local storage (JWT, refresh token, FCM token)
   - Clear AuthController state
   - Navigate to login screen
5. On error: Show error toast

### Delete Account Flow
1. User taps "Delete Account" in Profile Settings
2. Show confirmation dialog with warning
3. Call `DELETE /api/auth/account` with JWT token
4. On success:
   - Clear ALL local storage
   - Clear AuthController state
   - Navigate to login screen
5. On error: Show error toast

---

## Notes

- All timestamps are in ISO 8601 format (UTC)
- JWT tokens should be stored securely in local storage
- Profile image should be sent as base64 encoded string
- All optional fields in update requests can be omitted if not being updated
- The mock API services are for development/testing only

---

## Testing

To test the mock APIs:

1. **Logout Test**:
   - Ensure user is logged in (has JWT token)
   - Navigate to Profile Settings
   - Tap "Logout"
   - Confirm logout and navigation to login screen

2. **Delete Account Test**:
   - Ensure user is logged in (has JWT token)
   - Navigate to Profile Settings
   - Tap "Delete Account"
   - Confirm deletion and navigation to login screen

---

## Future Enhancements

- Add refresh token rotation on logout
- Add account deletion grace period (e.g., 30 days)
- Add account recovery option
- Add audit log for account deletion
- Add email confirmation for account deletion


