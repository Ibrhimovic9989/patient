# Fix 500 Error After Sign-In

## Problem
After signing in with Google, you get a 500 error when the app tries to create records in `therapist` or `patient` tables.

## Root Cause
Supabase has **Row Level Security (RLS)** enabled by default, which blocks all database operations unless policies are explicitly defined.

## Solution

### Step 1: Run RLS Policies SQL

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Copy the entire contents of `supabase/schemas/rls_policies.sql`
3. Paste it into the SQL Editor
4. Click **Run** (or press Ctrl+Enter)

This will:
- Enable RLS on all tables
- Create policies that allow authenticated users to:
  - Insert their own records in `therapist` and `patient` tables
  - View and update their own records
  - View related records (therapists can see their patients, etc.)

### Step 2: Verify Policies

After running the SQL:
1. Go to **Supabase Dashboard** → **Authentication** → **Policies**
2. You should see policies for `therapist` and `patient` tables
3. Each table should have policies for SELECT, INSERT, and UPDATE

### Step 3: Test Again

1. Sign out from your apps
2. Sign in again with Google
3. The 500 error should be gone!

## What These Policies Do

- **Users can insert their own records**: When you sign in, the app can create your `therapist` or `patient` record
- **Users can view their own records**: You can only see your own data
- **Therapists can view their patients**: Therapists can see patient records they're assigned to
- **Public read access**: Reference tables (assessments, therapies, etc.) are readable by everyone

## Troubleshooting

If you still get errors:

1. **Check Supabase Logs**:
   - Go to **Supabase Dashboard** → **Logs** → **Postgres Logs**
   - Look for the actual error message

2. **Verify User Authentication**:
   - Make sure you're actually signed in
   - Check that `auth.uid()` returns your user ID

3. **Check Required Fields**:
   - Make sure the app is providing all required fields (name, email, phone, etc.)

4. **Verify Policies Were Created**:
   - Go to **Table Editor** → Select a table → **Policies** tab
   - You should see the policies listed

## Next Steps

After fixing this, users should be able to:
- Sign in with Google ✅
- Create their profile in `therapist` or `patient` table ✅
- Access the app without 500 errors ✅
