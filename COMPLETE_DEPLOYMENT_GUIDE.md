# Complete Deployment Guide - SaaS Implementation

## 📋 Overview

This guide provides **direct file paths** and **step-by-step instructions** to deploy the SaaS multi-tenant clinic platform.

---

## Part 1: SQL Queries (Run in Supabase SQL Editor)

### Access SQL Editor:
1. Go to: **https://supabase.com/dashboard**
2. Select your project: `ouzgddcxfynjhwjnvdtb`
3. Click **SQL Editor** → **New Query**

### Execution Order (MUST follow this order):

#### ✅ Query 1: Create Clinic Table
**File Path:** `supabase/schemas/clinic_tables.sql`

**Action:**
1. Open file: `supabase/schemas/clinic_tables.sql`
2. Copy **entire file contents**
3. Paste into Supabase SQL Editor
4. Click **Run** (Ctrl+Enter)
5. Verify: "Success. No rows returned"

---

#### ✅ Query 2: Create Clinic Subscription Table
**File Path:** `supabase/schemas/clinic_subscription.sql`

**Action:**
1. Open file: `supabase/schemas/clinic_subscription.sql`
2. Copy **entire file contents**
3. Paste into Supabase SQL Editor
4. Click **Run**
5. Verify: "Success. No rows returned"

---

#### ✅ Query 3: Update Patient Table
**File Path:** `supabase/schemas/update_patient_table.sql`

**Action:**
1. Open file: `supabase/schemas/update_patient_table.sql`
2. Copy **entire file contents**
3. Paste into Supabase SQL Editor
4. Click **Run**
5. Verify: "Success. No rows returned"

**Note:** Adds `clinic_id` column to existing `patient` table.

---

#### ✅ Query 4: Expand Package Table
**File Path:** `supabase/schemas/expand_package_table.sql`

**Action:**
1. Open file: `supabase/schemas/expand_package_table.sql`
2. Copy **entire file contents**
3. Paste into Supabase SQL Editor
4. Click **Run**
5. Verify: "Success. No rows returned"

**Creates:**
- New columns in `package` table
- `package_therapy_details` table
- `patient_package` table

---

#### ✅ Query 5: Update Therapist Table
**File Path:** `supabase/schemas/update_therapist_table.sql`

**Action:**
1. Open file: `supabase/schemas/update_therapist_table.sql`
2. Copy **entire file contents**
3. Paste into Supabase SQL Editor
4. Click **Run**
5. Verify: "Success. No rows returned"

**⚠️ Warning:** If you have existing therapists without `clinic_id`, you may need to assign them clinics first or temporarily make the constraint nullable.

---

#### ✅ Query 6: Add Clinic ID to Related Tables
**File Path:** `supabase/schemas/add_clinic_id_to_tables.sql`

**Action:**
1. Open file: `supabase/schemas/add_clinic_id_to_tables.sql`
2. Copy **entire file contents**
3. Paste into Supabase SQL Editor
4. Click **Run**
5. Verify: "Success. No rows returned"

**Adds `clinic_id` to:**
- `session` table
- `therapy_goal` table
- `daily_activities` table

---

#### ✅ Query 7: Create RLS Policies
**File Path:** `supabase/schemas/clinic_rls_policies.sql`

**Action:**
1. Open file: `supabase/schemas/clinic_rls_policies.sql`
2. Copy **entire file contents**
3. Paste into Supabase SQL Editor
4. Click **Run**
5. Verify: "Success. No rows returned"

**⚠️ Important:** Review policies - they reference `owner_email` for clinic admin identification. Adjust if your auth setup differs.

---

## Part 2: Deploy Edge Functions

### Access Edge Functions:
1. Go to: **https://supabase.com/dashboard**
2. Select your project
3. Click **Edge Functions** in left sidebar

---

### ✅ Function 1: Check Clinic Subscription (NEW)

**File Path:** `supabase/functions/check-clinic-subscription/index.ts`

**Deploy Steps:**
1. Click **Create a new function**
2. Name: `check-clinic-subscription`
3. Click **Create**
4. Open file: `supabase/functions/check-clinic-subscription/index.ts`
5. Copy **entire file contents**
6. Paste into Supabase editor
7. Click **Deploy**
8. Wait for "Function deployed successfully"

