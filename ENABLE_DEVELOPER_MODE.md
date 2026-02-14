# Enable Developer Mode (Windows)

## The Issue

Flutter build shows:
```
Building with plugins requires symlink support.
Please enable Developer Mode in your system settings.
```

## The Fix

**Enable Developer Mode on Windows:**

1. **Open Windows Settings:**
   - Press `Win + I` OR
   - Run: `start ms-settings:developers`

2. **Navigate to:**
   - Settings → Privacy & Security → For developers
   - OR Settings → Update & Security → For developers

3. **Enable Developer Mode:**
   - Toggle "Developer Mode" to **ON**
   - Accept any prompts/restarts if needed

4. **Restart your terminal/PowerShell** after enabling

## Why This Is Needed

Flutter uses symlinks (symbolic links) for:
- Plugin dependencies
- Asset linking
- Build optimization

Windows requires Developer Mode to create symlinks without admin privileges.

## After Enabling

Run the script again:
```powershell
.\run-patient.ps1
```

The build should now work without the symlink error.
