-- Clinic Subscription Table
-- Tracks subscription status for each clinic (SaaS model)

CREATE TABLE clinic_subscription (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clinic_id UUID REFERENCES clinic(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    subscription_tier TEXT NOT NULL CHECK (subscription_tier IN ('basic', 'premium', 'enterprise')),
    status TEXT NOT NULL CHECK (status IN ('active', 'expired', 'cancelled')) DEFAULT 'active',
    starts_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ,
    payment_amount DECIMAL(10,2),
    payment_date TIMESTAMPTZ,
    granted_by UUID REFERENCES auth.users(id), -- SaaS owner who granted it
    notes TEXT -- Additional notes about the subscription
);

-- Indexes for faster lookups
CREATE INDEX idx_clinic_subscription_clinic_id ON clinic_subscription(clinic_id);
CREATE INDEX idx_clinic_subscription_status ON clinic_subscription(status);
CREATE INDEX idx_clinic_subscription_expires_at ON clinic_subscription(expires_at);

-- Add comment
COMMENT ON TABLE clinic_subscription IS 'Tracks subscription status and billing for clinic tenants';
