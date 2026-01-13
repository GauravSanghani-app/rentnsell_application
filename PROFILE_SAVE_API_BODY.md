# Profile Save API Request Body

## When Save Profile Button is Tapped

When the user taps the "Save Profile" button in `ProfileManageScreen`, the following request body is sent to the API.

## Request Body Structure

```json
{
  "email": "user@example.com",
  "phone": "+1234567890",
  "age": 25,
  "gender": "Male",
  "address": "123 Main Street, City, State, Country",
  "interestedCategoryIds": [
    "cat_men",
    "cat_women",
    "cat_car",
    "cat_house"
  ],
  "interestedActions": [
    "Sell",
    "Rent",
    "Buy"
  ],
  "fcmToken": "fcm_token_from_firebase_messaging_here",
  "googleId": "google_user_id_from_firebase_auth",
  "displayName": "John Doe",
  "photoUrl": "https://lh3.googleusercontent.com/a/photo_url_here"
}
```

## Field Details

| Field | Type | Required | Description | Example |
|-------|------|----------|-------------|---------|
| `email` | String | ✅ Yes | User's email address (from Google Sign-In) | `"user@example.com"` |
| `phone` | String | ✅ Yes | User's phone number with country code | `"+1234567890"` |
| `age` | Integer | ✅ Yes | User's age (13-120) | `25` |
| `gender` | String | ✅ Yes | User's gender | `"Male"`, `"Female"`, or `"Other"` |
| `address` | String | ✅ Yes | User's full address | `"123 Main St, City, Country"` |
| `interestedCategoryIds` | Array[String] | ✅ Yes | Selected category IDs | `["cat_men", "cat_women"]` |
| `interestedActions` | Array[String] | ✅ Yes | Selected actions | `["Sell", "Rent", "Buy"]` |
| `fcmToken` | String | ✅ Yes | Firebase Cloud Messaging token | `"fcm_token_here"` |
| `googleId` | String | ❌ Optional | Google user ID (from Firebase Auth) | `"1234567890"` |
| `displayName` | String | ❌ Optional | User's display name (from Google) | `"John Doe"` |
| `photoUrl` | String | ❌ Optional | User's photo URL (from Google) | `"https://..."` |

## Example Request Body (Real Data)

```json
{
  "email": "john.doe@gmail.com",
  "phone": "+11234567890",
  "age": 28,
  "gender": "Male",
  "address": "456 Oak Avenue, New York, NY 10001, USA",
  "interestedCategoryIds": [
    "cat_men",
    "cat_car",
    "cat_electronic",
    "cat_mobile"
  ],
  "interestedActions": [
    "Sell",
    "Rent",
    "Buy"
  ],
  "fcmToken": "dK8xYz9aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890",
  "googleId": "108512345678901234567",
  "displayName": "John Doe",
  "photoUrl": "https://lh3.googleusercontent.com/a-/AOh14GiExamplePhoto"
}
```

## How It's Generated

The request body is created in `ProfileController.saveProfile()` method:

1. **Profile Data** is collected from form fields:
   - `email` - From emailController (pre-filled from Google)
   - `phone` - From phoneController + countryCode
   - `age` - From ageController (parsed to int)
   - `gender` - From selected gender option
   - `address` - From addressController
   - `interestedCategoryIds` - From selected categories
   - `interestedActions` - From selected actions

2. **FCM Token** is retrieved from:
   - FCMService (if available)
   - Or from local storage (if previously saved)

3. **Google Data** is from:
   - `googleId` - From Firebase Auth user.uid
   - `displayName` - From Firebase Auth user.displayName
   - `photoUrl` - From Firebase Auth user.photoURL

4. **Request Model** is created:
   ```dart
   final requestModel = ProfileSaveRequestModel.fromUserProfile(profile, fcmToken);
   final jsonBody = requestModel.toJson();
   ```

## Code Flow

```
ProfileManageScreen (Save Button Tap)
  ↓
ProfileManageController.saveProfile()
  ↓
ProfileController.saveProfile()
  ↓
1. Build UserProfileModel from form fields
2. Get FCM Token from FCMService
3. Create ProfileSaveRequestModel
4. Call MockProfileApiService.saveProfile()
  ↓
ProfileSaveRequestModel.toJson()
  ↓
JSON Body sent to API
```

## Console Output

When you tap Save Profile, you'll see in console:

```
MockProfileApiService: Request Body:
{
  "email":"user@example.com",
  "phone":"+1234567890",
  "age":25,
  "gender":"Male",
  "address":"123 Main St",
  "interestedCategoryIds":["cat_men","cat_women"],
  "interestedActions":["Sell","Rent"],
  "fcmToken":"fcm_token_here",
  "googleId":"google_user_id",
  "displayName":"John Doe",
  "photoUrl":"https://..."
}
```

## Notes

- **Phone Number**: Includes country code (e.g., `+1` for US, `+91` for India)
- **Age**: Must be between 13-120 (validated in form)
- **Categories**: At least one category must be selected
- **Actions**: At least one action must be selected
- **FCM Token**: Automatically retrieved from Firebase Messaging
- **Optional Fields**: `googleId`, `displayName`, `photoUrl` may be null if not available from Google Sign-In

