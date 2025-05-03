-- Create Users SQL Script
-- This script creates teacher and student users in the auth.users table with proper password hashing

-- Begin transaction
BEGIN;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Function to generate random confirmation token
CREATE OR REPLACE FUNCTION generate_confirmation_token() 
RETURNS text AS $$
BEGIN
  RETURN encode(gen_random_bytes(32), 'hex');
END;
$$ LANGUAGE plpgsql;

-- Clear existing data (if needed)
-- DELETE FROM auth.users WHERE email LIKE '%@university.edu';

-- Initialize arrays to store user IDs
DO $$ 
DECLARE
    teacher_ids uuid[] := ARRAY[]::uuid[];
    student_ids uuid[] := ARRAY[]::uuid[];
    temp_id uuid;
    instance_id uuid;
    confirm_token text;
    i integer;
    base_teacher_number integer := 1000;
    base_student_number integer := 2000;
    teacher_password text := 'Teacher@2024';
    student_password text := 'Student@2024';
BEGIN
    -- Generate instance ID using proper UUID
    instance_id := uuid_generate_v4();

    -- Create 4 teachers
    FOR i IN 1..4 LOOP
        -- Generate confirmation token
        confirm_token := generate_confirmation_token();
        
        -- Generate user ID using UUID v4
        temp_id := uuid_generate_v4();
        
        INSERT INTO auth.users (
            id,
            email,
            encrypted_password,
            email_confirmed_at,
            confirmation_token,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at,
            role,
            instance_id,
            aud,
            confirmation_sent_at
        )
        VALUES (
            temp_id,
            'teacher' || (base_teacher_number + i) || '@university.edu',
            crypt(teacher_password, gen_salt('bf')),
            now(),
            confirm_token,
            jsonb_build_object(
                'provider', 'email',
                'role', 'teacher'
            ),
            jsonb_build_object(
                'full_name', 'Teacher ' || i,
                'teacher_id', (base_teacher_number + i)::text,
                'department', 'Computer Science'
            ),
            now(),
            now(),
            'authenticated',
            instance_id,
            'authenticated',
            now()
        );
        
        teacher_ids := array_append(teacher_ids, temp_id);
    END LOOP;

    -- Create 60 students
    FOR i IN 1..60 LOOP
        -- Generate confirmation token
        confirm_token := generate_confirmation_token();
        
        -- Generate user ID using UUID v4
        temp_id := uuid_generate_v4();
        
        INSERT INTO auth.users (
            id,
            email,
            encrypted_password,
            email_confirmed_at,
            confirmation_token,
            raw_app_meta_data,
            raw_user_meta_data,
            created_at,
            updated_at,
            role,
            instance_id,
            aud,
            confirmation_sent_at
        )
        VALUES (
            temp_id,
            'student' || (base_student_number + i) || '@university.edu',
            crypt(student_password, gen_salt('bf')),
            now(),
            confirm_token,
            jsonb_build_object(
                'provider', 'email',
                'role', 'student'
            ),
            jsonb_build_object(
                'full_name', 'Student ' || i,
                'student_id', (base_student_number + i)::text,
                'group', 'Group ' || (((i-1)/20) + 1)::text,
                'year', '2024'
            ),
            now(),
            now(),
            'authenticated',
            instance_id,
            'authenticated',
            now()
        );
        
        student_ids := array_append(student_ids, temp_id);
    END LOOP;

    -- Store IDs in a temporary table for reference
    CREATE TEMPORARY TABLE user_ids (
        user_type text,
        user_id uuid
    );

    -- Insert teacher IDs
    FOR i IN 1..array_length(teacher_ids, 1) LOOP
        INSERT INTO user_ids (user_type, user_id)
        VALUES ('teacher', teacher_ids[i]);
    END LOOP;

    -- Insert student IDs
    FOR i IN 1..array_length(student_ids, 1) LOOP
        INSERT INTO user_ids (user_type, user_id)
        VALUES ('student', student_ids[i]);
    END LOOP;

    -- Safety check: Verify no null IDs
    IF EXISTS (
        SELECT 1 FROM auth.users 
        WHERE id IS NULL 
        AND email LIKE '%@university.edu'
    ) THEN
        RAISE EXCEPTION 'Null IDs detected in users table';
    END IF;

END $$;

-- Verification queries
SELECT COUNT(*) as total_teachers 
FROM auth.users 
WHERE raw_app_meta_data->>'role' = 'teacher'
AND email LIKE '%@university.edu';

SELECT COUNT(*) as total_students
FROM auth.users 
WHERE raw_app_meta_data->>'role' = 'student'
AND email LIKE '%@university.edu';

-- Sample queries to verify user metadata
SELECT id, email, instance_id, confirmation_token, raw_user_meta_data 
FROM auth.users 
WHERE raw_app_meta_data->>'role' = 'teacher'
AND email LIKE '%@university.edu'
LIMIT 2;

SELECT id, email, instance_id, confirmation_token, raw_user_meta_data 
FROM auth.users 
WHERE raw_app_meta_data->>'role' = 'student'
AND email LIKE '%@university.edu'
LIMIT 2;

-- Commit transaction
COMMIT;