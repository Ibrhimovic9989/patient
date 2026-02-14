-- Check RLS status on ALL tables that patient app queries

SELECT 
    tablename, 
    CASE 
        WHEN rowsecurity THEN '⚠️ RLS ENABLED'
        ELSE '✅ RLS DISABLED'
    END as rls_status
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN (
    'patient',           -- Checked in checkIfPatientExists()
    'assessment_results', -- Checked in checkIfPatientAssessmentExists()
    'session'            -- Checked in checkIfPatientConsultationExists()
)
ORDER BY tablename;

-- Check policies on these tables
SELECT 
    tablename,
    policyname,
    cmd as operation
FROM pg_policies
WHERE tablename IN ('patient', 'assessment_results', 'session')
ORDER BY tablename, cmd;
