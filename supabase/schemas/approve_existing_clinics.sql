-- Approve All Existing Clinics
-- This script sets is_active = true for all existing clinic records
-- This ensures current clinic users are already approved and can log in

-- Update all existing clinics to be active
UPDATE clinic
SET is_active = true
WHERE is_active IS NULL OR is_active = false;

-- Verify the update
-- You can run this query to see all active clinics:
-- SELECT id, name, email, owner_email, is_active, created_at 
-- FROM clinic 
-- ORDER BY created_at DESC;

-- Optional: Show summary
DO $$
DECLARE
    total_clinics INTEGER;
    active_clinics INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_clinics FROM clinic;
    SELECT COUNT(*) INTO active_clinics FROM clinic WHERE is_active = true;
    
    RAISE NOTICE 'Total clinics: %', total_clinics;
    RAISE NOTICE 'Active clinics: %', active_clinics;
END $$;
