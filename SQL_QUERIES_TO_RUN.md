# SQL Queries to Run - Complete List

## 📍 Access Point
**Supabase Dashboard → SQL Editor → New Query**
URL: https://supabase.com/dashboard/project/YOUR_PROJECT_ID/sql/new

---

## ✅ Query 1: Create Clinic Table

**File:** `supabase/schemas/clinic_tables.sql`

**Full Path:** `C:\Users\camun\Documents\pts\NeuroTrack\supabase\schemas\clinic_tables.sql`

**SQL Code:**
```sql
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
```

---

## ✅ Query 2: Create Clinic Subscription Table

**File:** `supabase/schemas/clinic_subscription.sql`

**Full Path:** `C:\Users\camun\Documents\pts\NeuroTrack\supabase\schemas\clinic_subscription.sql`

**SQL Code:**
```sql
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
```

---

## ✅ Query 3: Update Patient Table

**File:** `supabase/schemas/update_patient_table.sql`

**Full Path:** `C:\Users\camun\Documents\pts\NeuroTrack\supabase\schemas\update_patient_table.sql`

**SQL Code:**
```sql
-- Update Patient Table
-- Add clinic_id to link patients to their clinic

ALTER TABLE patient ADD COLUMN clinic_id UUID REFERENCES clinic(id);
CREATE INDEX idx_patient_clinic_id ON patient(clinic_id);

-- Add comment
COMMENT ON COLUMN patient.clinic_id IS 'The clinic this patient belongs to';
```

---

## ✅ Query 4: Expand Package Table

**File:** `supabase/schemas/expand_package_table.sql`

**Full Path:** `C:\Users\camun\Documents\pts\NeuroTrack\supabase\schemas\expand_package_table.sql`

**SQL Code:**
```sql
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
```

---

## ✅ Query 5: Update Therapist Table

**File:** `supabase/schemas/update_therapist_table.sql`

**Full Path:** `C:\Users\camun\Documents\pts\NeuroTrack\supabase\schemas\update_therapist_table.sql`

**SQL Code:**
```sql
-- Update Therapist Table
-- Make clinic_id required and add foreign key constraint

-- Add foreign key constraint
ALTER TABLE therapist ADD CONSTRAINT fk_therapist_clinic 
    FOREIGN KEY (clinic_id) REFERENCES clinic(id);

-- Create index if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_therapist_clinic_id ON therapist(clinic_id);

-- Add comment
COMMENT ON COLUMN therapist.clinic_id IS 'The clinic this therapist belongs to (required)';
```

**⚠️ Note:** If you have existing therapists without `clinic_id`, this may fail. Either:
- Assign clinics to existing therapists first, OR
- Temporarily comment out the foreign key constraint line

---

## ✅ Query 6: Add Clinic ID to Related Tables

**File:** `supabase/schemas/add_clinic_id_to_tables.sql`

**Full Path:** `C:\Users\camun\Documents\pts\NeuroTrack\supabase\schemas\add_clinic_id_to_tables.sql`

**SQL Code:**
```sql
-- Add Clinic ID to Related Tables
-- Ensure all clinic-scoped data has clinic_id for multi-tenancy

-- Sessions should be clinic-scoped
ALTER TABLE session ADD COLUMN clinic_id UUID REFERENCES clinic(id);
CREATE INDEX idx_session_clinic_id ON session(clinic_id);

-- Therapy goals should be clinic-scoped
ALTER TABLE therapy_goal ADD COLUMN clinic_id UUID REFERENCES clinic(id);
CREATE INDEX idx_therapy_goal_clinic_id ON therapy_goal(clinic_id);

-- Daily activities should be clinic-scoped
ALTER TABLE daily_activities ADD COLUMN clinic_id UUID REFERENCES clinic(id);
CREATE INDEX idx_daily_activities_clinic_id ON daily_activities(clinic_id);

-- Add comments
COMMENT ON COLUMN session.clinic_id IS 'The clinic this session belongs to';
COMMENT ON COLUMN therapy_goal.clinic_id IS 'The clinic this therapy goal belongs to';
COMMENT ON COLUMN daily_activities.clinic_id IS 'The clinic this daily activity belongs to';
```

---

## ✅ Query 7: Create RLS Policies

**File:** `supabase/schemas/clinic_rls_policies.sql`

**Full Path:** `C:\Users\camun\Documents\pts\NeuroTrack\supabase\schemas\clinic_rls_policies.sql`

**⚠️ IMPORTANT:** This file is large (330+ lines). Copy the ENTIRE file contents.

**Key Sections:**
- Enables RLS on new tables
- Creates policies for clinic isolation
- Updates existing patient/therapist policies
- Adds clinic-scoped policies for sessions, therapy_goals, daily_activities

**Note:** Review policies - they reference `owner_email` for clinic admin identification.

---

## 📋 Execution Checklist

Copy each file's contents in order:

1. [ ] `supabase/schemas/clinic_tables.sql` → Run in SQL Editor
2. [ ] `supabase/schemas/clinic_subscription.sql` → Run in SQL Editor
3. [ ] `supabase/schemas/update_patient_table.sql` → Run in SQL Editor
4. [ ] `supabase/schemas/expand_package_table.sql` → Run in SQL Editor
5. [ ] `supabase/schemas/update_therapist_table.sql` → Run in SQL Editor
6. [ ] `supabase/schemas/add_clinic_id_to_tables.sql` → Run in SQL Editor
7. [ ] `supabase/schemas/clinic_rls_policies.sql` → Run in SQL Editor

---

## 🔧 Edge Functions to Deploy

### Function 1: Check Clinic Subscription

**File:** `supabase/functions/check-clinic-subscription/index.ts`

**Full Path:** `C:\Users\camun\Documents\pts\NeuroTrack\supabase\functions\check-clinic-subscription\index.ts`

**Deploy via:** Supabase Dashboard → Edge Functions → Create Function → Name: `check-clinic-subscription`

### Function 2: Evaluate Assessments (Verify)

**File:** `supabase/functions/evaluate-assessments/index.ts`

**Full Path:** `C:\Users\camun\Documents\pts\NeuroTrack\supabase\functions\evaluate-assessments\index.ts`

**Action:** Verify it exists and has CORS headers

---

## ✅ Verification Queries

After running all queries, run these to verify:

```sql
-- Check tables created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('clinic', 'clinic_subscription', 'package_therapy_details', 'patient_package')
ORDER BY table_name;
```

```sql
-- Check clinic_id columns
SELECT table_name, column_name 
FROM information_schema.columns 
WHERE column_name = 'clinic_id' 
AND table_schema = 'public'
ORDER BY table_name;
```
