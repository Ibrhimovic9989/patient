# How Clinic Assignment Works

## Current Implementation

### ❌ Problem Identified

**Neither therapists nor patients are assigned to clinics during signup.** The `clinic_id` field is not being set when users register.

### ✅ Solution Implemented

I've implemented **manual clinic assignment by clinic admins** through the clinic app. Here's how it works:

## Assignment Flow

### For Therapists:

1. **Therapist Signs Up:**
   - Therapist signs in with Google
   - Fills personal details form
   - **`clinic_id` is NULL** at this point
   - Therapist cannot access clinic-scoped features

2. **Clinic Admin Assigns Clinic:**
   - Clinic admin opens **Clinic App → Therapists**
   - Sees list of therapists (with or without clinic)
   - For unassigned therapists, clicks **"Assign Clinic"** button
   - Selects clinic from list
   - **`clinic_id` is set** in therapist table
   - Therapist can now access clinic-scoped data

3. **Clinic Admin Approves Therapist:**
   - After assigning clinic, admin can approve therapist
   - Sets `approved = true` in therapist table
   - Therapist is now fully active

**Files:**
- `clinic/lib/presentation/therapists/therapists_screen.dart` - Shows therapists, allows clinic assignment
- `clinic/lib/presentation/therapists/assign_clinic_screen.dart` - Screen to assign clinic to therapist

### For Patients:

1. **Patient Signs Up:**
   - Patient signs in with Google
   - Fills personal details form
   - **`clinic_id` is NULL** at this point
   - Patient cannot see packages or access clinic features

2. **Clinic Admin Assigns Clinic:**
   - Clinic admin opens **Clinic App → Patients**
   - Sees list of patients (with or without clinic)
   - For unassigned patients, clicks **"Assign Clinic"** button
   - Selects clinic from list
   - **`clinic_id` is set** in patient table
   - Patient can now see clinic packages

3. **Clinic Admin Assigns Therapist:**
   - After clinic assignment, admin can assign therapist
   - Uses existing **"Assign Therapist"** feature
   - Sets `therapist_id` in patient table

**Files:**
- `clinic/lib/presentation/patients/patients_screen.dart` - Shows patients, allows clinic/therapist assignment
- `clinic/lib/presentation/patients/assign_therapist_screen.dart` - Screen to assign therapist to patient

## Visual Flow

```
Therapist Signup
    ↓
clinic_id = NULL
    ↓
Clinic Admin → Therapists Screen
    ↓
Click "Assign Clinic"
    ↓
Select Clinic
    ↓
clinic_id = <clinic_uuid>
    ↓
Therapist can access clinic data ✅
```

```
Patient Signup
    ↓
clinic_id = NULL
    ↓
Clinic Admin → Patients Screen
    ↓
Click "Assign Clinic"
    ↓
Select Clinic
    ↓
clinic_id = <clinic_uuid>
    ↓
Patient can see packages ✅
    ↓
Clinic Admin → Assign Therapist
    ↓
therapist_id = <therapist_uuid>
    ↓
Patient fully onboarded ✅
```

## Alternative Approaches (Not Yet Implemented)

### Option 1: Invitation System
- Clinic generates invitation link with `clinic_id` parameter
- User signs up via invitation link
- `clinic_id` automatically set during signup

### Option 2: Clinic Selection During Signup
- User selects clinic from list during onboarding
- Creates join request
- Clinic admin approves
- `clinic_id` set after approval

### Option 3: URL Parameter
- Signup URL includes `?clinic_id=xxx`
- App reads parameter and sets `clinic_id` during signup

## Current Status

✅ **Implemented:**
- Clinic admin can assign clinic to therapists
- Clinic admin can assign clinic to patients
- Clinic admin can assign therapist to patients
- UI shows assignment status

❌ **Missing:**
- Automatic clinic assignment during signup
- Invitation system
- Clinic selection during signup
- Bulk assignment features

## Next Steps

To enable automatic assignment, you would need to:

1. **Add `clinic_id` parameter to signup flows:**
   - Update `therapist/lib/repository/supabase_auth_repository.dart`
   - Update `patient/lib/repository/supabase_auth_repository.dart`
   - Accept `clinic_id` in `storePersonalInfo` methods

2. **Or implement invitation system:**
   - Create `clinic_invitations` table
   - Generate invitation codes/links
   - Pass `clinic_id` via invitation

3. **Or add clinic selection screen:**
   - Show clinic list during onboarding
   - Let user select/request clinic
   - Clinic admin approves

For now, **manual assignment via clinic app is the working solution**.
