-- Package Schedule Configuration Table
-- Stores scheduling preferences for each therapy type in a patient package

CREATE TABLE IF NOT EXISTS package_schedule_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_package_id UUID NOT NULL REFERENCES patient_package(id) ON DELETE CASCADE,
    therapy_type_id UUID NOT NULL REFERENCES therapy(id),
    days_of_week INT2[] NOT NULL, -- Array of day numbers (0=Sunday, 1=Monday, ..., 6=Saturday)
    time_slot TIME NOT NULL, -- Session time (e.g., "09:00:00")
    created_by UUID REFERENCES auth.users(id), -- Clinic admin who configured it
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(patient_package_id, therapy_type_id) -- One schedule config per therapy type per package
);

-- Add indexes
CREATE INDEX IF NOT EXISTS idx_package_schedule_config_patient_package_id ON package_schedule_config(patient_package_id);
CREATE INDEX IF NOT EXISTS idx_package_schedule_config_therapy_type_id ON package_schedule_config(therapy_type_id);
CREATE INDEX IF NOT EXISTS idx_package_schedule_config_created_by ON package_schedule_config(created_by);

-- Add comments
COMMENT ON TABLE package_schedule_config IS 'Scheduling configuration for therapy types within patient packages';
COMMENT ON COLUMN package_schedule_config.days_of_week IS 'Array of day numbers: 0=Sunday, 1=Monday, ..., 6=Saturday';
COMMENT ON COLUMN package_schedule_config.time_slot IS 'Time of day for sessions (HH:MM:SS format)';

-- Enable RLS
ALTER TABLE package_schedule_config ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Clinic admins can view schedule configs for their clinic's patients
CREATE POLICY "Clinic admins can view schedule configs for their clinic"
    ON package_schedule_config FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM patient_package pp
            JOIN patient p ON pp.patient_id = p.id
            JOIN clinic c ON p.clinic_id = c.id
            WHERE pp.id = package_schedule_config.patient_package_id
            AND (auth.jwt() ->> 'email')::text = c.owner_email
        )
    );

-- Clinic admins can insert schedule configs for their clinic's patients
CREATE POLICY "Clinic admins can create schedule configs for their clinic"
    ON package_schedule_config FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM patient_package pp
            JOIN patient p ON pp.patient_id = p.id
            JOIN clinic c ON p.clinic_id = c.id
            WHERE pp.id = package_schedule_config.patient_package_id
            AND (auth.jwt() ->> 'email')::text = c.owner_email
        )
    );

-- Clinic admins can update schedule configs for their clinic's patients
CREATE POLICY "Clinic admins can update schedule configs for their clinic"
    ON package_schedule_config FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM patient_package pp
            JOIN patient p ON pp.patient_id = p.id
            JOIN clinic c ON p.clinic_id = c.id
            WHERE pp.id = package_schedule_config.patient_package_id
            AND (auth.jwt() ->> 'email')::text = c.owner_email
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM patient_package pp
            JOIN patient p ON pp.patient_id = p.id
            JOIN clinic c ON p.clinic_id = c.id
            WHERE pp.id = package_schedule_config.patient_package_id
            AND (auth.jwt() ->> 'email')::text = c.owner_email
        )
    );

-- Therapists can view schedule configs for their patients
CREATE POLICY "Therapists can view schedule configs for their patients"
    ON package_schedule_config FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM patient_package pp
            JOIN patient p ON pp.patient_id = p.id
            WHERE pp.id = package_schedule_config.patient_package_id
            AND p.therapist_id = auth.uid()
        )
    );

-- Patients can view their own schedule configs
CREATE POLICY "Patients can view their own schedule configs"
    ON package_schedule_config FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM patient_package pp
            WHERE pp.id = package_schedule_config.patient_package_id
            AND pp.patient_id = auth.uid()
        )
    );
