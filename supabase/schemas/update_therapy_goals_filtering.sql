-- Update Therapy Goals Filtering
-- Add indexes and ensure therapy goals are properly linked

-- Add index on therapy_type_id for faster filtering
CREATE INDEX IF NOT EXISTS idx_therapy_goal_therapy_type_id ON therapy_goal(therapy_type_id);

-- Ensure therapy goals can be filtered by package therapy types
-- (package_id and patient_package_id already exist from previous migration)
