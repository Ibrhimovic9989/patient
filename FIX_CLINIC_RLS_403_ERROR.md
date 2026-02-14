# Fix Clinic RLS 403 Permission Error

## Problem

The clinic app is getting a `403 permission denied for table users` error when trying to query the `clinic` table. This is because RLS policies are trying to access `auth.users` table, which is not accessible from RLS policies.

## Solution

Replace all `auth.users` queries in RLS policies with JWT email extraction using `(auth.jwt() ->> 'email')::text`.

## Quick Fix

Run this SQL in **Supabase SQL Editor**:

**File:** `supabase/schemas/fix_clinic_rls_auth_users.sql`

Copy the entire file contents and run it.

## What This Does

1. **Drops existing policies** that use `auth.users`
2. **Recreates policies** using JWT email extraction:
   - `(auth.jwt() ->> 'email')::text` instead of `(SELECT email FROM auth.users WHERE id = auth.uid())`
3. **Fixes all clinic-related policies**:
   - Clinic table
   - Clinic subscription
   - Patient (clinic admin access)
   - Therapist (clinic admin access)
   - Package (clinic admin access)
   - Package therapy details
   - Patient package

## After Running

1. **Refresh the clinic app** (hot reload or restart)
2. **Sign in with Google** using `excellencecircle91@gmail.com`
3. **Should work** - no more 403 errors!

## Why This Works

- JWT tokens contain the user's email
- `auth.jwt() ->> 'email'` extracts it directly from the token
- No need to query `auth.users` table
- More efficient and secure
