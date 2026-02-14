-- RLS Policies for Therapists to manage daily_activity_logs
-- Therapists need to be able to insert logs when creating/updating activity sets

-- Drop existing policy if it exists (to allow re-running)
DROP POLICY IF EXISTS "Therapists can insert activity logs for their patients" ON daily_activity_logs;
DROP POLICY IF EXISTS "Therapists can view activity logs for their patients" ON daily_activity_logs;
DROP POLICY IF EXISTS "Therapists can delete activity logs for their patients" ON daily_activity_logs;

-- Therapists can view activity logs for their patients
CREATE POLICY "Therapists can view activity logs for their patients"
  ON daily_activity_logs FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM daily_activities
      WHERE daily_activities.id = daily_activity_logs.activity_id
      AND daily_activities.therapist_id = auth.uid()
    )
  );

-- Therapists can insert activity logs for their patients
-- This allows therapists to create logs when setting up activity sets
CREATE POLICY "Therapists can insert activity logs for their patients"
  ON daily_activity_logs FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM daily_activities
      WHERE daily_activities.id = daily_activity_logs.activity_id
      AND daily_activities.therapist_id = auth.uid()
      AND daily_activities.patient_id = daily_activity_logs.patient_id
    )
  );

-- Therapists can delete activity logs for their patients
-- This allows therapists to clean up logs when updating activity sets
CREATE POLICY "Therapists can delete activity logs for their patients"
  ON daily_activity_logs FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM daily_activities
      WHERE daily_activities.id = daily_activity_logs.activity_id
      AND daily_activities.therapist_id = auth.uid()
    )
  );
