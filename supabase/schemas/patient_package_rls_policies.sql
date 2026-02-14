-- RLS Policies for patient_package table
-- Allow therapists to view packages for patients they're assigned to

ALTER TABLE patient_package ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Patients can view their own packages" ON patient_package;
DROP POLICY IF EXISTS "Therapists can view packages for assigned patients" ON patient_package;
DROP POLICY IF EXISTS "Clinic admins can view packages for clinic patients" ON patient_package;

-- Patients can view their own packages
CREATE POLICY "Patients can view their own packages"
  ON patient_package FOR SELECT
  USING (auth.uid() = patient_id);

-- Therapists can view packages for patients they're assigned to
CREATE POLICY "Therapists can view packages for assigned patients"
  ON patient_package FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM patient_therapist_assignment
      WHERE patient_therapist_assignment.patient_id = patient_package.patient_id
      AND patient_therapist_assignment.therapist_id = auth.uid()
      AND patient_therapist_assignment.is_active = TRUE
    )
  );

-- Clinic admins can view packages for patients in their clinic
CREATE POLICY "Clinic admins can view packages for clinic patients"
  ON patient_package FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM patient p
      JOIN clinic c ON p.clinic_id = c.id
      WHERE p.id = patient_package.patient_id
      AND c.owner_email = (auth.jwt() ->> 'email')::text
    )
  );

-- RLS Policies for package_therapy_details table
-- Allow therapists to view therapy details for packages of assigned patients

ALTER TABLE package_therapy_details ENABLE ROW LEVEL SECURITY;

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Therapists can view therapy details for assigned patient packages" ON package_therapy_details;

-- Therapists can view therapy details for assigned patient packages
CREATE POLICY "Therapists can view therapy details for assigned patient packages"
  ON package_therapy_details FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM patient_package pp
      JOIN patient_therapist_assignment pta ON pp.patient_id = pta.patient_id
      WHERE pp.package_id = package_therapy_details.package_id
      AND pta.therapist_id = auth.uid()
      AND pta.is_active = TRUE
    )
    OR
    EXISTS (
      SELECT 1 FROM patient_package pp
      WHERE pp.package_id = package_therapy_details.package_id
      AND pp.patient_id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 FROM patient_package pp
      JOIN patient p ON pp.patient_id = p.id
      JOIN clinic c ON p.clinic_id = c.id
      WHERE pp.package_id = package_therapy_details.package_id
      AND c.owner_email = (auth.jwt() ->> 'email')::text
    )
  );
