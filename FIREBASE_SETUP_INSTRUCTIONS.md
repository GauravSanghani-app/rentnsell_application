# Firebase Google Sign-In Setup Instructions

## Problem
The `google-services.json` file shows `"oauth_client": []` which means Google Sign-In OAuth is not configured. This causes the "Missing access token or id token" error.

## Solution: Add SHA Fingerprints to Firebase Console

### Step 1: Get Your SHA Fingerprints (Already Done)
Your SHA fingerprints are:
- **SHA1**: `7B:1C:5A:2F:36:F6:14:A2:74:EC:9D:B1:7A:CC:BF:46:C6:15:4F:CF`
- **SHA-256**: `C1:BB:7A:22:3B:B8:AB:B3:29:61:6F:45:35:A7:E7:1C:8B:FD:89:C5:50:7B:A9:3E:8E:5D:06:C0:D4:02:79:28`

### Step 2: Add SHA Fingerprints to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **rentnsell-4a1df**
3. Click on the **⚙️ Settings** icon (gear icon) next to "Project Overview"
4. Select **Project settings**
5. Scroll down to **Your apps** section
6. Find your Android app: `com.rent.n.sell.car.home.property.chaniyacholi`
7. Click on the app to expand it
8. Click **Add fingerprint** button
9. Add both SHA-1 and SHA-256 fingerprints:
   - SHA-1: `7B:1C:5A:2F:36:F6:14:A2:74:EC:9D:B1:7A:CC:BF:46:C6:15:4F:CF`
   - SHA-256: `C1:BB:7A:22:3B:B8:AB:B3:29:61:6F:45:35:A7:E7:1C:8B:FD:89:C5:50:7B:A9:3E:8E:5D:06:C0:D4:02:79:28`
10. Click **Save**

### Step 3: Enable Google Sign-In in Firebase Authentication

1. In Firebase Console, go to **Authentication** (left sidebar)
2. Click on **Sign-in method** tab
3. Find **Google** in the list
4. Click on **Google**
5. Enable it by toggling the switch
6. Enter your **Support email** (your email address)
7. Click **Save**

### Step 4: Download Updated google-services.json

1. Go back to **Project settings** (⚙️ Settings → Project settings)
2. Scroll to **Your apps** section
3. Find your Android app
4. Click **Download google-services.json**
5. Replace the existing file at: `android/app/google-services.json`

### Step 5: Verify OAuth Client is Added

After downloading the new `google-services.json`, check that the `oauth_client` array is no longer empty. It should contain OAuth client configuration.

### Step 6: Rebuild the App

```bash
flutter clean
flutter pub get
flutter run
```

## Alternative: Manual OAuth Client Configuration

If the above doesn't work, you can manually add OAuth client:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project: **rentnsell-4a1df**
3. Go to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **OAuth client ID**
5. Select **Android** as application type
6. Enter:
   - Name: `Rent N Sell Android`
   - Package name: `com.rent.n.sell.car.home.property.chaniyacholi`
   - SHA-1: `7B:1C:5A:2F:36:F6:14:A2:74:EC:9D:B1:7A:CC:BF:46:C6:15:4F:CF`
7. Click **Create**
8. Download the updated `google-services.json` from Firebase Console

## Troubleshooting

- **Still getting "Missing access token" error?**
  - Wait 5-10 minutes after adding SHA fingerprints (Firebase needs time to propagate)
  - Make sure you downloaded the NEW `google-services.json` after adding fingerprints
  - Verify `oauth_client` array is not empty in the new file

- **For Release Build:**
  - You'll need to add the release keystore SHA fingerprints as well
  - Get release SHA: `cd android && ./gradlew signingReport` (with release keystore)
  - Add those fingerprints to Firebase Console too

