# Rent N Sell

Flutter-based marketplace app for renting and selling products.

## Tech Stack

- Flutter (Dart)
- GetX (routing + state management)
- HTTP (REST APIs)
- Firebase Core/Auth/Messaging (notifications + auth support)
- SharedPreferences (local session storage)

## Project Architecture (Short)

- `lib/ui_and_controller/` - Feature-first screens and GetX controllers
- `lib/services/` - API service classes (auth, product, wishlist, profile, notifications)
- `lib/models/` - Request/response models
- `lib/config/` - App configuration and route definitions
- `lib/api/` - API constants like base URL
- `lib/utils/` - Shared helpers, local storage wrapper, extensions

## Main App Flow

`Splash -> Onboarding/Login -> Master (Bottom Tabs)`

Bottom tabs in master:

- Home
- Category
- Wishlist
- Profile

## Core Features

- Authentication and session management
- Product CRUD (add, edit, detail, delete)
- Wishlist with cross-screen sync
- Profile and settings management
- Notifications (FCM)
- Location-aware product discovery

## State Management

- Uses `GetxController` + `GetBuilder`
- UI updates are mostly `update()` driven
- Navigation uses centralized named routes

## API Configuration

- Base URL is configured in `lib/api/request_const.dart`
- Most modules call REST endpoints through `lib/services/`

## Quick Start

1. Install Flutter SDK
2. Run dependency install:
   - `flutter pub get`
3. Configure Firebase files:
   - Android: `android/app/google-services.json`
   - iOS: `ios/Runner/GoogleService-Info.plist`
4. Run app:
   - `flutter run`

## Build Commands

- Debug run: `flutter run`
- Android release APK: `flutter build apk --release`
- iOS release build: `flutter build ios --release`

## Notes

- If APIs are not responding, verify base URL and network permissions.
- For login/session issues, clear app storage and retry.