**Test:**
- Click **Invoke function** tab
- Use payload:
  ```json
  {
    "clinic_id": "test-clinic-uuid"
  }
  ```
- Click **Invoke**

---

### ✅ Function 2: Evaluate Assessments (Verify/Update)

**File Path:** `supabase/functions/evaluate-assessments/index.ts`

**Verify Steps:**
1. Check if `evaluate-assessments` function exists
2. If exists, click on it
3. Verify it has CORS headers (should have `Access-Control-Allow-Origin: *`)
4. If missing, update with latest code from `supabase/functions/evaluate-assessments/index.ts`

**If Not Exists:**
1. Create new function: `evaluate-assessments`
2. Copy contents from `supabase/functions/evaluate-assessments/index.ts`
3. Deploy

---

## Part 3: Verify Deployment

### Verify Tables Created:
Run in SQL Editor:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('clinic', 'clinic_subscription', 'package_therapy_details', 'patient_package')
ORDER BY table_name;
```

**Expected:** 4 rows returned

---

### Verify Columns Added:
Run in SQL Editor:
```sql
SELECT table_name, column_name 
FROM information_schema.columns 
WHERE column_name = 'clinic_id' 
AND table_schema = 'public'
ORDER BY table_name;
```

**Expected:** Should show `clinic_id` in:
- patient
- therapist
- session
- therapy_goal
- daily_activities
- package
- patient_package

---

### Verify Edge Functions:
1. Go to **Edge Functions**
2. Should see:
   - ✅ `check-clinic-subscription`
   - ✅ `evaluate-assessments`

---

## 📝 Quick Reference Checklist

### SQL Files (Run in Order):
- [ ] `supabase/schemas/clinic_tables.sql`
- [ ] `supabase/schemas/clinic_subscription.sql`
- [ ] `supabase/schemas/update_patient_table.sql`
- [ ] `supabase/schemas/expand_package_table.sql`
- [ ] `supabase/schemas/update_therapist_table.sql`
- [ ] `supabase/schemas/add_clinic_id_to_tables.sql`
- [ ] `supabase/schemas/clinic_rls_policies.sql`

### Edge Functions (Deploy):
- [ ] `supabase/functions/check-clinic-subscription/index.ts` (NEW)
- [ ] `supabase/functions/evaluate-assessments/index.ts` (Verify/Update)

---

## 🚨 Important Notes

1. **Backup First:** Always backup database before migrations
2. **Order Matters:** Run SQL queries in exact order listed
3. **Existing Data:** Existing therapists/patients will have `clinic_id = NULL` until they select clinic
4. **RLS Policies:** May need adjustment based on your auth setup
5. **Test First:** Test in development environment before production

---

## 🎯 After Deployment

1. **Create Test Clinic:**
   ```sql
   INSERT INTO clinic (name, email, phone, owner_email, is_active)
   VALUES ('Test Clinic', 'admin@testclinic.com', '1234567890', 'admin@testclinic.com', true);
   ```

2. **Grant Test Subscription:**
   ```sql
   INSERT INTO clinic_subscription (clinic_id, subscription_tier, status, starts_at, expires_at)
   SELECT 
     id,
     'premium',
     'active',
     NOW(),
     NOW() + INTERVAL '12 months'
   FROM clinic WHERE email = 'admin@testclinic.com';
   ```

3. **Test Clinic Selection:**
   - Sign up as therapist/patient
   - Should see clinic selection screen
   - Select test clinic
   - Verify `clinic_id` is set

---

## ✅ Success Criteria

- [ ] All 7 SQL queries executed successfully
- [ ] All tables created
- [ ] All columns added
- [ ] RLS policies created
- [ ] Edge functions deployed
- [ ] Can create clinic and grant subscription
- [ ] Users can select clinic during signup
- [ ] Clinic admin can see users who selected their clinic

---

## 📞 Troubleshooting

**Error: "relation already exists"**
→ Table already created, skip that query

**Error: "column already exists"**
→ Column already added, skip that ALTER TABLE

**Error: "foreign key constraint"**
→ Check execution order, ensure referenced tables exist

**Error: "permission denied"**
→ Check database role permissions

**Edge Function: "Module not found"**
→ Ensure imports use `jsr:@supabase/supabase-js@2`

**Edge Function: "CORS error"**
→ Verify CORS headers in function code
