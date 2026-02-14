-- Update Therapist Table
-- Make clinic_id required and add foreign key constraint

-- First, update any existing NULL clinic_id values (if any) - this will fail if there are NULLs
-- In production, you'd need to assign clinics first
-- For now, we'll make it nullable temporarily, then enforce it

-- Add foreign key constraint
ALTER TABLE therapist ADD CONSTRAINT fk_therapist_clinic 
    FOREIGN KEY (clinic_id) REFERENCES clinic(id);

-- Create index if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_therapist_clinic_id ON therapist(clinic_id);

-- Add comment
COMMENT ON COLUMN therapist.clinic_id IS 'The clinic this therapist belongs to (required)';
