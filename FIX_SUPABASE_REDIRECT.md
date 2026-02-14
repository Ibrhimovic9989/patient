# Fix Supabase Redirect Issue

## The Problem

Supabase is redirecting to `http://localhost:3000` (the Site URL), but:
- Patient app runs on `http://localhost:50001`
- Therapist app runs on `http://localhost:50002`
- Nothing is running on port 3000 → `ERR_CONNECTION_REFUSED`

## The Solution

**Update Supabase Site URL:**

1. Go to **Supabase Dashboard** → **Authentication** → **URL Configuration**

2. **Change the Site URL** from:
   ```
   http://localhost:3000
   ```
   to:
   ```
   http://localhost:50001
   ```
   (Use patient app port as default, or therapist port `50002` - doesn't matter much since redirect URLs handle both)

3. **Keep Redirect URLs as:**
   ```
   http://localhost:*
   ```
   (This already allows both ports)

4. Click **"Save changes"**

## Why This Works

- **Site URL** is the default redirect when no specific redirect URL matches
- **Redirect URLs** (`http://localhost:*`) allows any port, but Site URL might take precedence
- By setting Site URL to an actual app port, Supabase will redirect correctly

## Alternative Solution (If Site URL can't be changed)

If you can't change Site URL, you can:
1. Add specific redirect URLs:
   - `http://localhost:50001`
   - `http://localhost:50002`
2. Make sure `http://localhost:*` is also in the list

## After Fixing

1. Restart both Flutter apps
2. Try signing in again
3. Should redirect to the correct port with the OAuth code
4. App should handle the OAuth callback properly
