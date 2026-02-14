# Debug 500 Error - Step by Step

Let's find the exact root cause before applying any fixes.

## Step 1: Check Supabase Logs (Most Important!)

1. **Go to Supabase Dashboard**
   - Navigate to: **Logs** → **Postgres Logs** (or **API Logs**)
   - Look for recent errors around the time you tried to sign in

2. **What to look for:**
   - Error messages mentioning "permission denied"
   - Error messages mentioning "row-level security"
   - Error messages mentioning "policy"
   - The exact SQL query that failed

3. **Copy the error message** - This will tell us exactly what's wrong

## Step 2: Check Browser Console

1. **Open your Flutter app in Chrome**
2. **Open DevTools** (F12 or Right-click → Inspect)
3. **Go to Console tab**
4. **Try signing in again**
5. **Look for:**
   - The exact error message
   - Any print statements from the app (like "Storing therapist data with ID: ...")
   - Network errors in the Network tab

## Step 3: Check if RLS is Enabled

Run this SQL in Supabase SQL Editor:

```sql
-- Check if RLS is enabled on therapist table
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('therapist', 'patient');
```

**Expected results:**
- If `rowsecurity = true` → RLS is enabled (this is likely the problem!)
- If `rowsecurity = false` → RLS is disabled (problem is something else)

## Step 4: Check Existing Policies

Run this SQL:

```sql
-- Check existing policies
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename IN ('therapist', 'patient')
ORDER BY tablename, policyname;
```

**What this tells us:**
- If no rows returned → No policies exist (RLS is blocking everything!)
- If policies exist → Check if they allow INSERT operations

## Step 5: Test the Insert Manually

Try inserting a test record directly in Supabase:

1. **Go to Table Editor** → Select `therapist` table
2. **Click "Insert row"**
3. **Fill in required fields:**
   - `id`: Use one of your user IDs from the Users table
   - `name`: "Test User"
   - `email`: "test@example.com"
   - `phone`: "1234567890"
4. **Click Save**

**What happens:**
- ✅ If it works → The problem is in the app code (wrong data format, missing fields, etc.)
- ❌ If it fails → The problem is RLS or database permissions

## Step 6: Check What Data the App is Sending

Add this temporary debug code to see what's being sent:

In `therapist/lib/repository/supabase_auth_repository.dart` around line 126, add:

```dart
print("=== DEBUG: Attempting to insert ===");
print("User ID: ${currentUser.id}");
print("Data being inserted: $data");
print("Data keys: ${data.keys}");
print("Data values: ${data.values}");
```

Then check the browser console when you try to sign in.

## Step 7: Check Required Fields

Compare what the app sends vs what the table requires:

**Therapist table requires:**
- `id` (UUID, PRIMARY KEY)
- `name` (TEXT, NOT NULL)
- `email` (TEXT, NOT NULL)  
- `phone` (TEXT, NOT NULL)

**Check if the app is providing all of these!**

## Common Issues Found:

### Issue 1: RLS Enabled, No Policies
**Symptom:** Error says "permission denied" or "new row violates row-level security"
**Solution:** Need to create RLS policies

### Issue 2: Missing Required Fields
**Symptom:** Error says "null value in column X violates not-null constraint"
**Solution:** App needs to provide all required fields

### Issue 3: Foreign Key Constraint
**Symptom:** Error mentions foreign key violation
**Solution:** Related record doesn't exist yet

### Issue 4: Wrong Data Type
**Symptom:** Error mentions type mismatch
**Solution:** Data format doesn't match column type

## Next Steps

After running these checks, share:
1. The exact error from Supabase logs
2. Whether RLS is enabled
3. Whether policies exist
4. What happens when you try to insert manually

Then we can create a targeted fix! 🎯
