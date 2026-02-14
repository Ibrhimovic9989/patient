# Fix Assessments Loading & AssetManifest Error

## Issue 1: AssetManifest.json 404 Error

**This is a Flutter web dev server issue. Fix it by:**

1. **Stop the current app** (press `Ctrl+C` in the terminal)
2. **Clear Flutter build cache:**
   ```powershell
   cd patient
   flutter clean
   flutter pub get
   ```
3. **Restart the app:**
   ```powershell
   cd ..
   .\run-patient.ps1
   ```

## Issue 2: Assessments Not Loading (HTTP request failed, statusCode: 0)

The assessments table is empty. You need to seed it with data.

### Quick Fix: Run SQL Seed Script

1. **Go to Supabase Dashboard** → **SQL Editor**
2. **Open** `supabase/schemas/seed_assessments.sql`
3. **Copy the entire contents** and paste into SQL Editor
4. **Click "Run"**

This will insert:
- **AQ-10** (10 questions) - Autism Spectrum Quotient
- **CAT-Q** (5 questions) - Camouflaging Autistic Traits Questionnaire

### Verify

After running the SQL:
1. Go to **Supabase Dashboard** → **Table Editor** → `assessments`
2. You should see 2 assessments

### Image URLs Fixed

The seed script now uses `NULL` for `image_url` instead of broken URLs. Images can be added later via Supabase Storage.

## After Both Fixes

1. **Restart the patient app** (to fix AssetManifest.json)
2. **Refresh the browser** (to load new assessments)
3. The assessments should now load without errors!

## Troubleshooting

- **Still seeing "HTTP request failed"** → Check if assessments were actually inserted in Supabase Table Editor
- **AssetManifest.json still 404** → Try `flutter clean` and restart
- **Assessments show but images are broken** → This is expected - images can be uploaded to Supabase Storage later
