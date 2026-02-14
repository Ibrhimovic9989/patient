-- Link Therapy Goals to Packages
-- Add package references to therapy_goal table

-- Add package-related columns to therapy_goal table
ALTER TABLE therapy_goal ADD COLUMN IF NOT EXISTS package_id UUID REFERENCES package(id);
ALTER TABLE therapy_goal ADD COLUMN IF NOT EXISTS patient_package_id UUID REFERENCES patient_package(id);

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_therapy_goal_package_id ON therapy_goal(package_id);
CREATE INDEX IF NOT EXISTS idx_therapy_goal_patient_package_id ON therapy_goal(patient_package_id);

-- Add comments
COMMENT ON COLUMN therapy_goal.package_id IS 'The package this therapy goal belongs to';
COMMENT ON COLUMN therapy_goal.patient_package_id IS 'The patient package subscription this goal is part of';

-- RLS policies already exist for therapy_goal based on therapist_id and patient_id
-- These should continue to work with the new package columns
