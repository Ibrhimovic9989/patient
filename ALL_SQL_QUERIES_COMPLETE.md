# All SQL Queries - Complete & Ready to Run

## 📍 Where to Run
**Supabase Dashboard → SQL Editor → New Query**
Direct Link: https://supabase.com/dashboard/project/ouzgddcxfynjhwjnvdtb/sql/new

---

## ⚠️ CRITICAL: Run in Exact Order

Execute queries **1-7 in sequence**. Each query depends on the previous one.

---

## Query 1: Create Clinic Table

**File Location:** `supabase/schemas/clinic_tables.sql`

**Copy and Run This:**

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

## Query 2: Create Clinic Subscription Table

**File Location:** `supabase/schemas/clinic_subscription.sql`

**Copy and Run This:**

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

## Query 3: Update Patient Table

**File Location:** `supabase/schemas/update_patient_table.sql`

**Copy and Run This:**

```sql
-- Update Patient Table
-- Add clinic_id to link patients to their clinic

ALTER TABLE patient ADD COLUMN clinic_id UUID REFERENCES clinic(id);
CREATE INDEX idx_patient_clinic_id ON patient(clinic_id);

-- Add comment
COMMENT ON COLUMN patient.clinic_id IS 'The clinic this patient belongs to';
```

---

## Query 4: Expand Package Table

**File Location:** `supabase/schemas/expand_package_table.sql`

**Copy and Run This:**

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

## Query 5: Update Therapist Table

**File Location:** `supabase/schemas/update_therapist_table.sql`

**Copy and Run This:**

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

**⚠️ If this fails:** You may have existing therapists without `clinic_id`. Either assign clinics first or temporarily skip the foreign key constraint.

---

## Query 6: Add Clinic ID to Related Tables

**File Location:** `supabase/schemas/add_clinic_id_to_tables.sql`

**Copy and Run This:**

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

## Query 7: Create RLS Policies

**File Location:** `supabase/schemas/clinic_rls_policies.sql`

**⚠️ This is a large query (330+ lines). Copy the ENTIRE file contents.**

**File Path:** `C:\Users\camun\Documents\pts\NeuroTrack\supabase\schemas\clinic_rls_policies.sql`

**Or copy from here (complete):**

