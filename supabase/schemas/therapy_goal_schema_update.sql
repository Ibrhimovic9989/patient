-- Add session_notes and goal_achievement_status columns to therapy_goal table
-- This migration adds fields for Phase 1 progress tracking features

-- Add session_notes field for therapist to add notes about the therapy session
ALTER TABLE therapy_goal ADD COLUMN IF NOT EXISTS session_notes TEXT;

-- Add goal_achievement_status field to track which goals are achieved/in-progress
-- Format: {"goal_id_1": "achieved", "goal_id_2": "in_progress", "goal_id_3": "not_started"}
ALTER TABLE therapy_goal ADD COLUMN IF NOT EXISTS goal_achievement_status JSONB;

-- Add comments for documentation
COMMENT ON COLUMN therapy_goal.session_notes IS 'Therapist notes about the therapy session';
COMMENT ON COLUMN therapy_goal.goal_achievement_status IS 'JSONB object mapping goal IDs to their achievement status (achieved, in_progress, not_started)';
