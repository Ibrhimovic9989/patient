# Debug Patient App Sign-In Issue

## Patient App Flow After Sign-In

1. ✅ User clicks "Sign in with Google"
2. ✅ Google OAuth completes
3. ✅ User is authenticated in Supabase
4. ❓ App calls `checkIfPatientExists()` - **This might be where the 500 error happens!**

## Possible Issues

### Issue 1: Query Failing (Even with RLS Disabled)

The `checkIfPatientExists()` method queries:
```dart
.from('patient')
.select('*')
.eq('id', _supabaseClient.auth.currentUser!.id)
.maybeSingle();
```

**Check:**
- Is `auth.currentUser` null? (User might not be fully authenticated yet)
- Is the query syntax correct?

### Issue 2: Error in Other Checks

After checking if patient exists, it also checks:
- `checkIfPatientAssessmentExists()` - queries `assessment_results` table
- `checkIfPatientConsultationExists()` - queries `session` table

**One of these might be failing!**

## Debug Steps

### Step 1: Check Browser Console

1. Open patient app
2. Open DevTools (F12)
3. Go to **Console** tab
4. Try signing in
5. Look for:
   - Error messages
   - Any print statements
   - The exact error stack trace

### Step 2: Check Network Tab

1. In DevTools, go to **Network** tab
2. Clear the log
3. Try signing in
4. Look for requests with **500 status**
5. Click on the failed request
6. Check **Response** tab for error details

### Step 3: Check Supabase API Logs

1. Go to **Supabase Dashboard** → **Logs** → **API Logs**
2. Look for recent 500 errors
3. Check the error message

### Step 4: Add Debug Logging

The code should print errors, but let's verify what's happening. Check if you see:
- "Error checking if patient exists: ..." in console
- Any other error messages

## Most Likely Causes

1. **User not authenticated yet** when query runs
   - Fix: Add a delay or wait for auth state to be ready

2. **Query to `assessment_results` or `session` table failing**
   - These tables might have RLS enabled even if `patient` doesn't
   - Or they might not exist yet

3. **Null user ID**
   - `auth.currentUser` might be null right after redirect

## Quick Test

Try this in Supabase SQL Editor to see if the query works:

```sql
-- Replace with one of your user IDs from Authentication → Users
SELECT * FROM patient 
WHERE id = '5c3c4572-37af-4556-9a89-fc2751700be1';
```

If this works, the issue is in the app code (timing, null check, etc.)