```sql
-- Clinic RLS Policies
-- Row Level Security policies for multi-tenant clinic isolation

-- Enable RLS on new tables
ALTER TABLE clinic ENABLE ROW LEVEL SECURITY;
ALTER TABLE clinic_subscription ENABLE ROW LEVEL SECURITY;
ALTER TABLE package_therapy_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_package ENABLE ROW LEVEL SECURITY;

-- ============================================
-- CLINIC TABLE POLICIES
-- ============================================

-- Clinic admins can view their own clinic
CREATE POLICY "Clinic admins can view their clinic"
  ON clinic FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.email = clinic.owner_email
    )
  );

-- ============================================
-- CLINIC SUBSCRIPTION POLICIES
-- ============================================

-- Clinic admins can view their clinic's subscription
CREATE POLICY "Clinic admins can view their subscription"
  ON clinic_subscription FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = clinic_subscription.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ============================================
-- PATIENT TABLE POLICIES (UPDATE)
-- ============================================

-- Drop existing patient policies that don't account for clinic_id
DROP POLICY IF EXISTS "Therapists can view their patients" ON patient;

-- Therapists can only see patients from their clinic
CREATE POLICY "Therapists can view patients from their clinic"
  ON patient FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM therapist
      WHERE therapist.id = auth.uid()
      AND therapist.clinic_id = patient.clinic_id
      AND (therapist.id = patient.therapist_id OR patient.therapist_id IS NULL)
    )
  );

-- Clinic admins can view all patients in their clinic
CREATE POLICY "Clinic admins can view clinic patients"
  ON patient FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- Clinic admins can update patients in their clinic (e.g., assign therapist)
CREATE POLICY "Clinic admins can update clinic patients"
  ON patient FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ============================================
-- THERAPIST TABLE POLICIES (UPDATE)
-- ============================================

-- Therapists can only see therapists from their clinic
CREATE POLICY "Therapists can view clinic therapists"
  ON therapist FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM therapist t
      WHERE t.id = auth.uid()
      AND t.clinic_id = therapist.clinic_id
    )
  );

-- Clinic admins can view all therapists in their clinic
CREATE POLICY "Clinic admins can view clinic therapists"
  ON therapist FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- Clinic admins can insert therapists in their clinic
CREATE POLICY "Clinic admins can insert clinic therapists"
  ON therapist FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- Clinic admins can update therapists in their clinic
CREATE POLICY "Clinic admins can update clinic therapists"
  ON therapist FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ============================================
-- PACKAGE TABLE POLICIES
-- ============================================

-- Patients can view packages from their clinic
CREATE POLICY "Patients can view clinic packages"
  ON package FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM patient
      WHERE patient.id = auth.uid()
      AND patient.clinic_id = package.clinic_id
      AND package.is_active = TRUE
    )
  );

-- Clinic admins can manage packages in their clinic
CREATE POLICY "Clinic admins can manage clinic packages"
  ON package FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = package.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = package.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ============================================
-- PACKAGE THERAPY DETAILS POLICIES
-- ============================================

-- Patients can view therapy details for their clinic's packages
CREATE POLICY "Patients can view package therapy details"
  ON package_therapy_details FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM package p
      JOIN patient pt ON pt.clinic_id = p.clinic_id
      WHERE pt.id = auth.uid()
      AND p.id = package_therapy_details.package_id
    )
  );

-- Clinic admins can manage therapy details for their packages
CREATE POLICY "Clinic admins can manage package therapy details"
  ON package_therapy_details FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM package p
      JOIN clinic c ON c.id = p.clinic_id
      WHERE c.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
      AND p.id = package_therapy_details.package_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM package p
      JOIN clinic c ON c.id = p.clinic_id
      WHERE c.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
      AND p.id = package_therapy_details.package_id
    )
  );

-- ============================================
-- PATIENT PACKAGE POLICIES
-- ============================================

-- Patients can view their own packages
CREATE POLICY "Patients can view their packages"
  ON patient_package FOR SELECT
  USING (patient_id = auth.uid());

-- Patients can insert their own package selection
CREATE POLICY "Patients can select packages"
  ON patient_package FOR INSERT
  WITH CHECK (
    patient_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM patient
      WHERE patient.id = auth.uid()
      AND patient.clinic_id = patient_package.clinic_id
    )
  );

-- Clinic admins can view and manage packages for their clinic's patients
CREATE POLICY "Clinic admins can manage patient packages"
  ON patient_package FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient_package.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient_package.clinic_id
      AND clinic.owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    )
  );

-- ============================================
-- SESSION TABLE POLICIES (UPDATE)
-- ============================================

-- Drop existing session policies if they exist
DROP POLICY IF EXISTS "Patients can view their own sessions" ON session;
DROP POLICY IF EXISTS "Therapists can view their sessions" ON session;

-- Patients can view sessions from their clinic
CREATE POLICY "Patients can view clinic sessions"
  ON session FOR SELECT
  USING (
    patient_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM patient
      WHERE patient.id = auth.uid()
      AND patient.clinic_id = session.clinic_id
    )
  );

-- Therapists can view sessions from their clinic
CREATE POLICY "Therapists can view clinic sessions"
  ON session FOR SELECT
  USING (
    therapist_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM therapist
      WHERE therapist.id = auth.uid()
      AND therapist.clinic_id = session.clinic_id
    )
  );

-- ============================================
-- THERAPY GOAL POLICIES (UPDATE)
-- ============================================

-- Therapists can view therapy goals from their clinic
CREATE POLICY "Therapists can view clinic therapy goals"
  ON therapy_goal FOR SELECT
  USING (
    therapist_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM therapist
      WHERE therapist.id = auth.uid()
      AND therapist.clinic_id = therapy_goal.clinic_id
    )
  );

-- ============================================
-- DAILY ACTIVITIES POLICIES (UPDATE)
-- ============================================

-- Patients can view their daily activities
CREATE POLICY "Patients can view their daily activities"
  ON daily_activities FOR SELECT
  USING (
    patient_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM patient
      WHERE patient.id = auth.uid()
      AND patient.clinic_id = daily_activities.clinic_id
    )
  );

-- Therapists can view daily activities for their clinic's patients
CREATE POLICY "Therapists can view clinic daily activities"
  ON daily_activities FOR SELECT
  USING (
    therapist_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM therapist
      WHERE therapist.id = auth.uid()
      AND therapist.clinic_id = daily_activities.clinic_id
    )
  );
```

---

## 🔧 Edge Functions to Deploy

### Function 1: Check Clinic Subscription

**File Location:** `supabase/functions/check-clinic-subscription/index.ts`

**Deploy Steps:**
1. Go to: **Supabase Dashboard → Edge Functions**
2. Click **Create a new function**
3. Name: `check-clinic-subscription`
4. Copy **entire contents** of `supabase/functions/check-clinic-subscription/index.ts`
5. Paste into editor
6. Click **Deploy**

---

### Function 2: Evaluate Assessments (Verify)

**File Location:** `supabase/functions/evaluate-assessments/index.ts`

**Action:**
- Verify it exists in Edge Functions
- If missing CORS headers, update with latest code
- Should already be deployed from previous fixes

---

## ✅ Verification

After running all queries, verify with:

```sql
-- Check tables
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('clinic', 'clinic_subscription', 'package_therapy_details', 'patient_package');

-- Check clinic_id columns
SELECT table_name, column_name FROM information_schema.columns 
WHERE column_name = 'clinic_id' AND table_schema = 'public';
```

---

## 📋 Summary

**SQL Queries (7 total):**
1. `supabase/schemas/clinic_tables.sql`
2. `supabase/schemas/clinic_subscription.sql`
3. `supabase/schemas/update_patient_table.sql`
4. `supabase/schemas/expand_package_table.sql`
5. `supabase/schemas/update_therapist_table.sql`
6. `supabase/schemas/add_clinic_id_to_tables.sql`
7. `supabase/schemas/clinic_rls_policies.sql`

**Edge Functions (2 total):**
1. `supabase/functions/check-clinic-subscription/index.ts` (NEW - Deploy)
2. `supabase/functions/evaluate-assessments/index.ts` (Verify/Update)
