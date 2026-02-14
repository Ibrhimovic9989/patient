-- RLS Policy for therapists to update therapy goals
-- This allows therapists to update therapy goals they created

-- Drop existing policy if it exists
DROP POLICY IF EXISTS "Therapists can update therapy goals" ON therapy_goal;

-- Therapists can update therapy goals they created
CREATE POLICY "Therapists can update therapy goals"
  ON therapy_goal FOR UPDATE
  USING (auth.uid() = therapist_id)
  WITH CHECK (auth.uid() = therapist_id);
