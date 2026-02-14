# Quick Fix: Supabase Redirect URLs

## Current Issue
You're being redirected to `http://localhost:3000` but Flutter web runs on different ports.

## Immediate Fix (2 minutes)

1. **Open Supabase Dashboard**
   - Go to: https://supabase.com/dashboard
   - Select your project
   - Go to: **Authentication** → **URL Configuration**

2. **Add Wildcard Redirect URL**
   - Under **Redirect URLs** section
   - Click **Add URL** button
   - Enter: `http://localhost:*`
   - Click **Save changes**

3. **Also add 127.0.0.1 (optional but recommended)**
   - Click **Add URL** again
   - Enter: `http://127.0.0.1:*`
   - Click **Save changes**

## Why This Works
- `*` is a wildcard that matches any port number
- Flutter web uses random ports (50000+)
- This allows OAuth redirects to work on any port

## After This Fix
- Restart your Flutter apps
- Try signing in again
- It should redirect back to your app correctly!

## Alternative: Fixed Ports
If you prefer specific ports, the run scripts now use:
- Patient app: `http://localhost:50001`
- Therapist app: `http://localhost:50002`

Add these specific URLs to Supabase if you use fixed ports.
