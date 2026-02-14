-- Create patient_therapist_assignment table and RLS policies
-- This script should be run in Supabase SQL Editor

-- Create the junction table
CREATE TABLE IF NOT EXISTS patient_therapist_assignment (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patient(id) ON DELETE CASCADE,
    therapist_id UUID REFERENCES therapist(id) ON DELETE CASCADE,
    therapy_type_id UUID REFERENCES therapy(id) ON DELETE CASCADE,
    patient_package_id UUID REFERENCES patient_package(id) ON DELETE CASCADE,
    assigned_by UUID REFERENCES auth.users(id), -- Clinic admin
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(patient_id, therapist_id, therapy_type_id, patient_package_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_patient_therapist_assignment_patient_id ON patient_therapist_assignment(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_therapist_assignment_therapist_id ON patient_therapist_assignment(therapist_id);
CREATE INDEX IF NOT EXISTS idx_patient_therapist_assignment_therapy_type_id ON patient_therapist_assignment(therapy_type_id);
CREATE INDEX IF NOT EXISTS idx_patient_therapist_assignment_patient_package_id ON patient_therapist_assignment(patient_package_id);

COMMENT ON TABLE patient_therapist_assignment IS 'Junction table linking patients to therapists for specific therapy types within a package';

-- Enable RLS
ALTER TABLE patient_therapist_assignment ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Clinic admins can manage patient therapist assignments" ON patient_therapist_assignment;
DROP POLICY IF EXISTS "Therapists can view their assignments" ON patient_therapist_assignment;
DROP POLICY IF EXISTS "Patients can view their assignments" ON patient_therapist_assignment;

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
