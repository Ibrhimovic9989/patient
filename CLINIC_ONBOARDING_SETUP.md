# Clinic Onboarding Form - Setup Guide

## Overview

A clinic onboarding form has been added to allow clinics to register themselves. The form collects clinic information and creates a pending clinic record that requires admin approval.

## What Was Added

### 1. Clinic Onboarding Screen
**File**: `clinic/lib/presentation/auth/clinic_onboarding_screen.dart`

**Features**:
- Google OAuth sign-in integration
- Form to collect clinic details:
  - Clinic Name (required)
  - Clinic Email (pre-filled from Google account)
  - Clinic Phone (required)
  - Address (optional)
  - Country (optional)
  - Owner/Administrator Name (required, pre-filled from Google account)
- Creates clinic record with `is_active = false` (pending approval)
- Shows success message after submission
- Prevents duplicate registrations

### 2. Updated Login Screen
**File**: `clinic/lib/presentation/auth/login_screen.dart`

- Added "New Clinic? Register Here" button
- Links to the onboarding screen

### 3. RLS Policy
**File**: `supabase/schemas/clinic_onboarding_rls.sql`

- Allows authenticated users to insert clinic records
- Restricts to `is_active = false` (prevents self-activation)
- Ensures `owner_email` matches authenticated user's email

### 4. Dependencies
**File**: `clinic/pubspec.yaml`

- Added `country_picker: ^2.0.27` for country selection

## Setup Instructions

### Step 1: Approve Existing Clinics (IMPORTANT)

**First, approve all existing clinic users** so they can continue to log in:

```sql
-- Approve all existing clinics
UPDATE clinic
SET is_active = true
WHERE is_active IS NULL OR is_active = false;
```

Or run the file:
```bash
# In Supabase SQL Editor, paste contents of:
supabase/schemas/approve_existing_clinics.sql
```

This ensures all current clinic users are already approved and won't be locked out.

### Step 2: Run the RLS Policy SQL

Execute the RLS policy in your Supabase SQL Editor:

```sql
-- Allow authenticated users to insert clinic records for onboarding
CREATE POLICY "Authenticated users can submit clinic onboarding"
  ON clinic FOR INSERT
  TO authenticated
  WITH CHECK (
    owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    AND is_active = false
  );
```

Or run the file:
```bash
# In Supabase SQL Editor, paste contents of:
supabase/schemas/clinic_onboarding_rls.sql
```

### Step 3: Install Dependencies

```bash
cd clinic
flutter pub get
```

### Step 4: Test the Onboarding Flow

1. **Start the clinic app**:
   ```bash
   cd clinic
   flutter run
   ```

2. **Navigate to Login Screen**:
   - Click "New Clinic? Register Here"

3. **Sign in with Google**:
   - Use the Google sign-in button
   - Complete OAuth flow

4. **Fill in Clinic Details**:
   - Clinic Name: "Test Clinic"
   - Clinic Email: (pre-filled from Google)
   - Clinic Phone: "+1234567890"
   - Address: (optional)
   - Country: (optional)
   - Owner Name: (pre-filled from Google)

5. **Submit**:
   - Click "Submit Onboarding Request"
   - Should see success message

6. **Verify in Database**:
   ```sql
   SELECT * FROM clinic WHERE email = 'your-test-email@example.com';
   ```
   - Should see record with `is_active = false`

## Admin Approval Process

### Current Manual Process

1. **Check Pending Clinics**:
   ```sql
   SELECT * FROM clinic WHERE is_active = false;
   ```

2. **Activate Clinic**:
   ```sql
   UPDATE clinic 
   SET is_active = true 
   WHERE id = '<clinic-id>';
   ```

3. **Notify Clinic**:
   - Send email notification to `owner_email`
   - Clinic can now log in

### Future Enhancement (Optional)

Consider creating an admin interface to:
- View pending clinic requests
- Approve/reject clinics
- Send automated email notifications

## How It Works

1. **Clinic Registration**:
   - Clinic signs in with Google OAuth
   - Fills onboarding form
   - Submits request
   - Record created with `is_active = false`

2. **Admin Approval**:
   - Admin reviews request in database
   - Sets `is_active = true`
   - Notifies clinic (manual for now)

3. **Clinic Login**:
   - Clinic attempts to log in
   - System checks if `owner_email` matches and `is_active = true`
   - If approved, clinic gains access

## Security Features

✅ **RLS Protection**:
- Only authenticated users can insert
- Can only set `is_active = false` (no self-activation)
- `owner_email` must match authenticated user's email

✅ **Duplicate Prevention**:
- Form checks for existing clinic with same email
- Shows appropriate message if already registered

✅ **Data Validation**:
- Required fields validated
- Email format validated
- Prevents empty submissions

## Troubleshooting

### Issue: "Permission denied" when submitting
**Solution**: Make sure you've run the RLS policy SQL (`clinic_onboarding_rls.sql`)

### Issue: Can't sign in with Google
**Solution**: 
- Check Supabase redirect URLs are configured
- Verify Google OAuth is enabled in Supabase Dashboard

### Issue: Form doesn't show after Google sign-in
**Solution**: 
- Check browser console for errors
- Verify auth state listener is working
- Try refreshing the page

### Issue: Country picker not working
**Solution**: 
- Run `flutter pub get` in clinic directory
- Verify `country_picker` is in `pubspec.yaml`

## Next Steps

1. ✅ Run RLS policy SQL
2. ✅ Install dependencies (`flutter pub get`)
3. ✅ Test onboarding flow
4. ⏳ Set up email notifications (optional)
5. ⏳ Create admin approval interface (optional)

---

**Status**: ✅ Onboarding form is ready to use after running the RLS policy SQL!
