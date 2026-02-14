-- Patient-Therapist-Therapy Type Assignment Junction Table
-- Supports multiple therapist assignments per patient for different therapy types

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

CREATE INDEX IF NOT EXISTS idx_patient_therapist_assignment_patient_id ON patient_therapist_assignment(patient_id);
CREATE INDEX IF NOT EXISTS idx_patient_therapist_assignment_therapist_id ON patient_therapist_assignment(therapist_id);
CREATE INDEX IF NOT EXISTS idx_patient_therapist_assignment_therapy_type_id ON patient_therapist_assignment(therapy_type_id);
CREATE INDEX IF NOT EXISTS idx_patient_therapist_assignment_patient_package_id ON patient_therapist_assignment(patient_package_id);

COMMENT ON TABLE patient_therapist_assignment IS 'Junction table linking patients to therapists for specific therapy types within a package';
