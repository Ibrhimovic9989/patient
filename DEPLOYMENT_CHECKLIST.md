# SaaS Implementation - Deployment Checklist

## ⚠️ IMPORTANT: Run in Order

Execute these SQL queries and deploy edge functions **in the exact order listed** to avoid foreign key constraint errors.

## 📋 SQL Queries to Run (Supabase SQL Editor)

### Step 1: Create Clinic Table
**File:** `supabase/schemas/clinic_tables.sql`

**Location:** Supabase Dashboard → SQL Editor → New Query

**Copy and paste the entire contents of:**
```
supabase/schemas/clinic_tables.sql
```

**What it does:**
- Creates `clinic` table
- Adds indexes for performance

---

### Step 2: Create Clinic Subscription Table
**File:** `supabase/schemas/clinic_subscription.sql`

**Location:** Supabase Dashboard → SQL Editor → New Query

**Copy and paste the entire contents of:**
```
supabase/schemas/clinic_subscription.sql
```

**What it does:**
- Creates `clinic_subscription` table for SaaS billing
- Tracks subscription status, tiers, expiry dates

---

### Step 3: Update Patient Table
**File:** `supabase/schemas/update_patient_table.sql`

**Location:** Supabase Dashboard → SQL Editor → New Query

**Copy and paste the entire contents of:**
```
supabase/schemas/update_patient_table.sql
```

**What it does:**
- Adds `clinic_id` column to `patient` table
- Creates index for performance

---

### Step 4: Expand Package Table
**File:** `supabase/schemas/expand_package_table.sql`

**Location:** Supabase Dashboard → SQL Editor → New Query

**Copy and paste the entire contents of:**
```
supabase/schemas/expand_package_table.sql
```

**What it does:**
- Adds clinic-specific fields to `package` table
- Creates `package_therapy_details` table
- Creates `patient_package` table

---

### Step 5: Update Therapist Table
**File:** `supabase/schemas/update_therapist_table.sql`

**Location:** Supabase Dashboard → SQL Editor → New Query

**Copy and paste the entire contents of:**
```
supabase/schemas/update_therapist_table.sql
```

**What it does:**
- Adds foreign key constraint for `clinic_id`
- Creates index for performance

**⚠️ Note:** If you have existing therapists without `clinic_id`, you'll need to assign them first or make this nullable temporarily.

---

### Step 6: Add Clinic ID to Related Tables
**File:** `supabase/schemas/add_clinic_id_to_tables.sql`

**Location:** Supabase Dashboard → SQL Editor → New Query

**Copy and paste the entire contents of:**
```
supabase/schemas/add_clinic_id_to_tables.sql
```

**What it does:**
- Adds `clinic_id` to `session` table
- Adds `clinic_id` to `therapy_goal` table
- Adds `clinic_id` to `daily_activities` table
- Creates indexes for performance

---

### Step 7: Create RLS Policies for Clinic Isolation
**File:** `supabase/schemas/clinic_rls_policies.sql`

**Location:** Supabase Dashboard → SQL Editor → New Query

**Copy and paste the entire contents of:**
```
supabase/schemas/clinic_rls_policies.sql
```

**What it does:**
- Enables RLS on new tables
- Creates policies for clinic data isolation
- Ensures multi-tenancy security

**⚠️ Important:** Review policies before running. Some may need adjustment based on your auth setup.

---

## 🔧 Edge Functions to Deploy

### Step 8: Deploy Check Clinic Subscription Function
**File:** `supabase/functions/check-clinic-subscription/index.ts`

**Location:** Supabase Dashboard → Edge Functions → Deploy

**Method 1: Via Supabase Dashboard**
1. Go to **Supabase Dashboard → Edge Functions**
2. Click **Create a new function**
3. Name it: `check-clinic-subscription`
4. Copy entire contents of `supabase/functions/check-clinic-subscription/index.ts`
5. Paste into editor
6. Click **Deploy**

**Method 2: Via CLI**
```bash
supabase functions deploy check-clinic-subscription
```

**What it does:**
- Checks if clinic has active subscription
- Returns subscription status and expiry
- Used to block access for expired subscriptions

---

### Step 9: Verify Evaluate Assessments Function
**File:** `supabase/functions/evaluate-assessments/index.ts`

**Status:** Already deployed (with CORS fixes)

**Verify it's deployed:**
- Go to **Supabase Dashboard → Edge Functions**
- Check if `evaluate-assessments` exists
- If not, deploy it using the same method as above

---

## 📝 Quick Reference: File Paths

### SQL Files (Run in Supabase SQL Editor):
1. `supabase/schemas/clinic_tables.sql`
2. `supabase/schemas/clinic_subscription.sql`
3. `supabase/schemas/update_patient_table.sql`
4. `supabase/schemas/expand_package_table.sql`
5. `supabase/schemas/update_therapist_table.sql`
6. `supabase/schemas/add_clinic_id_to_tables.sql`
7. `supabase/schemas/clinic_rls_policies.sql`

### Edge Functions (Deploy via Dashboard or CLI):
1. `supabase/functions/check-clinic-subscription/index.ts` (NEW)
2. `supabase/functions/evaluate-assessments/index.ts` (Verify/Update)

---

## ✅ Verification Steps

After running all queries:

1. **Check Tables Created:**
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public' 
   AND table_name IN ('clinic', 'clinic_subscription', 'package_therapy_details', 'patient_package');
   ```

2. **Check Columns Added:**
   ```sql
   SELECT column_name, table_name 
   FROM information_schema.columns 
   WHERE column_name = 'clinic_id' 
   AND table_schema = 'public';
   ```

3. **Check RLS Enabled:**
   ```sql
   SELECT tablename, rowsecurity 
   FROM pg_tables 
   WHERE schemaname = 'public' 
   AND tablename IN ('clinic', 'clinic_subscription', 'package_therapy_details', 'patient_package');
   ```

4. **Test Edge Functions:**
   - Go to Edge Functions → `check-clinic-subscription` → Invoke
   - Test with: `{"clinic_id": "your-clinic-id"}`

---

## 🚨 Important Notes

1. **Backup First:** Always backup your database before running migrations
2. **Test Environment:** Test in a development environment first
3. **Existing Data:** If you have existing therapists/patients, you may need to:
   - Assign them to clinics manually, OR
   - Make `clinic_id` nullable temporarily
4. **RLS Policies:** Review RLS policies and adjust based on your auth setup
5. **Edge Functions:** Ensure CORS headers are included (already done in code)

---

## 📞 Need Help?

If any query fails:
1. Check error message
2. Verify previous steps completed successfully
3. Check for foreign key constraint errors
4. Ensure all referenced tables exist
