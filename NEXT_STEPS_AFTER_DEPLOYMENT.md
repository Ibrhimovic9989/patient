# Next Steps After Deployment

## ✅ What You've Completed

1. ✅ All 7 SQL queries executed
2. ✅ Edge functions deployed/updated
3. ✅ Database schema updated for multi-tenancy
4. ✅ RLS policies created

---

## 🧪 Step 1: Create Test Data

### Create a Test Clinic

Run this in **Supabase SQL Editor**:

```sql
-- Create test clinic (using Gmail for Google Auth compatibility)
INSERT INTO clinic (name, email, phone, address, country, owner_name, owner_email, is_active)
VALUES (
  'Excellence Circle Therapy Clinic',
  'excellencecircle91@gmail.com',
  '+1234567890',
  '123 Test Street, Test City',
  'United States',
  'Excellence Circle Admin',
  'excellencecircle91@gmail.com',
  true
)
ON CONFLICT (email) DO NOTHING
RETURNING id, name, email;
```

**Note the `id` returned** - you'll need it for the subscription.

### Grant Test Subscription

```sql
-- Grant premium subscription to test clinic
INSERT INTO clinic_subscription (
  clinic_id,
  subscription_tier,
  status,
  starts_at,
  expires_at,
  payment_amount,
  payment_date
)
SELECT 
  c.id,
  'premium',
  'active',
  NOW(),
  NOW() + INTERVAL '12 months',
  999.99,
  NOW()
FROM clinic c
WHERE c.email = 'excellencecircle91@gmail.com'
RETURNING id, clinic_id, subscription_tier, status, expires_at;
```

---

## 🧪 Step 2: Test Clinic Selection Flow

### Test as Therapist:

1. **Run therapist app:**
   ```powershell
   .\run-therapist.ps1
   ```

2. **Sign in with Google** (use a test account)

3. **Fill Personal Details:**
   - Name, age, gender, specialization, etc.
   - Click "Continue"

4. **Select Clinic Screen:**
   - Should see "Test Therapy Clinic" in the list
   - Search for "Test" to filter
   - Select the clinic
   - Click "Continue"

5. **Verify:**
   - Should navigate to Home Screen
   - Check database: `therapist` table should have `clinic_id` set

### Test as Patient:

1. **Run patient app:**
   ```powershell
   .\run-patient.ps1
   ```

2. **Sign in with Google** (use a different test account)

3. **Fill Personal Details:**
   - Name, age, guardian info, etc.
   - Click "Continue"

4. **Select Clinic Screen:**
   - Should see "Test Therapy Clinic" in the list
   - Select the clinic
   - Click "Continue"

5. **Verify:**
   - Should navigate to Assessments Screen
   - Check database: `patient` table should have `clinic_id` set

---

## 🧪 Step 3: Test Clinic App

### Test Clinic Admin:

1. **Run clinic app:**
   ```powershell
   cd clinic
   flutter run -d chrome --web-port=50003
   ```

2. **Sign in with Google** (use `excellencecircle91@gmail.com`)

3. **Verify Dashboard:**
   - Should see clinic info
   - Should see subscription status

4. **Check Therapists:**
   - Go to "Therapists" screen
   - Should see therapist who selected your clinic
   - Approve therapist if needed

5. **Check Patients:**
   - Go to "Patients" screen
   - Should see patient who selected your clinic
   - Assign therapist to patient

---

## 🧪 Step 4: Test Edge Function

### Test Check Clinic Subscription:

1. **Go to Supabase Dashboard → Edge Functions**

2. **Click on `check-clinic-subscription`**

3. **Click "Invoke function" tab**

4. **Use this payload:**
   ```json
   {
     "clinic_id": "YOUR_CLINIC_ID_HERE"
   }
   ```
   (Replace with actual clinic ID from test clinic)

5. **Click "Invoke"**

