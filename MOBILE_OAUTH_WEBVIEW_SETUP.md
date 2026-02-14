# Mobile OAuth Web View Setup

## Summary of Changes

The authentication has been updated to use **web view OAuth** for both web and mobile platforms. This ensures compatibility with your Google OAuth client configured as a "Web Application" in Google Cloud Console.

## Changes Made

### 1. Code Updates

#### Therapist App
- **File**: `therapist/lib/repository/supabase_auth_repository.dart`
  - Removed native `GoogleSignIn` package usage
  - Updated to use `signInWithOAuth` with web view for all platforms
  - Removed unused imports (`dart:io`, `flutter_dotenv`, `google_sign_in`)

#### Patient App
- **File**: `patient/lib/provider/auth_provider.dart`
  - Removed native `GoogleSignIn` package usage
  - Updated to use `signInWithOAuth` with web view for all platforms
  - Removed unused imports (`dart:io`, `flutter_dotenv`, `google_sign_in`)

### 2. Deep Link Configuration

#### Android (Both Apps)
- **Files**: 
  - `therapist/android/app/src/main/AndroidManifest.xml`
  - `patient/android/app/src/main/AndroidManifest.xml`
- **Added**: Deep link intent filters for OAuth callbacks
  - Therapist: `com.neurotrack.therapist://login-callback`
  - Patient: `com.neurotrack.patient://login-callback`

#### iOS (Both Apps)
- **Files**:
  - `therapist/ios/Runner/Info.plist`
  - `patient/ios/Runner/Info.plist`
- **Added**: Custom URL schemes for OAuth callbacks
  - Therapist: `com.neurotrack.therapist`
  - Patient: `com.neurotrack.patient`

## Required Supabase Configuration

### Step 1: Update Redirect URLs

Go to **Supabase Dashboard** → **Authentication** → **URL Configuration**

Add the following redirect URLs:

**For Web (Development):**
```
http://localhost:*
http://127.0.0.1:*
```

**For Mobile Apps:**
```
com.neurotrack.therapist://login-callback
com.neurotrack.patient://login-callback
```

**For Production Web (if applicable):**
```
https://your-production-domain.com
https://your-production-domain.com/**
```

### Step 2: Verify Google OAuth Settings

1. Ensure Google OAuth is enabled in **Supabase Dashboard** → **Authentication** → **Providers** → **Google**
2. Verify that your Google Cloud Console OAuth client is configured as a **Web Application**
3. Ensure the **Authorized Redirect URIs** in Google Cloud Console includes:
   ```
   https://your-project-id.supabase.co/auth/v1/callback
   ```

## How It Works

1. **Web**: Uses the current page URL for redirect (e.g., `http://localhost:50001`)
2. **Mobile**: Uses custom deep link schemes (e.g., `com.neurotrack.therapist://login-callback`)
3. **OAuth Flow**: 
   - User taps "Sign in with Google"
   - App opens a web view with Google OAuth
   - User authenticates with Google
   - Google redirects to Supabase callback
   - Supabase redirects to the app's deep link
   - App handles the callback and completes authentication

## Testing

### Web Testing
1. Run the app on web: `flutter run -d chrome`
2. Click "Sign in with Google"
3. Complete OAuth flow
4. Should redirect back to the app

### Mobile Testing
1. Build and run on device/emulator
2. Click "Sign in with Google"
3. Web view should open with Google sign-in
4. After authentication, app should return from web view
5. User should be authenticated

## Deployment Notes

### Play Store & App Store
- ✅ **Ready for deployment** - No Vercel needed
- The apps can be built and deployed directly to:
  - **Google Play Store** (Android)
  - **Apple App Store** (iOS)

### Important Notes
- The `google_sign_in` package is still in `pubspec.yaml` but no longer used in code
- You can optionally remove it later if not needed elsewhere
- Deep link schemes must match between code and platform configurations
- Ensure Supabase redirect URLs include your mobile deep links

## Troubleshooting

### Issue: OAuth redirect not working on mobile
- **Check**: Deep link schemes match in code, AndroidManifest.xml, and Info.plist
- **Check**: Supabase redirect URLs include the mobile deep link schemes
- **Check**: App has proper permissions for opening web views

### Issue: OAuth redirect not working on web
- **Check**: Supabase redirect URLs include `http://localhost:*`
- **Check**: Current URL matches one of the configured redirect URLs

### Issue: "Invalid redirect URI" error
- **Solution**: Add the exact redirect URL to Supabase Dashboard → Authentication → URL Configuration
