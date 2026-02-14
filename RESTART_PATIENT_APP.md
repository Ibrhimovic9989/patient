# Restart Patient App - AssetManifest.json Error

## The Problem

The patient app is showing:
```
Failed to load resource: the server responded with a status of 404 (Not Found)
Unable to load asset: "AssetManifest.json"
```

This means the Flutter web dev server needs to be restarted.

## Quick Fix

1. **Stop the current app** (press `Ctrl+C` in the terminal where it's running)

2. **Restart the patient app:**
   ```powershell
   .\run-patient.ps1
   ```

   OR manually:
   ```powershell
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
   cd patient
   flutter run -d chrome --web-port=50001
   ```

3. **Wait for the app to fully load** - You should see:
   - "Launching lib\main.dart on Chrome in debug mode..."
   - Chrome browser opens automatically
   - No 404 errors in console

## Why This Happens

The Flutter web dev server needs to:
1. Build the app
2. Generate `AssetManifest.json`
3. Serve assets from the correct path

Sometimes the dev server gets into a bad state and needs a restart.

## After Restart

Once the app loads properly:
1. ✅ No `AssetManifest.json` errors
2. ✅ No font loading errors
3. ✅ App UI displays correctly
4. ✅ You can use the app normally
