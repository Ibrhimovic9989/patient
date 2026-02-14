-- RLS Policy for Clinic Onboarding
-- Allows authenticated users to insert clinic records for onboarding (pending approval)

-- Allow authenticated users to insert clinic records with is_active = false
-- This enables the clinic onboarding form to work
CREATE POLICY "Authenticated users can submit clinic onboarding"
  ON clinic FOR INSERT
  TO authenticated
  WITH CHECK (
    -- User can only set their own email as owner_email
    owner_email = (SELECT email FROM auth.users WHERE id = auth.uid())
    -- Can only create clinics with is_active = false (pending approval)
    AND is_active = false
  );

-- Note: Clinic activation (setting is_active = true) should be done
-- by administrators using the service role key or through a separate admin interface

-- IMPORTANT: Run approve_existing_clinics.sql to approve all current clinic users
