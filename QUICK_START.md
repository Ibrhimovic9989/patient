# Quick Start Guide

## Prerequisites Check
- [ ] Flutter installed (`flutter --version`)
- [ ] Flutter web enabled (`flutter config --enable-web`)
- [ ] Supabase account created
- [ ] Google Cloud Console account (for OAuth)

## Fast Setup (5 Steps)

### 1. Run Setup Script
```powershell
.\setup.ps1
```
This will:
- Check Flutter installation
- Create `.env` file if missing
- Enable Flutter web
- Install dependencies for both apps

### 2. Set Up Supabase Cloud
1. Create project at https://supabase.com
2. Get credentials from Project Settings → API
3. Run SQL schema:
   - Go to SQL Editor
   - Copy/paste `supabase/schemas/schema.sql`
   - Click Run
4. Update `.env` with your Supabase credentials

### 3. Configure Google OAuth (Optional)
1. Create OAuth client in Google Cloud Console
2. Add redirect URI: `https://your-project-id.supabase.co/auth/v1/callback`
3. Enable Google provider in Supabase Dashboard
4. Add `GOOGLE_WEB_CLIENT_ID` to `.env`

### 4. Get Gemini API Key (Optional)
1. Visit https://aistudio.google.com/app/apikey
2. Create API key
3. Add to `.env` as `GEMINI_API_KEY`

### 5. Run the Apps
```powershell
# Terminal 1 - Patient App
cd patient
flutter run -d chrome

# Terminal 2 - Therapist App  
cd therapist
flutter run -d chrome
```

## What's Already Done ✅
- ✅ Both apps configured to use common `.env` at root
- ✅ SQL schema syntax errors fixed
- ✅ Setup script created
- ✅ Setup guide created

## Need Help?
See `SETUP_GUIDE.md` for detailed instructions.
