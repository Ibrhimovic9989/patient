# NeuroTrack Setup Guide

## ✅ Completed Steps

1. ✅ Updated both apps to use common `.env` file at root (`../.env`)
2. ✅ Fixed all SQL schema syntax errors
3. ✅ Created `.env.example` template file

## 📋 Remaining Setup Steps

### 1. Install Flutter

**Windows:**
1. Download Flutter SDK from: https://docs.flutter.dev/get-started/install/windows
2. Extract to a location (e.g., `C:\src\flutter`)
3. Add Flutter to PATH:
   - Search for "Environment Variables" in Windows
   - Add `C:\src\flutter\bin` to your PATH
4. Verify installation:
   ```powershell
   flutter --version
   flutter doctor
   ```
5. Enable web support:
   ```powershell
   flutter config --enable-web
   ```

### 2. Create Your `.env` File

Copy `.env.example` to `.env` in the project root:
```powershell
Copy-Item .env.example .env
```

Then edit `.env` and fill in your actual credentials (see steps below).

### 3. Set Up Supabase Cloud

1. **Create Supabase Project:**
   - Go to https://supabase.com
   - Sign up/Login
   - Click "New Project"
   - Choose organization, name, database password, and region
   - Wait for project to be created (~2 minutes)

2. **Get Your Credentials:**
   - Go to Project Settings → API
   - Copy:
     - **Project URL** → `SUPABASE_URL` in `.env`
     - **anon public** key → `SUPABASE_ANON_KEY` in `.env`

3. **Run Database Schema:**
   - Go to SQL Editor in Supabase Dashboard
   - Copy entire contents of `supabase/schemas/schema.sql`
   - Paste into SQL Editor
   - Click "Run" (or press Ctrl+Enter)
   - Verify all tables are created (check Table Editor)

4. **Seed Assessment Data:**
   ```powershell
   cd supabase/scripts
   npm install
   # Create .env file here with:
   # SUPABASE_URL=your-project-url
   # SUPABASE_KEY=your-service-role-key (from Supabase Dashboard → Settings → API)
   node seed_assessments.js
   ```

5. **Deploy Edge Function:**
   - Install Supabase CLI (if not installed):
     ```powershell
     winget install Supabase.cli
     ```
   - Login to Supabase:
     ```powershell
     supabase login
     ```
   - Link your project:
     ```powershell
     supabase link --project-ref your-project-ref
     ```
   - Deploy function:
     ```powershell
     cd supabase/functions/evaluate-assessments
     supabase functions deploy evaluate-assessments
     ```

### 4. Set Up Google OAuth (Optional but Recommended)

1. **Google Cloud Console:**
   - Go to https://console.cloud.google.com/
   - Create a new project or select existing
   - Enable Google+ API
   - Go to "APIs & Services" → "Credentials"
   - Click "Create Credentials" → "OAuth client ID"
   - Configure OAuth consent screen first (if prompted)
   - Create OAuth client:
     - Type: Web application
     - Authorized JavaScript origins: `https://your-project-id.supabase.co`
     - Authorized redirect URIs: `https://your-project-id.supabase.co/auth/v1/callback`
   - Copy Client ID and Client Secret

2. **Configure in Supabase:**
   - Go to Supabase Dashboard → Authentication → Providers
   - Enable "Google"
   - Paste Client ID and Client Secret
   - Save

3. **Update `.env`:**
   - Add `GOOGLE_WEB_CLIENT_ID` from Google Cloud Console

### 5. Get Gemini API Key (Optional)

1. Go to https://aistudio.google.com/app/apikey
2. Create API key
3. Add to `.env` as `GEMINI_API_KEY`

### 6. Install Flutter Dependencies

```powershell
# Patient app
cd patient
flutter pub get

# Therapist app
cd ../therapist
flutter pub get
```

### 7. Run the Apps

**Patient App:**
```powershell
cd patient
flutter run -d chrome
```

**Therapist App (in another terminal):**
```powershell
cd therapist
flutter run -d chrome
```

## 🐛 Troubleshooting

### Flutter not found
- Make sure Flutter is in your PATH
- Restart terminal/PowerShell after adding to PATH
- Run `flutter doctor` to check for issues

### .env file not found
- Make sure `.env` exists in project root (not in patient/ or therapist/)
- Check that file is named exactly `.env` (not `.env.txt`)

### Supabase connection errors
- Verify `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.env`
- Check Supabase project is active (not paused)
- Ensure schema was run successfully

### Web build issues
- Run `flutter config --enable-web`
- Try `flutter clean` then `flutter pub get`
- Check browser console for errors

## 📝 Notes

- Both apps now use the same `.env` file at project root
- SQL schema has been fixed (removed trailing commas)
- Flutter web avoids Gradle/Android Studio setup issues
- You can run both apps simultaneously in different terminals
