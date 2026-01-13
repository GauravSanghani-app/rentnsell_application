# Profile API Documentation

This document describes the Profile APIs used in the application.

## 1. GET Profile API

### Endpoint
```
GET /api/profile
```

### Headers
```
Authorization: Bearer {jwtToken}
Content-Type: application/json
```

### Description
Retrieves the user's profile information. Requires JWT token in the Authorization header.

### Request
No request body required. JWT token is passed in the Authorization header.

### Response

#### Success Response (200 OK)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Profile retrieved successfully",
  "data": {
    "email": "user@example.com",
    "phone": "+1234567890",
    "age": 25,
    "gender": "Male",
    "address": "123 Main St",
    "interestedCategoryIds": ["cat_men", "cat_women"],
    "interestedActions": ["Sell", "Rent"],
    "googleId": "google_user_id",
    "displayName": "John Doe",
    "photoUrl": "https://google_photo_url",
    "profileImageUrl": "https://api.example.com/profile_images/user_123.jpg",
    "showAddressToAll": false
  }
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

### Response Model
- **ProfileGetResponseModel**: Contains `success`, `statusCode`, `message`, and `data`
- **ProfileGetResponseData**: Contains all profile fields including:
  - `email`: User's email address
  - `phone`: User's phone number with country code
  - `age`: User's age
  - `gender`: User's gender (Male/Female/Other)
  - `address`: User's address
  - `interestedCategoryIds`: List of selected category IDs
  - `interestedActions`: List of selected interests
  - `googleId`: Google user ID (if logged in via Google)
  - `displayName`: User's display name
  - `photoUrl`: Google profile photo URL (if available)
  - `profileImageUrl`: Server URL for uploaded profile image (if available)
  - `showAddressToAll`: Boolean toggle for address visibility

---

## 2. UPDATE Profile API

### Endpoint
```
PATCH /api/profile
```

### Headers
```
Authorization: Bearer {jwtToken}
Content-Type: application/json
```

### Description
Updates user profile information. Supports partial updates - only send fields that need to be updated. Requires JWT token in the Authorization header.

### Request Body

#### Update Profile Image
```json
{
  "profileImageBase64": "iVBORw0KGgoAAAANSUhEUgAA... (base64 encoded image)",
  "profileImageName": "IMG_20240101_123456.jpg",
  "profileImageType": "image/jpeg"
}
```

#### Update Phone Number
```json
{
  "phone": "+1234567890"
}
```

#### Update Address Visibility
```json
{
  "showAddressToAll": true
}
```

#### Update Categories
```json
{
  "interestedCategoryIds": ["cat_men", "cat_women", "cat_car"]
}
```

#### Update Interests
```json
{
  "interestedActions": ["Sell", "Rent", "Buy"]
}
```

#### Combined Update (Multiple Fields)
```json
{
  "phone": "+1234567890",
  "showAddressToAll": true,
  "interestedCategoryIds": ["cat_men", "cat_women"],
  "interestedActions": ["Sell", "Rent"]
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
    "profileImageUrl": "https://api.example.com/profile_images/user_123_1234567890.jpg",
    "phone": "+1234567890",
    "showAddressToAll": true,
    "interestedCategoryIds": ["cat_men", "cat_women"],
    "interestedActions": ["Sell", "Rent"]
  }
}
```

**Note**: The response `data` object only contains the fields that were updated. If you only updated the phone number, only `phone` will be in the response.

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

### Request Model
- **ProfileUpdateRequestModel**: Contains optional fields:
  - `phone`: String? - Phone number with country code
  - `profileImageBase64`: String? - Base64 encoded image
  - `profileImageName`: String? - Image file name
  - `profileImageType`: String? - Image MIME type (image/jpeg, image/png, etc.)
  - `showAddressToAll`: bool? - Address visibility toggle
  - `interestedCategoryIds`: List<String>? - Updated category selection
  - `interestedActions`: List<String>? - Updated interest selection

### Response Model
- **ProfileUpdateResponseModel**: Contains `success`, `statusCode`, `message`, and `data`
- **ProfileUpdateResponseData**: Contains only the updated fields:
  - `profileImageUrl`: String? - Updated profile image URL (if image was uploaded)
  - `phone`: String? - Updated phone number (if phone was updated)
  - `showAddressToAll`: bool? - Updated address visibility (if toggle was updated)
  - `interestedCategoryIds`: List<String>? - Updated categories (if categories were updated)
  - `interestedActions`: List<String>? - Updated interests (if interests were updated)

---

## 3. JWT Token Storage

The JWT token is stored in local storage using `SharedPreferences` with the key `jwtToken`.

### Retrieving JWT Token
```dart
final jwtToken = preferences.getString(SharedPreference.jwtToken);
```

### Using JWT Token in API Calls
The JWT token is automatically included in the Authorization header when making API calls:
```dart
headers: {
  'Authorization': 'Bearer $jwtToken',
  'Content-Type': 'application/json',
}
```

The `requestHeaders` function in `lib/api/request_const.dart` automatically retrieves the JWT token from local storage and includes it in the Authorization header when `passAuthToken: true` is set.

---

## 4. Profile Screen Features

The Profile Screen (`profile_screen.dart`) provides the following features:

1. **View Profile Information**
   - Display name, email, phone, age, gender, address
   - Profile image (from Google, uploaded image, or default avatar)

2. **Update Profile Image**
   - Select image from gallery
   - Image is compressed and converted to Base64
   - Sent to API with `profileImageBase64`, `profileImageName`, and `profileImageType`

3. **Update Phone Number**
   - Country code picker
   - Phone number input
   - Updates phone via API

4. **Address Visibility Toggle**
   - Toggle switch to show/hide address to all users
   - Updates `showAddressToAll` via API

5. **Update Categories**
   - Multi-select chips for categories
   - Updates `interestedCategoryIds` via API

6. **Update Interests**
   - Multi-select chips for interests (Sell, Rent, Buy, Not decided yet, Want rental things)
   - Updates `interestedActions` via API

---

## 5. Implementation Notes

### Image Handling
- When a user selects a new image, it's stored locally as `_selectedImagePath`
- The image is converted to Base64 before sending to the API
- After successful upload, the server returns `profileImageUrl` which replaces the local image
- Image priority for display: Selected image > Server image > Google photo > Default avatar

### Partial Updates
- The UPDATE API supports partial updates
- Only send the fields that need to be updated
- The response only contains the updated fields

### Error Handling
- All API calls include proper error handling
- Error messages are displayed using toast notifications
- Loading states are managed for better UX

### Local Profile Sync
- After successful API updates, the local profile is also updated
- This ensures consistency between server and local data

---

## 6. Mock API Service

The `MockProfileApiService` class provides mock implementations of:
- `getProfile(jwtToken)`: Returns mock profile data
- `updateProfile(jwtToken, request)`: Returns mock update response

These can be replaced with actual API calls when the backend is ready.

