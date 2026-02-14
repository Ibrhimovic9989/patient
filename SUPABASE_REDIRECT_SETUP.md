# Supabase Redirect URLs Setup for Flutter Web

## Problem
Flutter web apps run on random ports (usually 50000+), but Supabase is configured to redirect to `http://localhost:3000`.

## Solution

### Option 1: Use Wildcards (Recommended for Development)

In Supabase Dashboard → Authentication → URL Configuration:

1. **Site URL:** Keep as `http://localhost:3000` (or change to a wildcard)
2. **Redirect URLs:** Add these:
   ```
   http://localhost:*
   http://127.0.0.1:*
   ```

This allows redirects to any localhost port.

### Option 2: Use Fixed Ports (Recommended for Production)

Update the run scripts to use fixed ports, then add specific URLs to Supabase.

**For Patient App:**
- Run on port `50001`
- Add to Supabase: `http://localhost:50001`

**For Therapist App:**
- Run on port `50002`  
- Add to Supabase: `http://localhost:50002`

## Quick Fix Steps

1. Go to Supabase Dashboard → Authentication → URL Configuration
2. Under **Redirect URLs**, click **Add URL**
3. Add: `http://localhost:*`
4. Click **Save changes**

Now your Flutter web apps will work on any port!
