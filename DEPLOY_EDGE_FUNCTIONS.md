# Deploy Edge Functions - Step by Step

## Edge Functions to Deploy

### 1. Check Clinic Subscription (NEW)
**File:** `supabase/functions/check-clinic-subscription/index.ts`

### 2. Evaluate Assessments (Verify/Update)
**File:** `supabase/functions/evaluate-assessments/index.ts`

---

## Method 1: Deploy via Supabase Dashboard (Recommended)

### Deploy Check Clinic Subscription Function

1. **Go to Supabase Dashboard:**
   - https://supabase.com/dashboard
   - Select your project
   - Click **Edge Functions** in left sidebar

2. **Create New Function:**
   - Click **Create a new function** button
   - Name: `check-clinic-subscription`
   - Click **Create**

3. **Copy Function Code:**
   - Open file: `supabase/functions/check-clinic-subscription/index.ts`
   - Copy **ALL contents** of the file
   - Paste into the editor in Supabase Dashboard

4. **Deploy:**
   - Click **Deploy** button
   - Wait for deployment to complete
   - Should see "Function deployed successfully"

5. **Test:**
   - Click **Invoke function** tab
   - Use test payload:
     ```json
     {
       "clinic_id": "your-clinic-uuid-here"
     }
     ```
   - Click **Invoke**
   - Should return subscription status

---

### Verify/Update Evaluate Assessments Function

1. **Check if Function Exists:**
   - Go to **Edge Functions**
   - Look for `evaluate-assessments`

2. **If Exists:**
   - Click on it
   - Verify it has CORS headers (check code)
   - If missing CORS, update with latest code from `supabase/functions/evaluate-assessments/index.ts`

3. **If Not Exists:**
   - Create new function: `evaluate-assessments`
   - Copy contents from `supabase/functions/evaluate-assessments/index.ts`
   - Deploy

---

## Method 2: Deploy via Supabase CLI

### Prerequisites:
```bash
# Install Supabase CLI (if not installed)
scoop install supabase
# OR
npm install -g supabase
```

### Deploy Steps:

1. **Login to Supabase:**
   ```bash
   supabase login
   ```

2. **Link Project:**
   ```bash
   cd C:\Users\camun\Documents\pts\NeuroTrack
   supabase link --project-ref YOUR_PROJECT_REF
   ```
   Find project ref in: Dashboard → Settings → General → Reference ID

3. **Deploy Functions:**
   ```bash
   # Deploy check-clinic-subscription
   supabase functions deploy check-clinic-subscription
   
   # Deploy/Update evaluate-assessments
   supabase functions deploy evaluate-assessments
   ```

---

## Function Details

### check-clinic-subscription

**Purpose:** Check if clinic has active subscription

**Endpoint:** `https://YOUR_PROJECT.supabase.co/functions/v1/check-clinic-subscription`

**Request:**
```json
{
  "clinic_id": "uuid-here"
}
```

**Response (Active):**
```json
{
  "has_active_subscription": true,
  "subscription": {
    "id": "uuid",
    "tier": "premium",
    "starts_at": "2024-01-01T00:00:00Z",
    "expires_at": "2025-01-01T00:00:00Z",
    "days_remaining": 180
  }
}
```

**Response (Expired/None):**
```json
{
  "has_active_subscription": false,
  "message": "Subscription has expired"
}
```

### evaluate-assessments

**Purpose:** Evaluate assessment results (already deployed with CORS fixes)

**Endpoint:** `https://YOUR_PROJECT.supabase.co/functions/v1/evaluate-assessments`

**Status:** Should already be deployed, just verify CORS headers are present

---

## Verification Checklist

- [ ] `check-clinic-subscription` function deployed
- [ ] `evaluate-assessments` function exists and has CORS headers
- [ ] Both functions can be invoked from Dashboard
- [ ] CORS headers present in responses
- [ ] Functions return expected responses

---

## Troubleshooting

### "Function not found"
- Ensure function name matches exactly
- Check you're in the correct project

### "CORS error"
- Verify CORS headers in function code
- Check `Access-Control-Allow-Origin: *` is present

### "Module not found"
- Ensure imports use `jsr:@supabase/supabase-js@2`
- Check all dependencies are available
