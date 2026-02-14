-- Delete Users and All Associated Records
-- WARNING: This will permanently delete all data for these users
-- Run this in Supabase SQL Editor

-- User 1: Ibrahim Raza
-- UID: 5c3c4572-37af-4556-9a89-fc2751700be1
-- Email: ibrahimshaheer91@gmail.com

-- User 2: Leeza app
-- UID: 97bfac42-2ecb-4964-bbb8-5f9adabe9382
-- Email: leeza.app15@gmail.com

BEGIN;

-- Store user IDs for easier reference
DO $$
DECLARE
    user1_id UUID := '5c3c4572-37af-4556-9a89-fc2751700be1';
    user2_id UUID := '97bfac42-2ecb-4964-bbb8-5f9adabe9382';
BEGIN
    -- ============================================
    -- DELETE USER 1 RECORDS (Ibrahim Raza)
    -- ============================================
    
    RAISE NOTICE 'Deleting records for User 1: %', user1_id;
    
    -- Delete patient_package records
    DELETE FROM patient_package WHERE patient_id = user1_id;
    RAISE NOTICE 'Deleted patient_package records for User 1';
    
    -- Delete daily_activities
    DELETE FROM daily_activities WHERE patient_id = user1_id;
    RAISE NOTICE 'Deleted daily_activities for User 1';
    
    -- Delete therapy_goals (if user was a therapist)
    DELETE FROM therapy_goal WHERE therapist_id = user1_id;
    RAISE NOTICE 'Deleted therapy_goals for User 1';
    
    -- Delete sessions (as patient or therapist)
    DELETE FROM session WHERE patient_id = user1_id OR therapist_id = user1_id;
    RAISE NOTICE 'Deleted sessions for User 1';
    
    -- Delete assessment_results
    DELETE FROM assessment_results WHERE patient_id = user1_id;
    RAISE NOTICE 'Deleted assessment_results for User 1';
    
    -- Delete therapist record (if exists)
    DELETE FROM therapist WHERE id = user1_id;
    RAISE NOTICE 'Deleted therapist record for User 1';
    
    -- Delete patient record (if exists)
    DELETE FROM patient WHERE id = user1_id;
    RAISE NOTICE 'Deleted patient record for User 1';
    
    -- ============================================
    -- DELETE USER 2 RECORDS (Leeza app)
    -- ============================================
    
    RAISE NOTICE 'Deleting records for User 2: %', user2_id;
    
    -- Delete patient_package records
    DELETE FROM patient_package WHERE patient_id = user2_id;
    RAISE NOTICE 'Deleted patient_package records for User 2';
    
    -- Delete daily_activities
    DELETE FROM daily_activities WHERE patient_id = user2_id;
    RAISE NOTICE 'Deleted daily_activities for User 2';
    
    -- Delete therapy_goals (if user was a therapist)
    DELETE FROM therapy_goal WHERE therapist_id = user2_id;
    RAISE NOTICE 'Deleted therapy_goals for User 2';
    
    -- Delete sessions (as patient or therapist)
    DELETE FROM session WHERE patient_id = user2_id OR therapist_id = user2_id;
    RAISE NOTICE 'Deleted sessions for User 2';
    
    -- Delete assessment_results
    DELETE FROM assessment_results WHERE patient_id = user2_id;
    RAISE NOTICE 'Deleted assessment_results for User 2';
    
    -- Delete therapist record (if exists)
    DELETE FROM therapist WHERE id = user2_id;
    RAISE NOTICE 'Deleted therapist record for User 2';
    
    -- Delete patient record (if exists)
    DELETE FROM patient WHERE id = user2_id;
    RAISE NOTICE 'Deleted patient record for User 2';
    
    RAISE NOTICE 'All data records deleted successfully';
END $$;

-- ============================================
-- DELETE FROM AUTH.USERS
-- ============================================
-- Note: Deleting from auth.users requires admin privileges
-- This might need to be done via Supabase Dashboard or Admin API
-- Uncomment the following if you have admin access:

-- DELETE FROM auth.users WHERE id IN (
--     '5c3c4572-37af-4556-9a89-fc2751700be1',
--     '97bfac42-2ecb-4964-bbb8-5f9adabe9382'
-- );

COMMIT;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these after deletion to verify:

-- Check if any records remain for User 1
SELECT 'patient' as table_name, COUNT(*) as count FROM patient WHERE id = '5c3c4572-37af-4556-9a89-fc2751700be1'
UNION ALL
SELECT 'therapist', COUNT(*) FROM therapist WHERE id = '5c3c4572-37af-4556-9a89-fc2751700be1'
UNION ALL
SELECT 'assessment_results', COUNT(*) FROM assessment_results WHERE patient_id = '5c3c4572-37af-4556-9a89-fc2751700be1'
UNION ALL
SELECT 'session', COUNT(*) FROM session WHERE patient_id = '5c3c4572-37af-4556-9a89-fc2751700be1' OR therapist_id = '5c3c4572-37af-4556-9a89-fc2751700be1'
UNION ALL
SELECT 'patient_package', COUNT(*) FROM patient_package WHERE patient_id = '5c3c4572-37af-4556-9a89-fc2751700be1';

-- Check if any records remain for User 2
SELECT 'patient' as table_name, COUNT(*) as count FROM patient WHERE id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382'
UNION ALL
SELECT 'therapist', COUNT(*) FROM therapist WHERE id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382'
UNION ALL
SELECT 'assessment_results', COUNT(*) FROM assessment_results WHERE patient_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382'
UNION ALL
SELECT 'session', COUNT(*) FROM session WHERE patient_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382' OR therapist_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382'
UNION ALL
SELECT 'patient_package', COUNT(*) FROM patient_package WHERE patient_id = '97bfac42-2ecb-4964-bbb8-5f9adabe9382';
