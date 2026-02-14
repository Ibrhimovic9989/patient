# Delete Users and All Records - Instructions

## ⚠️ WARNING
This will **permanently delete** all data for these users:
- Ibrahim Raza (`ibrahimshaheer91@gmail.com`)
- Leeza app (`leeza.app15@gmail.com`)

## Step 1: Delete Data Records

Run the SQL script: `supabase/scripts/delete_users_and_records.sql`

**Or copy this simplified version:**

```sql
BEGIN;

-- Delete User 1 (Ibrahim Raza)
DELETE FROM patient_package WHERE patient_id = '5c3c4572-37af-4556-9a89-fc2751700be1';
DELETE FROM daily_activities WHERE patient_id = '5c3c4572-37af-4556-9a89-fc2751700be1';
DELETE FROM therapy_goal WHERE therapist_id = '5c3c4572-37af-4556-9a89-fc2751700be1';
DELETE FROM session WHERE patient_id = '5c3c4572-37af-4556-9a89-fc2751700be1' OR therapist_id = '5c3c4572-37af-4556-9a89-fc2751700be1';
DELETE FROM assessment_results WHERE patient_id = '5c3c4572-37af-4556-9a89-fc2751700be1';
DELETE FROM therapist WHERE id = '5c3c4572-37af-4556-9a89-fc2751700be1';
DELETE FROM patient WHERE id = '5c3c4572-37af-4556-9a89-fc2751700be1';

-- Delete User 2 (Leeza app)
DELETE FROM patient_package WHERE patient_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382';
DELETE FROM daily_activities WHERE patient_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382';
DELETE FROM therapy_goal WHERE therapist_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382';
DELETE FROM session WHERE patient_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382' OR therapist_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382';
DELETE FROM assessment_results WHERE patient_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382';
DELETE FROM therapist WHERE id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382';
DELETE FROM patient WHERE id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382';

COMMIT;
```

## Step 2: Delete from Auth (Supabase Dashboard)

**Option A: Via Dashboard (Recommended)**
1. Go to **Supabase Dashboard → Authentication → Users**
2. Search for `ibrahimshaheer91@gmail.com`
3. Click the user → Click **Delete user**
4. Repeat for `leeza.app15@gmail.com`

**Option B: Via SQL (Requires Admin)**
```sql
-- Only works if you have admin/service role access
DELETE FROM auth.users WHERE id IN (
    '5c3c4572-37af-4556-9a89-fc2751700be1',
    '97bfac42-2ecb-4964-bbb8-5f9adabe9382'
);
```

## Step 3: Verify Deletion

Run this to check if any records remain:

```sql
-- Check User 1
SELECT 'patient' as table_name, COUNT(*) as count FROM patient WHERE id = '5c3c4572-37af-4556-9a89-fc2751700be1'
UNION ALL
SELECT 'therapist', COUNT(*) FROM therapist WHERE id = '5c3c4572-37af-4556-9a89-fc2751700be1'
UNION ALL
SELECT 'assessment_results', COUNT(*) FROM assessment_results WHERE patient_id = '5c3c4572-37af-4556-9a89-fc2751700be1';

-- Check User 2
SELECT 'patient' as table_name, COUNT(*) as count FROM patient WHERE id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382'
UNION ALL
SELECT 'therapist', COUNT(*) FROM therapist WHERE id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382'
UNION ALL
SELECT 'assessment_results', COUNT(*) FROM assessment_results WHERE patient_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382';
```

**Expected:** All counts should be `0`

## What Gets Deleted

For each user:
- ✅ Patient record (if they were a patient)
- ✅ Therapist record (if they were a therapist)
- ✅ Assessment results
- ✅ Sessions (as patient or therapist)
- ✅ Therapy goals (if therapist)
- ✅ Daily activities (if patient)
- ✅ Patient packages (if patient)
- ✅ Auth user (via Dashboard)

## Notes

- **Cascade deletes:** Some related records may be automatically deleted due to foreign key constraints
- **Auth users:** Must be deleted via Dashboard or Admin API (not regular SQL)
- **Backup first:** Consider backing up data before deletion if needed
