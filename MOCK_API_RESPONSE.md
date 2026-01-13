# Mock API Response Documentation

## Profile Save API

### Endpoint
`POST /api/profile/save`

### Request Body
```json
{
  "email": "user@example.com",
  "phone": "+1234567890",
  "age": 25,
  "gender": "Male",
  "address": "123 Main St, City, Country",
  "interestedCategoryIds": ["cat_men", "cat_women", "cat_car"],
  "interestedActions": ["Sell", "Rent", "Buy"],
  "fcmToken": "fcm_token_from_firebase_messaging",
  "googleId": "google_user_id_from_firebase_auth",
  "displayName": "John Doe",
  "photoUrl": "https://lh3.googleusercontent.com/photo_url"
}
```

### Response Structure

#### Success Response (200 OK)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Profile saved successfully",
  "data": {
    "userId": "user_1234567890",
    "email": "user@example.com",
    "profileCompleted": true,
    "jwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjM0NTY3ODkwIiwic3ViIjoiZW1haWxAZXhhbXBsZS5jb20iLCJpYXQiOjE3MDAwMDAwMDAsImV4cCI6MTcwMDAwMzYwMH0.mock_jwt_token_signature",
    "refreshToken": "refresh_token_1234567890",
    "expiresIn": 3600
  }
}
```

#### Error Response (400 Bad Request)
```json
{
  "success": false,
  "statusCode": 400,
  "message": "Validation failed",
  "data": null,
  "errors": {
    "phone": ["Phone number is required"],
    "age": ["Age must be between 13 and 120"]
  }
}
```

#### Error Response (401 Unauthorized)
```json
{
  "success": false,
  "statusCode": 401,
  "message": "Unauthorized. Please login again.",
  "data": null
}
```

#### Error Response (500 Internal Server Error)
```json
{
  "success": false,
  "statusCode": 500,
  "message": "Internal server error. Please try again later.",
  "data": null
}
```

## Response Fields Explanation

### Success Response Data Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Indicates if the request was successful |
| `statusCode` | integer | HTTP status code (200 for success) |
| `message` | string | Human-readable message |
| `data.userId` | string | Unique user identifier |
| `data.email` | string | User's email address |
| `data.profileCompleted` | boolean | Whether profile is complete |
| `data.jwtToken` | string | JWT authentication token (saved to local storage) |
| `data.refreshToken` | string | Token used to refresh JWT token |
| `data.expiresIn` | integer | JWT token expiration time in seconds |

### JWT Token Structure

The JWT token is a base64-encoded string with three parts:
1. **Header**: Algorithm and token type
2. **Payload**: User data (userId, email, etc.)
3. **Signature**: Verification signature

Example decoded payload:
```json
{
  "userId": "1234567890",
  "sub": "email@example.com",
  "iat": 1700000000,
  "exp": 1700003600
}
```

## Implementation Details

### What Gets Saved to Local Storage

1. **JWT Token** (`jwt_token`): Saved in SharedPreferences
   - Used for authenticated API requests
   - Expires after `expiresIn` seconds

2. **Refresh Token** (`refresh_token`): Saved in SharedPreferences
   - Used to get a new JWT token when it expires

3. **FCM Token** (`fcm_token`): Saved in SharedPreferences
   - Used for push notifications
   - Automatically refreshed by Firebase

4. **User Profile**: Saved as JSON in SharedPreferences
   - All profile data including categories and actions

### Flow

1. User fills profile form
2. On "Save Profile" button tap:
   - Get FCM token (if available)
   - Build request body with profile data + FCM token
   - Call mock API service
   - Wait for response (2 second delay simulated)
3. On success:
   - Save JWT token to local storage
   - Save refresh token to local storage
   - Save profile data locally
   - Show success toast
   - Navigate to Home screen
4. On error:
   - Show error toast with message
   - Keep user on profile screen

## Testing

The mock API service simulates:
- ✅ 2 second network delay
- ✅ Successful response with JWT token
- ✅ Proper response structure
- ✅ Console logging of request/response

To test with real API, replace `MockProfileApiService` with actual HTTP service.

