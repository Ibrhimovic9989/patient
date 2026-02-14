-- Link Sessions to Packages
-- Add package and therapy type references to session table

-- Add package-related columns to session table
ALTER TABLE session ADD COLUMN IF NOT EXISTS package_id UUID REFERENCES package(id);
ALTER TABLE session ADD COLUMN IF NOT EXISTS therapy_type_id UUID REFERENCES therapy(id);
ALTER TABLE session ADD COLUMN IF NOT EXISTS patient_package_id UUID REFERENCES patient_package(id);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_session_package_id ON session(package_id);
CREATE INDEX IF NOT EXISTS idx_session_therapy_type_id ON session(therapy_type_id);
CREATE INDEX IF NOT EXISTS idx_session_patient_package_id ON session(patient_package_id);

-- Add comments
COMMENT ON COLUMN session.package_id IS 'The package this session belongs to';
COMMENT ON COLUMN session.therapy_type_id IS 'The therapy type for this session';
COMMENT ON COLUMN session.patient_package_id IS 'The patient package subscription this session is part of';

-- Update RLS policies to include package-based access
-- Note: Existing policies should still work, but we can add package-based policies if needed
-- For now, existing policies (therapist_id, patient_id) are sufficient
