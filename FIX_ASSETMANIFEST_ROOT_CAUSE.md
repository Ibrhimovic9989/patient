# Root Cause Analysis: AssetManifest.json 404 Error

## The Problem

Flutter web dev server in debug mode doesn't always generate `AssetManifest.json` properly. The build creates `AssetManifest.bin.json`, but the runtime expects `AssetManifest.json`.

## Root Cause

1. **Base href issue**: `$FLUTTER_BASE_HREF` placeholder not replaced in dev mode
2. **Dev server limitation**: Debug mode doesn't always generate the manifest file
3. **Build vs Run mismatch**: `flutter run` doesn't always trigger a full web build

## The Fix

### ✅ Fixed Files

1. **`patient/web/index.html`**: Changed `<base href="$FLUTTER_BASE_HREF">` to `<base href="/">`
2. **`run-patient.ps1`**: Now builds for web first, then runs

### What Changed

**Before:**
- `flutter run` → Dev server starts → No AssetManifest.json → 404 error

**After:**
- `flutter build web` → Generates proper web build with AssetManifest.json
- `flutter run` → Uses the built assets → Works!

## How to Use

Just run:
```powershell
.\run-patient.ps1
```

The script now:
1. ✅ Cleans build cache
2. ✅ Gets dependencies
3. ✅ **Builds for web** (generates AssetManifest.json)
4. ✅ Runs the app (uses the built assets)

## Why This Works

- `flutter build web` creates a complete web build with all assets
- The dev server then serves from this build directory
- AssetManifest.json is properly generated and accessible

## Alternative: Use Release Mode

If you want faster startup (but no hot reload):
```powershell
cd patient
flutter run -d chrome --web-port=50001 --release
```

Release mode always works because it does a full build first.

## Verification

After running the updated script:
- ✅ No `AssetManifest.json` 404 errors
- ✅ Fonts load correctly
- ✅ All assets accessible
- ✅ App works normally
