# Quick RLS Status Check

Run this in Supabase SQL Editor to see if RLS is the problem:

```sql
-- Check RLS status
SELECT 
    tablename, 
    CASE 
        WHEN rowsecurity THEN '⚠️ RLS ENABLED - This is likely the problem!'
        ELSE '✅ RLS DISABLED'
    END as status
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('therapist', 'patient');

-- Check if policies exist
SELECT 
    tablename,
    COUNT(*) as policy_count,
    STRING_AGG(cmd::text, ', ') as operations
FROM pg_policies
WHERE tablename IN ('therapist', 'patient')
GROUP BY tablename;
```

## What to Look For:

### Scenario 1: RLS Enabled, No Policies
```
tablename | status
----------|----------------------------------------
therapist | ⚠️ RLS ENABLED - This is likely the problem!
patient   | ⚠️ RLS ENABLED - This is likely the problem!

policy_count: 0 (or empty result)
```
**This means:** RLS is blocking all operations. You need to create policies!

### Scenario 2: RLS Enabled, Policies Exist
```
tablename | status
----------|----------------------------------------
therapist | ⚠️ RLS ENABLED
patient   | ⚠️ RLS ENABLED

policy_count: 2-4 per table
operations: SELECT, INSERT, UPDATE
```
**This means:** Policies exist but might not allow INSERT. Check the policy details.

### Scenario 3: RLS Disabled
```
tablename | status
----------|------------------
therapist | ✅ RLS DISABLED
patient   | ✅ RLS DISABLED
```
**This means:** RLS is not the problem. The issue is something else (missing fields, wrong data format, etc.)

## Also Check Supabase Logs

While you're at it, check the actual error:
1. Go to **Supabase Dashboard** → **Logs** → **Postgres Logs**
2. Look for the most recent error
3. Copy the error message

Common error messages:
- `"new row violates row-level security policy"` → RLS is blocking
- `"null value in column X violates not-null constraint"` → Missing required field
- `"permission denied for table X"` → RLS or permissions issue
