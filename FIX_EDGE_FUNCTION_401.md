# CRITICAL FIX: Edge Function 401 Error

## Root Cause
The POST request is NOT reaching the Edge Function code. Only OPTIONS requests are logged. This means **Supabase's middleware is rejecting the POST request BEFORE your function code executes**.

## The Problem
Supabase Edge Functions have built-in JWT verification that happens at the middleware level. If this verification fails, the function code never runs and you get a 401 error.

## Solution: Disable JWT Verification in Dashboard

**You MUST do this in the Supabase Dashboard:**

1. Go to **Supabase Dashboard** → **Edge Functions** → `schedule-package-sessions`
2. Click on **"Settings"** or **"Configuration"** tab
3. Find **"Verify JWT"** or **"JWT Verification"** setting
4. **DISABLE IT** (set to `false` or uncheck it)
5. **Save** the settings
6. **Redeploy** the function (even if code hasn't changed)

## Alternative: If Settings Don't Exist

If you can't find the JWT verification setting, you need to configure it via `config.toml`:

Add this to `supabase/config.toml`:

```toml
[functions.schedule-package-sessions]
enabled = true
verify_jwt = false  # <-- THIS IS THE KEY
```

Then redeploy via CLI:
```powershell
supabase functions deploy schedule-package-sessions
```

## Why This Works

- The JWT is valid (we can see it in the logs)
- But Supabase middleware is rejecting it before your code runs
- Disabling JWT verification at the middleware level allows the request to reach your code
- Your code can then validate the JWT manually if needed (but we're using service role key, so we don't need to)

## After Fixing

1. ✅ Disable JWT verification in Dashboard or config.toml
2. ✅ Redeploy the function
3. ✅ Test the schedule save again
4. ✅ Check Edge Function logs - you should now see POST requests reaching your code

## Verification

After fixing, you should see in the Edge Function logs:
- `🚀 FUNCTION CALLED AT: [timestamp]`
- `Method: POST` (not just OPTIONS)
- `=== PROCESSING REQUEST ===`
- All the debug logs we added

If you still only see OPTIONS requests, the middleware is still blocking POST requests.
