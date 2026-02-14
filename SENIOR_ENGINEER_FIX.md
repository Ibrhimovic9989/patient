# Senior Engineer Analysis & Fix: AssetManifest.json 404

## Root Cause Analysis

### The Problem
```
GET http://localhost:50001/assets/AssetManifest.json 404 (Not Found)
Unable to load asset: "AssetManifest.json"
```

### Why It Persists
1. **Base href placeholder**: `$FLUTTER_BASE_HREF` in `index.html` isn't replaced in dev mode
2. **Dev server limitation**: `flutter run` doesn't always generate `AssetManifest.json`
3. **Build mismatch**: Dev mode uses `AssetManifest.bin.json`, but runtime expects `AssetManifest.json`

### The Fix (3 Changes)

#### 1. Fixed Base Href
**File**: `patient/web/index.html` & `therapist/web/index.html`
- Changed: `<base href="$FLUTTER_BASE_HREF">` → `<base href="/">`
- Why: Explicit base path ensures assets load from root

#### 2. Build Before Run
**File**: `run-patient.ps1` & `run-therapist.ps1`
- Added: `flutter build web --web-renderer canvaskit` before `flutter run`
- Why: Ensures `AssetManifest.json` is generated before dev server starts

#### 3. Clean Build Process
- Script now: Clean → Get deps → Build web → Run
- Why: Fresh build guarantees proper asset generation

## How to Use

**Just run the script:**
```powershell
.\run-patient.ps1
```

The script now automatically:
1. Cleans build cache
2. Gets dependencies  
3. **Builds for web** (generates AssetManifest.json)
4. Runs the app

## Technical Details

### Why `flutter build web` First?
- `flutter run` in debug mode uses incremental builds
- Sometimes skips generating `AssetManifest.json`
- `flutter build web` does a complete build
- Generates all required files including `AssetManifest.json`

### Why Fixed Base Href?
- `$FLUTTER_BASE_HREF` is a placeholder for production builds
- In dev mode, it might not be replaced
- Explicit `/` ensures assets load from root path
- Works in both dev and production

## Verification

After running:
- ✅ No `AssetManifest.json` 404 errors
- ✅ Fonts load (Poppins-Regular, Bold, Medium, SemiBold)
- ✅ All assets accessible
- ✅ App UI renders correctly

## If Still Not Working

Try this nuclear option:
```powershell
cd patient
Remove-Item -Recurse -Force build -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force .dart_tool -ErrorAction SilentlyContinue
flutter clean
flutter pub get
flutter build web --web-renderer canvaskit
flutter run -d chrome --web-port=50001
```

This removes ALL build artifacts and starts completely fresh.
