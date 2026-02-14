-- Daily Activities Phase 1 Schema Updates

-- Add instructions column to daily_activities table
-- Structure: JSONB array of {activity_id, instructions}
ALTER TABLE daily_activities 
ADD COLUMN IF NOT EXISTS instructions JSONB DEFAULT '[]'::jsonb;

-- Add parent_notes column to daily_activity_logs table
-- Structure: JSONB array of {activity_id, note, timestamp}
ALTER TABLE daily_activity_logs 
ADD COLUMN IF NOT EXISTS parent_notes JSONB DEFAULT '[]'::jsonb;

-- Add media_attachments column to daily_activity_logs table
-- Structure: JSONB array of {activity_id, media_url, media_type, uploaded_at}
ALTER TABLE daily_activity_logs 
ADD COLUMN IF NOT EXISTS media_attachments JSONB DEFAULT '[]'::jsonb;

-- Add reminder_settings column to daily_activities table
-- Structure: {enabled: boolean, reminder_times: [string], timezone: string}
ALTER TABLE daily_activities 
ADD COLUMN IF NOT EXISTS reminder_settings JSONB DEFAULT '{"enabled": false, "reminder_times": [], "timezone": "UTC"}'::jsonb;

-- Create notification_queue table for scheduled notifications
CREATE TABLE IF NOT EXISTS notification_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID REFERENCES patient(id) ON DELETE CASCADE,
    activity_set_id UUID REFERENCES daily_activities(id) ON DELETE CASCADE,
    scheduled_time TIMESTAMPTZ NOT NULL,
    notification_type TEXT NOT NULL CHECK (notification_type IN ('reminder', 'summary')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'sent', 'failed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for notification_queue
CREATE INDEX IF NOT EXISTS idx_notification_queue_patient_id ON notification_queue(patient_id);
CREATE INDEX IF NOT EXISTS idx_notification_queue_scheduled_time ON notification_queue(scheduled_time);
CREATE INDEX IF NOT EXISTS idx_notification_queue_status ON notification_queue(status);

-- RLS policies for notification_queue
ALTER TABLE notification_queue ENABLE ROW LEVEL SECURITY;

-- Patients can view their own notification queue entries
CREATE POLICY "Patients can view their own notification queue"
  ON notification_queue FOR SELECT
  USING (auth.uid() = patient_id);

-- Therapists can view notification queue for their patients
CREATE POLICY "Therapists can view notification queue for their patients"
  ON notification_queue FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM daily_activities 
      WHERE daily_activities.id = notification_queue.activity_set_id 
      AND daily_activities.therapist_id = auth.uid()
    )
  );
