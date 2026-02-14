-- RLS Policies for Patient-Therapist Assignment Junction Table

ALTER TABLE patient_therapist_assignment ENABLE ROW LEVEL SECURITY;

-- Clinic admins can manage assignments for their clinic's patients
CREATE POLICY "Clinic admins can manage patient therapist assignments"
  ON patient_therapist_assignment FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM patient p
      JOIN clinic c ON p.clinic_id = c.id
      WHERE p.id = patient_therapist_assignment.patient_id
      AND c.owner_email = (auth.jwt() ->> 'email')::text
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM patient p
      JOIN clinic c ON p.clinic_id = c.id
      WHERE p.id = patient_therapist_assignment.patient_id
      AND c.owner_email = (auth.jwt() ->> 'email')::text
    )
  );

-- Therapists can view their own assignments
CREATE POLICY "Therapists can view their assignments"
  ON patient_therapist_assignment FOR SELECT
  USING (
    therapist_id = auth.uid()
    AND is_active = TRUE
  );

-- Patients can view their own assignments
CREATE POLICY "Patients can view their assignments"
  ON patient_therapist_assignment FOR SELECT
  USING (
    patient_id = auth.uid()
    AND is_active = TRUE
  );
