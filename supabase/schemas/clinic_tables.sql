-- Clinic Table
-- Represents therapy centers/clinics that are tenants in the SaaS platform

CREATE TABLE clinic (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT NOT NULL,
    address TEXT,
    country TEXT,
    owner_name TEXT,
    owner_email TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

-- Index for faster lookups
CREATE INDEX idx_clinic_email ON clinic(email);
CREATE INDEX idx_clinic_is_active ON clinic(is_active);

-- Add comment
COMMENT ON TABLE clinic IS 'Therapy centers/clinics that are tenants in the SaaS platform';
