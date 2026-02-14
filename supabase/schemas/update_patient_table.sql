-- Update Patient Table
-- Add clinic_id to link patients to their clinic

ALTER TABLE patient ADD COLUMN clinic_id UUID REFERENCES clinic(id);
CREATE INDEX idx_patient_clinic_id ON patient(clinic_id);

-- Add comment
COMMENT ON COLUMN patient.clinic_id IS 'The clinic this patient belongs to';
