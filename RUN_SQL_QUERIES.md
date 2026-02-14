# Run SQL Queries - Step by Step Guide

## How to Access Supabase SQL Editor

1. Go to: **https://supabase.com/dashboard**
2. Select your project
3. Click **SQL Editor** in the left sidebar
4. Click **New Query**

## Execution Order (CRITICAL - Run in this exact order)

### Query 1: Create Clinic Table
**File:** `supabase/schemas/clinic_tables.sql`

**Steps:**
1. Open SQL Editor → New Query
2. Copy **ALL contents** from `supabase/schemas/clinic_tables.sql`
3. Paste into editor
4. Click **Run** (or press Ctrl+Enter)
5. Verify: Should see "Success. No rows returned"

---

### Query 2: Create Clinic Subscription Table
**File:** `supabase/schemas/clinic_subscription.sql`

**Steps:**
1. New Query (or clear previous)
2. Copy **ALL contents** from `supabase/schemas/clinic_subscription.sql`
3. Paste and Run
4. Verify: Should see "Success. No rows returned"

---

### Query 3: Update Patient Table
**File:** `supabase/schemas/update_patient_table.sql`

**Steps:**
1. New Query
2. Copy **ALL contents** from `supabase/schemas/update_patient_table.sql`
3. Paste and Run
4. Verify: Should see "Success. No rows returned"

**⚠️ If you have existing patients:**
- This will add `clinic_id` column (nullable)
- Existing patients will have `clinic_id = NULL`
- They'll need to select clinic during next login or you can assign manually

---

### Query 4: Expand Package Table
**File:** `supabase/schemas/expand_package_table.sql`

**Steps:**
1. New Query
2. Copy **ALL contents** from `supabase/schemas/expand_package_table.sql`
3. Paste and Run
4. Verify: Should see "Success. No rows returned"

**What this creates:**
- New columns in `package` table
- `package_therapy_details` table
- `patient_package` table

---

### Query 5: Update Therapist Table
**File:** `supabase/schemas/update_therapist_table.sql`

**Steps:**
1. New Query
2. Copy **ALL contents** from `supabase/schemas/update_therapist_table.sql`
3. Paste and Run

**⚠️ If you have existing therapists without clinic_id:**
- This may fail if foreign key constraint is added
- **Option A:** Assign clinics to existing therapists first
- **Option B:** Temporarily comment out the foreign key constraint line

---

### Query 6: Add Clinic ID to Related Tables
**File:** `supabase/schemas/add_clinic_id_to_tables.sql`

**Steps:**
1. New Query
2. Copy **ALL contents** from `supabase/schemas/add_clinic_id_to_tables.sql`
3. Paste and Run
4. Verify: Should see "Success. No rows returned"

**What this does:**
- Adds `clinic_id` to `session` table
- Adds `clinic_id` to `therapy_goal` table
- Adds `clinic_id` to `daily_activities` table

---

### Query 7: Create RLS Policies
**File:** `supabase/schemas/clinic_rls_policies.sql`

**Steps:**
1. New Query
2. Copy **ALL contents** from `supabase/schemas/clinic_rls_policies.sql`
3. Paste and Run
4. Verify: Should see "Success. No rows returned"

**⚠️ Important:**
- This enables Row Level Security
- Review policies before running
- Some policies reference `owner_email` - ensure this matches your clinic admin setup

---

## Quick Copy-Paste Links

Since you can't directly link to files, here's what to do:

1. **Open each file in your editor:**
   - `supabase/schemas/clinic_tables.sql`
   - `supabase/schemas/clinic_subscription.sql`
   - `supabase/schemas/update_patient_table.sql`
   - `supabase/schemas/expand_package_table.sql`
   - `supabase/schemas/update_therapist_table.sql`
   - `supabase/schemas/add_clinic_id_to_tables.sql`
   - `supabase/schemas/clinic_rls_policies.sql`

2. **Copy entire file contents**

3. **Paste into Supabase SQL Editor**

4. **Run each query one by one**

---

## Verify Queries Ran Successfully

Run this verification query after all migrations:

```sql
-- Check all new tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
  'clinic', 
  'clinic_subscription', 
  'package_therapy_details', 
  'patient_package'
)
ORDER BY table_name;
```

Should return 4 rows.

```sql
-- Check clinic_id columns were added
SELECT table_name, column_name 
FROM information_schema.columns 
WHERE column_name = 'clinic_id' 
AND table_schema = 'public'
ORDER BY table_name;
```

Should show `clinic_id` in: patient, therapist, session, therapy_goal, daily_activities, package, patient_package.

---

## Troubleshooting

### Error: "relation already exists"
- Table already created, skip that query

### Error: "column already exists"
- Column already added, skip that ALTER TABLE statement

### Error: "foreign key constraint"
- Ensure referenced table exists
- Check order of execution
- May need to assign clinics to existing records first

### Error: "permission denied"
- Check you're using the correct database role
- Some operations may need service role key
