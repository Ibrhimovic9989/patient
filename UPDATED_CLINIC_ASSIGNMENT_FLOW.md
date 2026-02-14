# Updated Privacy-Compliant Clinic Assignment Flow

## ✅ Privacy-First Implementation

Users (therapists and patients) now **select their own clinic** during signup, ensuring privacy compliance and user control.

## New User-Driven Flow

### Therapist Onboarding:

```
1. Sign In with Google
   ↓
2. Fill Personal Details
   - Name, age, gender, specialization, etc.
   - Saves to therapist table (clinic_id = NULL)
   ↓
3. Select Clinic Screen (NEW)
   - User searches clinics
   - User selects their clinic
   - Updates therapist.clinic_id
   ↓
4. Clinic Admin Approval (Optional)
   - Admin sees therapist in clinic list
   - Admin approves (sets approved = true)
   ↓
5. Home Screen
   - Therapist can access clinic features
```

### Patient Onboarding:

```
1. Sign In with Google
   ↓
2. Fill Personal Details
   - Name, age, guardian info, etc.
   - Saves to patient table (clinic_id = NULL)
   ↓
3. Select Clinic Screen (NEW)
   - User searches clinics
   - User selects their clinic
   - Updates patient.clinic_id
   ↓
4. Assessments Screen
   - Patient can take assessments
   - Patient can see clinic packages
   ↓
5. Clinic Admin Assigns Therapist
   - Admin assigns therapist to patient
   - Patient can book sessions
```

## Privacy Benefits

✅ **User Control:** Users choose their own clinic
✅ **No Admin Overreach:** Admins cannot assign users to clinics
✅ **Transparency:** Users see all available clinics
✅ **Search:** Easy to find clinic by name/location/email
✅ **Compliance:** Meets privacy and data protection requirements

## Implementation Details

### New Screens Created:

1. **`therapist/lib/presentation/auth/clinic_selection_screen.dart`**
   - Shows all active clinics
   - Search by name, email, or address
   - Radio button selection
   - Updates `therapist.clinic_id` on selection

2. **`patient/lib/presentation/auth/clinic_selection_screen.dart`**
   - Shows all active clinics
   - Search by name, email, or address
   - Radio button selection
   - Updates `patient.clinic_id` on selection

### Updated Flows:

1. **Therapist Signup:**
   - `PersonalDetailsScreen` → `ClinicSelectionScreen` → `HomeScreen`

2. **Patient Signup:**
   - `PersonalDetailsScreen` → `ClinicSelectionScreen` → `AssessmentsListScreen`

### Clinic App Updates:

- **Therapists Screen:** Removed clinic assignment button (therapists select themselves)
- **Patients Screen:** Removed clinic assignment button (patients select themselves)
- **Admin Role:** Can only approve therapists and assign therapists to patients

## User Experience

### Clinic Selection Screen Features:

- **Search Bar:** Filter clinics by name, email, or address
- **Clinic Cards:** Show clinic name, email, and address
- **Radio Selection:** Clear visual indication of selection
- **Continue Button:** Only enabled when clinic is selected
- **Loading States:** Shows loading while fetching clinics
- **Empty States:** Helpful messages when no clinics found

## Clinic Admin Workflow

After user selects clinic:

1. **Therapist Appears in Clinic List:**
   - Admin sees therapist in "Therapists" screen
   - Status shows "Pending Approval" if not approved
   - Admin can approve therapist

2. **Patient Appears in Clinic List:**
   - Admin sees patient in "Patients" screen
   - Admin can assign therapist to patient
   - Patient can then book sessions

## Data Flow

```
User Signup
    ↓
Personal Details Saved (clinic_id = NULL)
    ↓
User Selects Clinic
    ↓
clinic_id Updated in Database
    ↓
User Appears in Clinic Admin's List
    ↓
Admin Can Approve/Assign (if needed)
```

## Security & Privacy

- ✅ Users control their clinic selection
- ✅ No unauthorized clinic assignment
- ✅ Clinic admins only see users who selected their clinic
- ✅ Search is client-side (no privacy concerns)
- ✅ RLS policies ensure data isolation

## Testing Checklist

- [ ] Therapist can search and select clinic during signup
- [ ] Patient can search and select clinic during signup
- [ ] Selected clinic_id is saved correctly
- [ ] Clinic admin sees user in their clinic list
- [ ] Clinic admin can approve therapist
- [ ] Clinic admin can assign therapist to patient
- [ ] Users cannot access other clinics' data
