# Models Structure Documentation

## Folder Structure

```
lib/models/
├── category_model.dart
├── user_profile_model.dart
├── request/
│   └── profile_save_request_model.dart
└── response/
    └── profile_save_response_model.dart
```

## Request Models

### ProfileSaveRequestModel
**Location:** `lib/models/request/profile_save_request_model.dart`

**Purpose:** Represents the request body sent to the API when saving user profile.

**Fields:**
- `email` (String) - User's email address
- `phone` (String) - User's phone number with country code
- `age` (int) - User's age
- `gender` (String) - User's gender (Male/Female/Other)
- `address` (String) - User's address
- `interestedCategoryIds` (List<String>) - Selected category IDs
- `interestedActions` (List<String>) - Selected actions (Sell, Rent, Buy, etc.)
- `fcmToken` (String) - Firebase Cloud Messaging token
- `googleId` (String?) - Google user ID (optional)
- `displayName` (String?) - User's display name (optional)
- `photoUrl` (String?) - User's photo URL (optional)

**Methods:**
- `toJson()` - Converts model to JSON map
- `fromJson()` - Creates model from JSON map
- `fromUserProfile()` - Factory constructor to create from UserProfileModel

**Usage Example:**
```dart
final requestModel = ProfileSaveRequestModel.fromUserProfile(profile, fcmToken);
final jsonBody = requestModel.toJson();
```

## Response Models

### ProfileSaveResponseModel
**Location:** `lib/models/response/profile_save_response_model.dart`

**Purpose:** Represents the API response when saving user profile.

**Fields:**
- `success` (bool) - Whether the request was successful
- `statusCode` (int) - HTTP status code
- `message` (String) - Response message
- `data` (ProfileSaveResponseData?) - Response data (nullable)

**Methods:**
- `toJson()` - Converts model to JSON map
- `fromJson()` - Creates model from JSON map

### ProfileSaveResponseData
**Location:** `lib/models/response/profile_save_response_model.dart`

**Purpose:** Nested data model within ProfileSaveResponseModel.

**Fields:**
- `userId` (String) - Unique user identifier
- `email` (String) - User's email address
- `profileCompleted` (bool) - Whether profile is complete
- `jwtToken` (String) - JWT authentication token
- `refreshToken` (String) - Token for refreshing JWT
- `expiresIn` (int) - JWT token expiration time in seconds

**Methods:**
- `toJson()` - Converts model to JSON map
- `fromJson()` - Creates model from JSON map

**Usage Example:**
```dart
final response = await apiService.saveProfile(profile, fcmToken);
if (response.success && response.data != null) {
  final jwtToken = response.data!.jwtToken;
  // Save JWT token to local storage
}
```

## Model Pattern

All models follow the same pattern:

1. **Class Definition** - Simple class with final fields
2. **Constructor** - Named constructor with required/optional parameters
3. **toJson()** - Converts model instance to Map<String, dynamic>
4. **fromJson()** - Factory constructor to create instance from Map<String, dynamic>
5. **Helper Methods** - Additional factory constructors or utility methods as needed

## Integration with Services

### MockProfileApiService
**Location:** `lib/services/mock_profile_api_service.dart`

Uses the request and response models:

```dart
Future<ProfileSaveResponseModel> saveProfile({
  required UserProfileModel profile,
  required String fcmToken,
}) async {
  // Create request model
  final requestModel = ProfileSaveRequestModel.fromUserProfile(profile, fcmToken);
  
  // Make API call (mock)
  // ...
  
  // Return response model
  return ProfileSaveResponseModel.fromJson(responseData);
}
```

### ProfileController
**Location:** `lib/ui_and_controller/auth/profile_controller.dart`

Uses the response model:

```dart
final response = await _apiService.saveProfile(profile: profile, fcmToken: fcmToken);

if (response.success && response.data != null) {
  final data = response.data!;
  // Access typed fields
  final jwtToken = data.jwtToken;
  final refreshToken = data.refreshToken;
}
```

## Benefits of This Structure

1. **Type Safety** - Compile-time checking instead of runtime errors
2. **Code Completion** - IDE autocomplete for all fields
3. **Maintainability** - Easy to update when API changes
4. **Consistency** - All models follow the same pattern
5. **Reusability** - Models can be used across different services
6. **Documentation** - Models serve as documentation of API structure

## Adding New Models

When adding new request/response models:

1. Create file in appropriate folder (`request/` or `response/`)
2. Follow the same pattern as existing models
3. Include `toJson()` and `fromJson()` methods
4. Add factory constructors if needed
5. Update services to use the new models
6. Update this documentation

