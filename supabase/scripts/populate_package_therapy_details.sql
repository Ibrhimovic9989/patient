-- Populate package_therapy_details for existing packages
-- Creates therapy types if they don't exist, then populates details

DO $$
DECLARE
    therapy_ot_uuid UUID;
    therapy_speech_uuid UUID;
    therapy_aba_uuid UUID;
BEGIN
    -- Get or create Occupational Therapy
    SELECT id INTO therapy_ot_uuid FROM therapy WHERE name ILIKE '%occupational%' LIMIT 1;
    IF therapy_ot_uuid IS NULL THEN
        INSERT INTO therapy (name, description)
        VALUES ('Occupational Therapy', 'Occupational therapy helps individuals develop skills for daily living')
        RETURNING id INTO therapy_ot_uuid;
    END IF;

    -- Get or create Speech Therapy
    SELECT id INTO therapy_speech_uuid FROM therapy WHERE name ILIKE '%speech%' LIMIT 1;
    IF therapy_speech_uuid IS NULL THEN
        INSERT INTO therapy (name, description)
        VALUES ('Speech Therapy', 'Speech therapy helps improve communication and language skills')
        RETURNING id INTO therapy_speech_uuid;
    END IF;

    -- Get or create ABA Therapy
    SELECT id INTO therapy_aba_uuid FROM therapy WHERE name ILIKE '%aba%' OR name ILIKE '%applied%' LIMIT 1;
    IF therapy_aba_uuid IS NULL THEN
        INSERT INTO therapy (name, description)
        VALUES ('Applied Behavior Analysis (ABA)', 'ABA therapy uses behavioral principles to improve social, communication, and learning skills')
        RETURNING id INTO therapy_aba_uuid;
    END IF;

    -- Package 1: Basic Therapy Package (9041d163-0934-4d67-89a7-ae9d4ce0159f)
    INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
    VALUES ('9041d163-0934-4d67-89a7-ae9d4ce0159f', therapy_ot_uuid, 8, 2, 45)
    ON CONFLICT (package_id, therapy_type_id) DO NOTHING;

    INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
    VALUES ('9041d163-0934-4d67-89a7-ae9d4ce0159f', therapy_speech_uuid, 8, 2, 45)
    ON CONFLICT (package_id, therapy_type_id) DO NOTHING;

    -- Package 2: Premium Therapy Package (bbe9ee8f-fc6d-4d9a-82c2-f9ef0ccc3e8f)
    INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
    VALUES ('bbe9ee8f-fc6d-4d9a-82c2-f9ef0ccc3e8f', therapy_ot_uuid, 16, 2, 60)
    ON CONFLICT (package_id, therapy_type_id) DO NOTHING;

    INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
    VALUES ('bbe9ee8f-fc6d-4d9a-82c2-f9ef0ccc3e8f', therapy_speech_uuid, 16, 2, 60)
    ON CONFLICT (package_id, therapy_type_id) DO NOTHING;

    INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
    VALUES ('bbe9ee8f-fc6d-4d9a-82c2-f9ef0ccc3e8f', therapy_aba_uuid, 12, 3, 60)
    ON CONFLICT (package_id, therapy_type_id) DO NOTHING;

    -- Package 3: Intensive Therapy Package (c5b8d73a-5b76-4548-a03c-c35f595f6887)
    INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
    VALUES ('c5b8d73a-5b76-4548-a03c-c35f595f6887', therapy_ot_uuid, 48, 3, 60)
    ON CONFLICT (package_id, therapy_type_id) DO NOTHING;

    INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
    VALUES ('c5b8d73a-5b76-4548-a03c-c35f595f6887', therapy_speech_uuid, 48, 3, 60)
    ON CONFLICT (package_id, therapy_type_id) DO NOTHING;

    INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
    VALUES ('c5b8d73a-5b76-4548-a03c-c35f595f6887', therapy_aba_uuid, 52, 4, 90)
    ON CONFLICT (package_id, therapy_type_id) DO NOTHING;

    RAISE NOTICE 'Package therapy details populated successfully';
END $$;
