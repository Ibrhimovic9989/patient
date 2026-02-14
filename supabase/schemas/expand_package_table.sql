-- Expand Package Table
-- Add clinic-specific fields and create related tables for therapy details

-- Update existing package table
ALTER TABLE package ADD COLUMN clinic_id UUID REFERENCES clinic(id);
ALTER TABLE package ADD COLUMN price DECIMAL(10,2);
ALTER TABLE package ADD COLUMN validity_days INT4; -- Package validity in days
ALTER TABLE package ADD COLUMN description TEXT;
ALTER TABLE package ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

-- Indexes
CREATE INDEX idx_package_clinic_id ON package(clinic_id);
CREATE INDEX idx_package_is_active ON package(is_active);

-- Package Therapy Details Table
-- Stores therapy-specific details for each package (therapy types, session counts, frequency, duration)
CREATE TABLE package_therapy_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    package_id UUID REFERENCES package(id) ON DELETE CASCADE,
    therapy_type_id UUID REFERENCES therapy(id),
    session_count INT4 NOT NULL, -- Number of sessions for this therapy type
    frequency_per_week INT4, -- e.g., 2 = twice per week
    session_duration_minutes INT4, -- e.g., 30, 60 minutes
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(package_id, therapy_type_id) -- One therapy type per package
);

-- Indexes
CREATE INDEX idx_package_therapy_details_package_id ON package_therapy_details(package_id);
CREATE INDEX idx_package_therapy_details_therapy_type_id ON package_therapy_details(therapy_type_id);

-- Patient Package Table
-- Tracks which package a patient has subscribed to
CREATE TABLE patient_package (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patient(id) ON DELETE CASCADE,
    package_id UUID REFERENCES package(id),
    clinic_id UUID REFERENCES clinic(id),
    assigned_by UUID, -- clinic admin user id or patient id if self-selected
    assigned_at TIMESTAMPTZ DEFAULT NOW(),
    starts_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ,
    status TEXT NOT NULL CHECK (status IN ('active', 'completed', 'expired', 'cancelled')) DEFAULT 'active',
    sessions_used JSONB, -- Track sessions used per therapy type: {"therapy_type_id": count}
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_patient_package_patient_id ON patient_package(patient_id);
CREATE INDEX idx_patient_package_package_id ON patient_package(package_id);
CREATE INDEX idx_patient_package_clinic_id ON patient_package(clinic_id);
CREATE INDEX idx_patient_package_status ON patient_package(status);

-- Add comments
COMMENT ON TABLE package_therapy_details IS 'Therapy-specific details for each package (sessions, frequency, duration)';
COMMENT ON TABLE patient_package IS 'Tracks patient package subscriptions and session usage';
