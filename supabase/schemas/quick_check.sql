-- Quick check: RLS status and policies in one query

-- Check RLS status
SELECT 
    'RLS Status Check' as check_type,
    tablename, 
    CASE 
        WHEN rowsecurity THEN '⚠️ ENABLED - Need policies!'
        ELSE '✅ DISABLED - No RLS blocking'
    END as status
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('therapist', 'patient')
ORDER BY tablename;

-- Check existing policies
SELECT 
    'Policy Check' as check_type,
    tablename,
    COUNT(*) as policy_count,
    STRING_AGG(cmd::text, ', ') as operations_covered
FROM pg_policies
WHERE tablename IN ('therapist', 'patient')
GROUP BY tablename
ORDER BY tablename;

-- If no policies exist, this will return empty - that's the problem!
