# Fix Persistent AssetManifest.json Error

## The Problem

Even after restarting, you're still getting:
```
Failed to load resource: the server responded with a status of 404 (Not Found)
Unable to load asset: "AssetManifest.json"
```

This is a Flutter web dev server issue where the build cache is corrupted.

## The Solution

The `run-patient.ps1` script has been updated to automatically clean and rebuild. Just run:

```powershell
.\run-patient.ps1
```

It will now:
1. ✅ Clean the build cache (`flutter clean`)
2. ✅ Reinstall dependencies (`flutter pub get`)
3. ✅ Run the app with a fresh build

## Manual Fix (If Script Doesn't Work)

If the script still doesn't work, try this:

1. **Stop the app** (Ctrl+C)

2. **Navigate to patient directory:**
   ```powershell
   cd patient
   ```

3. **Clean everything:**
   ```powershell
   flutter clean
   ```

4. **Delete build folder manually:**
   ```powershell
   Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
   ```

5. **Get dependencies:**
   ```powershell
   flutter pub get
   ```

6. **Build for web first:**
   ```powershell
   flutter build web
   ```

7. **Then run:**
   ```powershell
   flutter run -d chrome --web-port=50001
   ```

## Alternative: Use Release Mode

Sometimes debug mode has issues. Try release mode:

```powershell
cd patient
flutter run -d chrome --web-port=50001 --release
```

## Why This Happens

Flutter web dev server:
- Generates `AssetManifest.json` during build
- Serves it from the build directory
- Sometimes the build cache gets corrupted
- A clean rebuild fixes it

## After Fix

Once it works:
- ✅ No `AssetManifest.json` 404 errors
- ✅ Fonts load correctly
- ✅ App UI displays properly
- ✅ All assets accessible
