-- Seed Dummy Packages for Clinic App
-- Run this in Supabase SQL Editor after creating a clinic

-- First, get the clinic ID (replace with your clinic email)
-- This assumes you have a clinic with email 'excellencecircle91@gmail.com'

DO $$
DECLARE
    clinic_uuid UUID;
    package1_uuid UUID;
    package2_uuid UUID;
    package3_uuid UUID;
    therapy_ot_uuid UUID;
    therapy_speech_uuid UUID;
    therapy_aba_uuid UUID;
BEGIN
    -- Get clinic ID
    SELECT id INTO clinic_uuid
    FROM clinic
    WHERE email = 'excellencecircle91@gmail.com'
    LIMIT 1;

    IF clinic_uuid IS NULL THEN
        RAISE EXCEPTION 'Clinic not found. Please create a clinic first.';
    END IF;

    -- Get therapy type IDs (assuming these exist)
    SELECT id INTO therapy_ot_uuid FROM therapy WHERE name ILIKE '%occupational%' LIMIT 1;
    SELECT id INTO therapy_speech_uuid FROM therapy WHERE name ILIKE '%speech%' LIMIT 1;
    SELECT id INTO therapy_aba_uuid FROM therapy WHERE name ILIKE '%aba%' OR name ILIKE '%applied%' LIMIT 1;

    -- Create Package 1: Basic Package
    INSERT INTO package (clinic_id, name, duration, price, validity_days, description, is_active)
    VALUES (
        clinic_uuid,
        'Basic Therapy Package',
        90, -- duration in days (matches validity_days)
        299.99,
        90,
        'A comprehensive basic package for essential therapy needs. Includes occupational and speech therapy sessions.',
        true
    )
    RETURNING id INTO package1_uuid;

    -- Add therapy details for Package 1
    IF therapy_ot_uuid IS NOT NULL THEN
        INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
        VALUES (package1_uuid, therapy_ot_uuid, 8, 2, 45);
    END IF;

    IF therapy_speech_uuid IS NOT NULL THEN
        INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
        VALUES (package1_uuid, therapy_speech_uuid, 8, 2, 45);
    END IF;

    -- Create Package 2: Premium Package
    INSERT INTO package (clinic_id, name, duration, price, validity_days, description, is_active)
    VALUES (
        clinic_uuid,
        'Premium Therapy Package',
        180, -- duration in days (matches validity_days)
        599.99,
        180,
        'An advanced package with extended sessions and multiple therapy types. Perfect for comprehensive treatment plans.',
        true
    )
    RETURNING id INTO package2_uuid;

    -- Add therapy details for Package 2
    IF therapy_ot_uuid IS NOT NULL THEN
        INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
        VALUES (package2_uuid, therapy_ot_uuid, 16, 2, 60);
    END IF;

    IF therapy_speech_uuid IS NOT NULL THEN
        INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
        VALUES (package2_uuid, therapy_speech_uuid, 16, 2, 60);
    END IF;

    IF therapy_aba_uuid IS NOT NULL THEN
        INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
        VALUES (package2_uuid, therapy_aba_uuid, 12, 3, 60);
    END IF;

    -- Create Package 3: Intensive Package
    INSERT INTO package (clinic_id, name, duration, price, validity_days, description, is_active)
    VALUES (
        clinic_uuid,
        'Intensive Therapy Package',
        365, -- duration in days (matches validity_days)
        999.99,
        365,
        'Our most comprehensive package with intensive therapy sessions. Includes all therapy types with maximum frequency.',
        true
    )
    RETURNING id INTO package3_uuid;

    -- Add therapy details for Package 3
    IF therapy_ot_uuid IS NOT NULL THEN
        INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
        VALUES (package3_uuid, therapy_ot_uuid, 48, 3, 60);
    END IF;

    IF therapy_speech_uuid IS NOT NULL THEN
        INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
        VALUES (package3_uuid, therapy_speech_uuid, 48, 3, 60);
    END IF;

    IF therapy_aba_uuid IS NOT NULL THEN
        INSERT INTO package_therapy_details (package_id, therapy_type_id, session_count, frequency_per_week, session_duration_minutes)
        VALUES (package3_uuid, therapy_aba_uuid, 52, 4, 90);
    END IF;

    RAISE NOTICE 'Dummy packages created successfully for clinic %', clinic_uuid;
END $$;
