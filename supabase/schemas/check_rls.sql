-- Quick diagnostic queries to check RLS status and policies

-- 1. Check if RLS is enabled on tables
SELECT 
    tablename, 
    rowsecurity as "RLS Enabled",
    CASE 
        WHEN rowsecurity THEN '⚠️ RLS is ENABLED - Need policies!'
        ELSE '✅ RLS is DISABLED'
    END as status
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('therapist', 'patient', 'session', 'therapy_goal', 'assessment_results')
ORDER BY tablename;

-- 2. Check existing policies
SELECT 
    tablename,
    policyname,
    cmd as "Operation",
    CASE 
        WHEN cmd = 'SELECT' THEN 'Read'
        WHEN cmd = 'INSERT' THEN 'Create'
        WHEN cmd = 'UPDATE' THEN 'Update'
        WHEN cmd = 'DELETE' THEN 'Delete'
        ELSE cmd::text
    END as "Operation Type",
    CASE
        WHEN qual IS NULL AND with_check IS NULL THEN '⚠️ No conditions'
        ELSE '✅ Has conditions'
    END as "Policy Status"
FROM pg_policies
WHERE tablename IN ('therapist', 'patient')
ORDER BY tablename, cmd;

-- 3. Count policies per table
SELECT 
    tablename,
    COUNT(*) as "Policy Count",
    STRING_AGG(cmd::text, ', ') as "Operations Covered"
FROM pg_policies
WHERE tablename IN ('therapist', 'patient')
GROUP BY tablename
ORDER BY tablename;

-- 4. Check if tables exist and their structure
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name IN ('therapist', 'patient')
ORDER BY table_name, ordinal_position;
