-- Fix infinite recursion in therapist RLS policies
-- The issue: Policies that query the therapist table cause recursion when checking RLS

-- Drop the problematic policy
DROP POLICY IF EXISTS "Therapists can view clinic therapists" ON therapist;

-- Use a SECURITY DEFINER function to get clinic_id without triggering RLS
CREATE OR REPLACE FUNCTION get_therapist_clinic_id(user_id UUID)
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT clinic_id FROM therapist WHERE id = user_id LIMIT 1;
$$;

-- Now create the policy using the function (SECURITY DEFINER bypasses RLS)
CREATE POLICY "Therapists can view clinic therapists"
  ON therapist FOR SELECT
  USING (
    -- Allow viewing own record
    id = auth.uid()
    OR
    -- Allow viewing therapists in same clinic (using function to avoid recursion)
    (clinic_id IS NOT NULL AND clinic_id = get_therapist_clinic_id(auth.uid()))
  );
