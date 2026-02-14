-- Row Level Security (RLS) Policies
-- These policies allow authenticated users to manage their own records

-- Enable RLS on all tables
ALTER TABLE therapist ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient ENABLE ROW LEVEL SECURITY;
ALTER TABLE session ENABLE ROW LEVEL SECURITY;
ALTER TABLE therapy_goal ENABLE ROW LEVEL SECURITY;
ALTER TABLE assessment_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_activity_logs ENABLE ROW LEVEL SECURITY;

-- THERAPIST TABLE POLICIES
-- Allow users to read their own therapist record
CREATE POLICY "Users can view their own therapist record"
  ON therapist FOR SELECT
  USING (auth.uid() = id);

-- Allow users to insert their own therapist record
CREATE POLICY "Users can insert their own therapist record"
  ON therapist FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Allow users to update their own therapist record
CREATE POLICY "Users can update their own therapist record"
  ON therapist FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- PATIENT TABLE POLICIES
-- Allow users to read their own patient record
CREATE POLICY "Users can view their own patient record"
  ON patient FOR SELECT
  USING (auth.uid() = id);

-- Allow users to insert their own patient record
CREATE POLICY "Users can insert their own patient record"
  ON patient FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Allow users to update their own patient record
CREATE POLICY "Users can update their own patient record"
  ON patient FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Allow therapists to view their patients
CREATE POLICY "Therapists can view their patients"
  ON patient FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM therapist
      WHERE therapist.id = auth.uid()
      AND therapist.id = patient.therapist_id
    )
  );

-- SESSION TABLE POLICIES
-- Patients can view their own sessions
CREATE POLICY "Patients can view their own sessions"
  ON session FOR SELECT
  USING (auth.uid() = patient_id);

-- Therapists can view sessions with their patients
CREATE POLICY "Therapists can view sessions with their patients"
  ON session FOR SELECT
  USING (auth.uid() = therapist_id);

-- Patients can create sessions
CREATE POLICY "Patients can create sessions"
  ON session FOR INSERT
  WITH CHECK (auth.uid() = patient_id);

-- Therapists can update sessions they're involved in
CREATE POLICY "Therapists can update their sessions"
  ON session FOR UPDATE
  USING (auth.uid() = therapist_id)
  WITH CHECK (auth.uid() = therapist_id);

-- THERAPY_GOAL POLICIES
-- Patients can view their own therapy goals
CREATE POLICY "Patients can view their own therapy goals"
  ON therapy_goal FOR SELECT
  USING (auth.uid() = patient_id);

-- Therapists can view therapy goals for their patients
CREATE POLICY "Therapists can view therapy goals for their patients"
  ON therapy_goal FOR SELECT
  USING (auth.uid() = therapist_id);

-- Therapists can create therapy goals
CREATE POLICY "Therapists can create therapy goals"
  ON therapy_goal FOR INSERT
  WITH CHECK (auth.uid() = therapist_id);

-- ASSESSMENT_RESULTS POLICIES
-- Patients can view their own assessment results
CREATE POLICY "Patients can view their own assessment results"
  ON assessment_results FOR SELECT
  USING (auth.uid() = patient_id);

-- Patients can insert their own assessment results
CREATE POLICY "Patients can insert their own assessment results"
  ON assessment_results FOR INSERT
  WITH CHECK (auth.uid() = patient_id);

-- DAILY_ACTIVITIES POLICIES
-- Patients can view their own daily activities
CREATE POLICY "Patients can view their own daily activities"
  ON daily_activities FOR SELECT
  USING (auth.uid() = patient_id);

-- Therapists can view daily activities for their patients
CREATE POLICY "Therapists can view daily activities for their patients"
  ON daily_activities FOR SELECT
  USING (auth.uid() = therapist_id);

-- Therapists can create daily activities for their patients
CREATE POLICY "Therapists can create daily activities"
  ON daily_activities FOR INSERT
  WITH CHECK (auth.uid() = therapist_id);

-- Therapists can update daily activities for their patients
CREATE POLICY "Therapists can update daily activities"
  ON daily_activities FOR UPDATE
  USING (auth.uid() = therapist_id)
  WITH CHECK (auth.uid() = therapist_id);

-- Therapists can delete daily activities for their patients
CREATE POLICY "Therapists can delete daily activities"
  ON daily_activities FOR DELETE
  USING (auth.uid() = therapist_id);

-- DAILY_ACTIVITY_LOGS POLICIES
-- Patients can view their own activity logs
CREATE POLICY "Patients can view their own activity logs"
  ON daily_activity_logs FOR SELECT
  USING (auth.uid() = patient_id);

-- Patients can insert their own activity logs
CREATE POLICY "Patients can insert their own activity logs"
  ON daily_activity_logs FOR INSERT
  WITH CHECK (auth.uid() = patient_id);

-- Patients can update their own activity logs
CREATE POLICY "Patients can update their own activity logs"
  ON daily_activity_logs FOR UPDATE
  USING (auth.uid() = patient_id)
  WITH CHECK (auth.uid() = patient_id);

-- PUBLIC READ ACCESS FOR REFERENCE TABLES
-- These tables don't contain sensitive user data, so allow public read access
ALTER TABLE assessments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view assessments"
  ON assessments FOR SELECT
  USING (true);

ALTER TABLE therapy ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view therapies"
  ON therapy FOR SELECT
  USING (true);

ALTER TABLE goal_master ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view goal master"
  ON goal_master FOR SELECT
  USING (true);

ALTER TABLE observation_master ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view observation master"
  ON observation_master FOR SELECT
  USING (true);

ALTER TABLE regression_master ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view regression master"
  ON regression_master FOR SELECT
  USING (true);

ALTER TABLE activity_master ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view activity master"
  ON activity_master FOR SELECT
  USING (true);

ALTER TABLE package ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view packages"
  ON package FOR SELECT
  USING (true);
