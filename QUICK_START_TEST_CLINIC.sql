-- Quick Start: Create Test Clinic with Gmail for Google Auth
-- Run this in Supabase SQL Editor

-- 1. Create clinic with Gmail address (compatible with Google Auth)
INSERT INTO clinic (name, email, phone, address, country, owner_name, owner_email, is_active)
VALUES (
  'Excellence Circle Therapy Clinic',
  'excellencecircle91@gmail.com',
  '+1234567890',
  '123 Test Street, Test City',
  'United States',
  'Excellence Circle Admin',
  'excellencecircle91@gmail.com',
  true
)
ON CONFLICT (email) DO UPDATE
SET 
  name = EXCLUDED.name,
  owner_name = EXCLUDED.owner_name,
  is_active = true
RETURNING id, name, email, owner_email;

-- 2. Grant premium subscription (12 months)
INSERT INTO clinic_subscription (
  clinic_id,
  subscription_tier,
  status,
  starts_at,
  expires_at,
  payment_amount,
  payment_date
)
SELECT 
  c.id,
  'premium',
  'active',
  NOW(),
  NOW() + INTERVAL '12 months',
  999.99,
  NOW()
FROM clinic c
WHERE c.email = 'excellencecircle91@gmail.com'
AND NOT EXISTS (
  SELECT 1 FROM clinic_subscription cs 
  WHERE cs.clinic_id = c.id 
  AND cs.status = 'active'
  AND cs.expires_at > NOW()
)
RETURNING id, clinic_id, subscription_tier, status, starts_at, expires_at;

-- 3. Verify setup
SELECT 
  c.id as clinic_id,
  c.name as clinic_name,
  c.email as clinic_email,
  c.owner_email,
  cs.subscription_tier,
  cs.status as subscription_status,
  cs.expires_at,
  CASE 
    WHEN cs.expires_at > NOW() THEN '✅ Active'
    ELSE '❌ Expired'
  END as subscription_status_check
FROM clinic c
LEFT JOIN clinic_subscription cs ON cs.clinic_id = c.id AND cs.status = 'active'
WHERE c.email = 'excellencecircle91@gmail.com';
