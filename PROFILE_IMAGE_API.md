# Profile Image API Documentation

## Image Display Priority

The profile image is displayed in the following priority order:

1. **User Selected Image** - If user picks a new image from gallery
2. **Google Photo** - If available from Google Sign-In
3. **Default Avatar** - Asset image (icon) if no image available

## Request Body (When Image is Selected)

When user selects a new image and taps "Save Profile", the request body includes:

```json
{
  "email": "user@example.com",
  "phone": "+1234567890",
  "age": 25,
  "gender": "Male",
  "address": "123 Main St",
  "interestedCategoryIds": ["cat_men", "cat_women"],
  "interestedActions": ["Sell", "Rent"],
  "fcmToken": "fcm_token_here",
  "googleId": "google_user_id",
  "displayName": "John Doe",
  "photoUrl": "https://google_photo_url",
  "profileImageBase64": "iVBORw0KGgoAAAANSUhEUgAA... (base64 encoded image)",
  "profileImageName": "IMG_20240101_123456.jpg",
  "profileImageType": "image/jpeg"
}
```

## Image Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `profileImageBase64` | String | ❌ Optional | Base64 encoded image (only if user selected new image) |
| `profileImageName` | String | ❌ Optional | Original image file name |
| `profileImageType` | String | ❌ Optional | MIME type (image/jpeg, image/png, etc.) |

## Response Structure

### Success Response (200 OK)
```json
{
  "success": true,
  "statusCode": 200,
  "message": "Profile saved successfully",
  "data": {
    "userId": "user_123",
    "email": "user@example.com",
    "profileCompleted": true,
    "jwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_here",
    "expiresIn": 3600,
    "profileImageUrl": "https://api.example.com/uploads/profile/user_123.jpg"
  }
}
```

## Image Upload Models

### ProfileImageUploadRequestModel
**Location:** `lib/models/request/profile_image_upload_request_model.dart`

Used for dedicated image upload endpoint (if needed separately).

```dart
{
  "userId": "user_123",
  "imageBase64": "base64_encoded_image",
  "imageName": "profile_image.jpg",
  "imageType": "image/jpeg"
}
```

### ProfileImageUploadResponseModel
**Location:** `lib/models/response/profile_image_upload_response_model.dart`

Response from image upload endpoint.

```dart
{
  "success": true,
  "statusCode": 200,
  "message": "Image uploaded successfully",
  "data": {
    "imageUrl": "https://api.example.com/uploads/profile/user_123.jpg",
    "imageId": "img_123456",
    "thumbnailUrl": "https://api.example.com/uploads/profile/thumb_user_123.jpg"
  }
}
```

## Image Processing

1. **Image Selection**: User taps camera icon → Image picker opens → User selects image
2. **Image Conversion**: Selected image is converted to base64
3. **Image Compression**: Image is compressed to 80% quality, max 800x800px
4. **API Request**: Base64 image is included in profile save request
5. **Response**: Server returns image URL which can be saved locally

## Implementation Details

### Image Picker
- Uses `image_picker` package
- Source: Gallery only (can be extended to camera)
- Quality: 80%
- Max dimensions: 800x800px

### Base64 Encoding
- Image file is read as bytes
- Converted to base64 string
- Included in API request body
- Only sent if user selected a new image

### Image Display
- Selected image: `Image.file(File(path))`
- Google photo: `Image.network(url)`
- Default avatar: `Icon(Icons.person)`

## Console Output

When image is selected and saved:

```
ProfileController: Image converted to base64, size: 245678 chars
MockProfileApiService: Request Body:
{
  "email":"user@example.com",
  ...
  "profileImageBase64":"iVBORw0KGgoAAAANSUhEUgAA... (245678 chars)",
  "profileImageName":"IMG_20240101_123456.jpg",
  "profileImageType":"image/jpeg"
}
```

## Notes

- Image is only sent if user selects a new image
- If no image is selected, only existing `photoUrl` (from Google) is sent
- Base64 encoding increases payload size significantly
- Consider using multipart/form-data for production
- Image is compressed to reduce payload size

