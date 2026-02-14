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
