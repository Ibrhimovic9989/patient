# Fix Assessments Table & Restart App

## Issue 1: AssetManifest.json Error

**Quick Fix - Restart the Patient App:**

1. **Stop the current app** (press `Ctrl+C` in the terminal)
2. **Restart:**
   ```powershell
   .\run-patient.ps1
   ```

## Issue 2: Assessments Table is Empty

You need to seed the `assessments` table with assessment data (AQ-10, CAT-Q, etc.).

### Option 1: Using Node.js Script (Recommended)

1. **Navigate to scripts directory:**
   ```powershell
   cd supabase\scripts
   ```

2. **Install dependencies:**
   ```powershell
   npm install
   ```

3. **Create/Update `.env` file in `supabase/scripts/` directory:**
   ```env
   SUPABASE_URL=https://ouzgddcxfynjhwjnvdtb.supabase.co
   SUPABASE_KEY=your-service-role-key-here
   ```
   ⚠️ **Important:** Use the **Service Role Key** (not anon key) from:
   - Supabase Dashboard → Settings → API → `service_role` key (secret)

4. **Run the seed script:**
   ```powershell
   node seed_assessments.js
   ```

### Option 2: Manual SQL Insert (Alternative)

If Node.js doesn't work, you can insert data directly via SQL Editor:

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Copy the assessment data from `supabase/scripts/seed_assessments.js`
3. Convert it to SQL INSERT statements
4. Run the SQL

### Option 3: Quick SQL Seed (Simplified)

I can create a simplified SQL script with just the essential assessments. Let me know if you want this!

## Verify

After seeding:

1. Go to **Supabase Dashboard** → **Table Editor** → `assessments`
2. You should see at least 2 assessments:
   - **AQ-10** (Autism Spectrum Quotient)
   - **CAT-Q** (Camouflaging Autistic Traits Questionnaire)

## What Gets Seeded

The script adds:
- Assessment templates with questions
- Multiple choice options for each question
- Scoring information
- Cutoff scores for autism detection

## Troubleshooting

- **"Invalid API key"** → Use `service_role` key, not `anon` key
- **"supabaseKey is required"** → Check `.env` file in `supabase/scripts/` directory
- **"Module not found"** → Run `npm install` in `supabase/scripts/`
