-- Clinic RLS Policies
-- Row Level Security policies for multi-tenant clinic isolation

-- Enable RLS on new tables
ALTER TABLE clinic ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinic_subscription ENABLE ROW LEVEL SECURITY;
ALTER TABLE package_therapy_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_package ENABLE ROW LEVEL SECURITY;

-- ============================================
-- CLINIC TABLE POLICIES
-- ============================================

-- Clinic admins can view their own clinic
CREATE POLICY "Clinic admins can view their clinic"
  ON clinic FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.email = clinic.owner_email
    )
  );

-- SaaS owner can view all clinics (via service role key)
-- Note: Service role bypasses RLS, so this is for reference
-- In practice, service role key should be used for admin operations

-- ============================================
-- CLINIC SUBSCRIPTION POLICIES
-- ============================================

-- Clinic admins can view their clinic's subscription
CREATE POLICY "Clinic admins can view their subscription"
  ON clinic_subscription FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = clinic_subscription.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ============================================
-- PATIENT TABLE POLICIES (UPDATE)
-- ============================================

-- Drop existing patient policies that don't account for clinic_id
DROP POLICY IF EXISTS "Therapists can view their patients" ON patient;

-- Therapists can only see patients from their clinic
CREATE POLICY "Therapists can view patients from their clinic"
  ON patient FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM therapist
      WHERE therapist.id = auth.uid()
      AND therapist.clinic_id = patient.clinic_id
      AND (therapist.id = patient.therapist_id OR patient.therapist_id IS NULL)
    )
  );

-- Clinic admins can view all patients in their clinic
CREATE POLICY "Clinic admins can view clinic patients"
  ON patient FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- Clinic admins can update patients in their clinic (e.g., assign therapist)
CREATE POLICY "Clinic admins can update clinic patients"
  ON patient FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ============================================
-- THERAPIST TABLE POLICIES (UPDATE)
-- ============================================

-- Therapists can only see therapists from their clinic
CREATE POLICY "Therapists can view clinic therapists"
  ON therapist FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM therapist t
      WHERE t.id = auth.uid()
      AND t.clinic_id = therapist.clinic_id
    )
  );

-- Clinic admins can view all therapists in their clinic
CREATE POLICY "Clinic admins can view clinic therapists"
  ON therapist FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- Clinic admins can insert therapists in their clinic
CREATE POLICY "Clinic admins can insert clinic therapists"
  ON therapist FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- Clinic admins can update therapists in their clinic
CREATE POLICY "Clinic admins can update clinic therapists"
  ON therapist FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ============================================
-- PACKAGE TABLE POLICIES
-- ============================================

-- Patients can view packages from their clinic
CREATE POLICY "Patients can view clinic packages"
  ON package FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM patient
      WHERE patient.id = auth.uid()
      AND patient.clinic_id = package.clinic_id
      AND package.is_active = TRUE
    )
  );

-- Clinic admins can manage packages in their clinic
CREATE POLICY "Clinic admins can manage clinic packages"
  ON package FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = package.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = package.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ============================================
-- PACKAGE THERAPY DETAILS POLICIES
-- ============================================

-- Patients can view therapy details for their clinic's packages
CREATE POLICY "Patients can view package therapy details"
  ON package_therapy_details FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM package p
      JOIN patient pt ON pt.clinic_id = p.clinic_id
      WHERE pt.id = auth.uid()
      AND p.id = package_therapy_details.package_id
    )
  );

-- Clinic admins can manage therapy details for their packages
CREATE POLICY "Clinic admins can manage package therapy details"
  ON package_therapy_details FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM package p
      JOIN clinic c ON c.id = p.clinic_id
      WHERE c.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
      AND p.id = package_therapy_details.package_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM package p
      JOIN clinic c ON c.id = p.clinic_id
      WHERE c.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
      AND p.id = package_therapy_details.package_id
    )
  );

-- ============================================
-- PATIENT PACKAGE POLICIES
-- ============================================

-- Patients can view their own packages
CREATE POLICY "Patients can view their packages"
  ON patient_package FOR SELECT
  USING (patient_id = auth.uid());

-- Patients can insert their own package selection
CREATE POLICY "Patients can select packages"
  ON patient_package FOR INSERT
  WITH CHECK (
    patient_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM patient
      WHERE patient.id = auth.uid()
      AND patient.clinic_id = patient_package.clinic_id
    )
  );

-- Clinic admins can view and manage packages for their clinic's patients
CREATE POLICY "Clinic admins can manage patient packages"
  ON patient_package FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient_package.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient_package.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ============================================
-- SESSION TABLE POLICIES (UPDATE)
-- ============================================

-- Drop existing session policies if they exist
DROP POLICY IF EXISTS "Patients can view their own sessions" ON session;
DROP POLICY IF EXISTS "Therapists can view their sessions" ON session;

-- Patients can view sessions from their clinic
CREATE POLICY "Patients can view clinic sessions"
  ON session FOR SELECT
  USING (
    patient_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM patient
      WHERE patient.id = auth.uid()
      AND patient.clinic_id = session.clinic_id
    )
  );

-- Therapists can view sessions from their clinic
CREATE POLICY "Therapists can view clinic sessions"
  ON session FOR SELECT
  USING (
    therapist_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM therapist
      WHERE therapist.id = auth.uid()
      AND therapist.clinic_id = session.clinic_id
    )
  );

-- ============================================
-- THERAPY GOAL POLICIES (UPDATE)
-- ============================================

-- Therapists can view therapy goals from their clinic
CREATE POLICY "Therapists can view clinic therapy goals"
  ON therapy_goal FOR SELECT
  USING (
    therapist_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM therapist
      WHERE therapist.id = auth.uid()
      AND therapist.clinic_id = therapy_goal.clinic_id
    )
  );

-- ============================================
-- DAILY ACTIVITIES POLICIES (UPDATE)
-- ============================================

-- Patients can view their daily activities
CREATE POLICY "Patients can view their daily activities"
  ON daily_activities FOR SELECT
  USING (
    patient_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM patient
      WHERE patient.id = auth.uid()
      AND patient.clinic_id = daily_activities.clinic_id
    )
  );

-- Therapists can view daily activities for their clinic's patients
CREATE POLICY "Therapists can view clinic daily activities"
  ON daily_activities FOR SELECT
  USING (
    therapist_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM therapist
      WHERE therapist.id = auth.uid()
      AND therapist.clinic_id = daily_activities.clinic_id
    )
  );
