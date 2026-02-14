-- Fix Clinic RLS Policies
-- Replace auth.users queries with JWT email extraction
-- Run this in Supabase SQL Editor

-- Drop existing clinic policies
DROP POLICY IF EXISTS "Clinic admins can view their clinic" ON clinic;
DROP POLICY IF EXISTS "Clinic admins can view their subscription" ON clinic_subscription;

-- ============================================
-- CLINIC TABLE POLICIES (FIXED)
-- ============================================

-- Clinic admins can view their own clinic (using JWT email)
CREATE POLICY "Clinic admins can view their clinic"
  ON clinic FOR SELECT
  USING (
    (auth.jwt() ->> 'email')::text = clinic.owner_email
  );

-- ============================================
-- CLINIC SUBSCRIPTION POLICIES (FIXED)
-- ============================================

-- Clinic admins can view their clinic's subscription
CREATE POLICY "Clinic admins can view their subscription"
  ON clinic_subscription FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = clinic_subscription.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  );

-- ============================================
-- UPDATE OTHER POLICIES THAT USE auth.users
-- ============================================

-- Drop and recreate patient policies
DROP POLICY IF EXISTS "Clinic admins can view clinic patients" ON patient;
DROP POLICY IF EXISTS "Clinic admins can update clinic patients" ON patient;

CREATE POLICY "Clinic admins can view clinic patients"
  ON patient FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  );

CREATE POLICY "Clinic admins can update clinic patients"
  ON patient FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  );

-- Drop and recreate therapist policies
DROP POLICY IF EXISTS "Clinic admins can view clinic therapists" ON therapist;
DROP POLICY IF EXISTS "Clinic admins can insert clinic therapists" ON therapist;
DROP POLICY IF EXISTS "Clinic admins can update clinic therapists" ON therapist;

CREATE POLICY "Clinic admins can view clinic therapists"
  ON therapist FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  );

CREATE POLICY "Clinic admins can insert clinic therapists"
  ON therapist FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  );

CREATE POLICY "Clinic admins can update clinic therapists"
  ON therapist FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = therapist.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  );

-- Drop and recreate package policies
DROP POLICY IF EXISTS "Clinic admins can manage clinic packages" ON package;

CREATE POLICY "Clinic admins can manage clinic packages"
  ON package FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = package.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = package.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  );

-- Drop and recreate package therapy details policies
DROP POLICY IF EXISTS "Clinic admins can manage package therapy details" ON package_therapy_details;

CREATE POLICY "Clinic admins can manage package therapy details"
  ON package_therapy_details FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM package p
      JOIN clinic c ON c.id = p.clinic_id
      WHERE c.owner_email = (auth.jwt() ->> 'email')::text
      AND p.id = package_therapy_details.package_id
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM package p
      JOIN clinic c ON c.id = p.clinic_id
      WHERE c.owner_email = (auth.jwt() ->> 'email')::text
      AND p.id = package_therapy_details.package_id
    )
  );

-- Drop and recreate patient package policies
DROP POLICY IF EXISTS "Clinic admins can manage patient packages" ON patient_package;

CREATE POLICY "Clinic admins can manage patient packages"
  ON patient_package FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient_package.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM clinic
      WHERE clinic.id = patient_package.clinic_id
      AND clinic.owner_email = (auth.jwt() ->> 'email')::text
    )
  );