6. **Expected Response:**
   ```json
   {
     "has_active_subscription": true,
     "subscription": {
       "id": "...",
       "tier": "premium",
       "starts_at": "...",
       "expires_at": "...",
       "days_remaining": 365
     }
   }
   ```

---

## ✅ Step 5: Verification Checklist

Run these verification queries in SQL Editor:

### Check Tables Created:
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('clinic', 'clinic_subscription', 'package_therapy_details', 'patient_package')
ORDER BY table_name;
```
**Expected:** 4 rows

### Check Clinic ID Columns:
```sql
SELECT table_name, column_name 
FROM information_schema.columns 
WHERE column_name = 'clinic_id' 
AND table_schema = 'public'
ORDER BY table_name;
```
**Expected:** Should show clinic_id in patient, therapist, session, therapy_goal, daily_activities, package, patient_package

### Check Test Clinic:
```sql
SELECT 
  c.id,
  c.name,
  c.email,
  cs.subscription_tier,
  cs.status,
  cs.expires_at
FROM clinic c
LEFT JOIN clinic_subscription cs ON cs.clinic_id = c.id AND cs.status = 'active'
WHERE c.email = 'excellencecircle91@gmail.com';
```

### Check RLS Enabled:
```sql
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('clinic', 'clinic_subscription', 'package_therapy_details', 'patient_package');
```
**Expected:** All should show `true` for `rowsecurity`

---

## 🚀 Step 6: Create Real Clinic Data

Once testing is complete:

1. **Create real clinics** via SQL or clinic app
2. **Grant subscriptions** using the script: `supabase/scripts/grant_clinic_subscription.js`
3. **Onboard real therapists and patients** - they'll select clinics during signup

---

## 📝 Step 7: Update Existing Data (If Needed)

If you have existing therapists/patients without `clinic_id`:

### Option A: Assign Manually
```sql
-- Assign existing therapist to clinic
UPDATE therapist 
SET clinic_id = (SELECT id FROM clinic WHERE email = 'admin@testclinic.com')
WHERE id = 'THERAPIST_ID_HERE';

-- Assign existing patient to clinic
UPDATE patient 
SET clinic_id = (SELECT id FROM clinic WHERE email = 'admin@testclinic.com')
WHERE id = 'PATIENT_ID_HERE';
```

### Option B: Let Users Select
- Existing users will see clinic selection screen on next login
- They can select their clinic themselves

---

## 🎯 Success Criteria

- [ ] Test clinic created with subscription
- [ ] Therapist can sign up and select clinic
- [ ] Patient can sign up and select clinic
- [ ] Clinic admin can see users who selected their clinic
- [ ] Edge function returns subscription status
- [ ] RLS policies working (users only see their clinic's data)
- [ ] No errors in console/logs

---

## 🐛 Troubleshooting

### "No clinics available" in selection screen
- Check clinic is created: `SELECT * FROM clinic WHERE is_active = true;`
- Verify `is_active = true`

### "Clinic not found" error
- Check clinic exists in database
- Verify clinic_id is correct

### Edge function returns error
- Check function is deployed
- Verify CORS headers present
- Check clinic_id format (should be UUID)

### RLS blocking access
- Verify user email matches `owner_email` in clinic table
- Check RLS policies are created
- Use service role key for admin operations if needed

---

## 📚 Next Features to Implement

1. **Package Management:**
   - Clinic admin creates packages
   - Patients select packages after assessment

2. **Subscription Management:**
   - Auto-renewal notifications
   - Subscription expiry warnings
   - Payment integration

3. **Clinic Invitations:**
   - Send invitation links with pre-selected clinic
   - QR code for clinic selection

4. **Analytics:**
   - Clinic usage statistics
   - Subscription metrics
   - Patient/therapist counts per clinic

---

## ✅ You're Ready!

Your SaaS multi-tenant platform is now deployed and ready for testing. Follow the steps above to verify everything works correctly!
