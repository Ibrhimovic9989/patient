# Clinic Assignment Flow - Current State & Recommendations

## Current State Analysis

### ❌ Problem: Clinic Assignment is Missing

Currently, **neither therapists nor patients are being assigned to clinics during signup**. This is a critical gap in the SaaS multi-tenant architecture.

### Therapist Signup Flow (Current)
1. Therapist signs in with Google
2. Therapist fills personal details form
3. **`clinic_id` is NOT set** - therapist record created without clinic
4. Therapist cannot access any clinic-scoped data

**File:** `therapist/lib/repository/supabase_auth_repository.dart` (line 128-154)
- The `storePersonalInfo` method does NOT include `clinic_id` in the data map
- Therapist is created with `clinic_id = NULL`

### Patient Signup Flow (Current)
1. Patient signs in with Google  
2. Patient fills personal details form
3. **`clinic_id` is NOT set** - patient record created without clinic
4. Patient cannot see packages or access clinic-scoped features

**File:** `patient/lib/repository/supabase_auth_repository.dart` (line 20-36)
- The `storePersonalInfo` method does NOT include `clinic_id` in the data map
- Patient is created with `clinic_id = NULL`

## Recommended Solutions

### Option 1: Clinic Invitation System (Recommended)

**How it works:**
1. Clinic admin generates invitation link/code with `clinic_id`
2. Therapist/Patient signs up using invitation link
3. `clinic_id` is automatically set during signup

**Implementation:**
- Add `clinic_invitations` table
- Generate unique invitation codes per clinic
- Pass `clinic_id` via URL parameter or invitation code
- Set `clinic_id` during signup

### Option 2: Clinic Selection During Signup

**How it works:**
1. User signs up
2. User selects clinic from list (or searches by name)
3. Clinic admin approves the request
4. `clinic_id` is set after approval

**Implementation:**
- Add clinic selection screen after signup
- Create `clinic_join_requests` table for approval workflow
- Clinic admin approves/rejects requests

### Option 3: Manual Assignment by Clinic Admin (Current Partial Implementation)

**How it works:**
1. User signs up (without clinic)
2. Clinic admin manually assigns user to clinic via clinic app
3. `clinic_id` is updated by admin

**Status:** 
- ✅ Partially implemented for patients (assign therapist screen exists)
- ❌ Missing for therapists (no screen to assign clinic to therapist)

## Immediate Fix Required

### For Therapists:
1. **Add clinic assignment screen** in clinic app
2. **Update therapist signup** to optionally accept `clinic_id` parameter
3. **Or** add clinic selection during therapist onboarding

### For Patients:
1. **Add clinic assignment screen** in clinic app (similar to therapist assignment)
2. **Update patient signup** to optionally accept `clinic_id` parameter
3. **Or** add clinic selection during patient onboarding

## Implementation Priority

### High Priority (Blocking):
1. ✅ Add clinic assignment for patients in clinic app (DONE - `assign_therapist_screen.dart`)
2. ❌ Add clinic assignment for therapists in clinic app (MISSING)
3. ❌ Update therapist signup to accept `clinic_id` parameter
4. ❌ Update patient signup to accept `clinic_id` parameter

### Medium Priority:
5. Add clinic invitation system
6. Add clinic selection during signup
7. Add approval workflow for clinic join requests

## Code Changes Needed

### 1. Update Therapist Signup to Accept Clinic ID

**File:** `therapist/lib/repository/supabase_auth_repository.dart`

```dart
@override
Future<ActionResult> storePersonalInfo(
  TherapistPersonalInfoEntity personalInfoEntity, {
  String? clinicId, // Add optional clinic_id parameter
}) async {
  // ... existing code ...
  
  final data = <String, dynamic>{
    'id': currentUser.id,
    'email': currentUser.email ?? '',
    'phone': '',
    'name': entityMap['name'],
    // ... other fields ...
    'clinic_id': clinicId, // Add clinic_id if provided
  };
  
  // ... rest of code ...
}
```

### 2. Update Patient Signup to Accept Clinic ID

**File:** `patient/lib/repository/supabase_auth_repository.dart`

```dart
@override
Future<ActionResult> storePersonalInfo(
  PersonalInfoEntity personalInfoEntity, {
  String? clinicId, // Add optional clinic_id parameter
}) async {
  final patientId = _supabaseClient.auth.currentSession?.user.id;
  final data = personalInfoEntity.copyWith(patientId: patientId).toMap();
  
  if (clinicId != null) {
    data['clinic_id'] = clinicId; // Add clinic_id if provided
  }
  
  await _supabaseClient.from('patient').insert(data);
  // ... rest of code ...
}
```

### 3. Add Clinic Assignment Screen for Therapists

**File:** `clinic/lib/presentation/therapists/assign_clinic_screen.dart`

Similar to `assign_therapist_screen.dart` but for assigning clinic to therapist.

### 4. Add Clinic Assignment to Patients Screen

**File:** `clinic/lib/presentation/patients/patients_screen.dart`

Add ability to assign clinic to unassigned patients (currently only therapist assignment exists).

## Database Constraints

**Current Issue:**
- `therapist.clinic_id` is nullable but should be required for active therapists
- `patient.clinic_id` is nullable but should be required for active patients

**Recommendation:**
- Keep nullable for initial signup
- Require `clinic_id` before therapist/patient can access clinic-scoped features
- Add validation in app logic (not just DB constraint)
