-- Test Clinic Setup Script
-- Run this after all migrations to create a test clinic and subscription

-- 1. Create a test clinic
-- Using Gmail address for Google Auth compatibility
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
ON CONFLICT (email) DO NOTHING
RETURNING id, name, email;

-- 2. Grant a test subscription to the clinic
-- Replace 'YOUR_USER_ID' with the actual SaaS owner user ID from auth.users
-- Or use a service role to grant it
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
)
RETURNING id, clinic_id, subscription_tier, status, expires_at;

-- 3. Verify setup
SELECT 
  c.id as clinic_id,
  c.name as clinic_name,
  c.email as clinic_email,
  cs.subscription_tier,
  cs.status as subscription_status,
  cs.expires_at,
  CASE 
    WHEN cs.expires_at > NOW() THEN 'Active'
    ELSE 'Expired'
  END as subscription_status_check
FROM clinic c
LEFT JOIN clinic_subscription cs ON cs.clinic_id = c.id AND cs.status = 'active'
WHERE c.email = 'excellencecircle91@gmail.com';
