-- Profile Creation and Auth User Linking Script
-- IMPORTANT: Run this script AFTER create_structure.sql and create_users.sql

BEGIN;

-- Create temporary structure to store teacher information
CREATE TEMPORARY TABLE temp_teacher_info (
    email TEXT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    department_code TEXT,
    employee_id TEXT
);

-- Insert teacher information matching create_users.sql pattern
INSERT INTO temp_teacher_info (email, first_name, last_name, phone, department_code, employee_id) VALUES
('teacher1001@university.edu', 'Teacher', '1', '+1234567890', 'CS', 'T1001'),
('teacher1002@university.edu', 'Teacher', '2', '+1234567891', 'CS', 'T1002'),
('teacher1003@university.edu', 'Teacher', '3', '+1234567892', 'MATH', 'T1003'),
('teacher1004@university.edu', 'Teacher', '4', '+1234567893', 'MATH', 'T1004');

-- Create teacher profiles and link them to auth users
DO $$
DECLARE
    teacher_rec RECORD;
    auth_user_id UUID;
    dept_id UUID;
BEGIN
    -- Email pattern verification
    IF EXISTS (
        SELECT 1 FROM auth.users 
        WHERE raw_app_meta_data->>'role' = 'teacher'
        AND email NOT LIKE 'teacher%@university.edu'
    ) THEN
        RAISE EXCEPTION 'Invalid teacher email pattern detected';
    END IF;

    FOR teacher_rec IN SELECT * FROM temp_teacher_info LOOP
        -- Get auth user ID
        SELECT id INTO auth_user_id 
        FROM auth.users 
        WHERE email = teacher_rec.email;

        IF auth_user_id IS NULL THEN
            RAISE EXCEPTION 'Auth user not found for email: %', teacher_rec.email;
        END IF;

        -- Get department ID
        SELECT id INTO dept_id 
        FROM departments 
        WHERE code = teacher_rec.department_code;

        IF dept_id IS NULL THEN
            RAISE EXCEPTION 'Department not found for code: %', teacher_rec.department_code;
        END IF;

        -- Create profile
        INSERT INTO profiles (
            id, 
            first_name, 
            last_name, 
            role, 
            phone
        ) VALUES (
            auth_user_id,
            teacher_rec.first_name,
            teacher_rec.last_name,
            'teacher',
            teacher_rec.phone
        );

        -- Create teacher profile
        INSERT INTO teacher_profiles (
            id,
            department_id,
            employee_id
        ) VALUES (
            auth_user_id,
            dept_id,
            teacher_rec.employee_id
        );

        RAISE NOTICE 'Created profile for teacher: % % (%)', 
            teacher_rec.first_name, 
            teacher_rec.last_name,
            teacher_rec.email;
    END LOOP;
END $$;

-- Link Teachers to Courses and Groups
DO $$
DECLARE
    teacher_rec RECORD;
    auth_user_id UUID;
    course_id UUID;
    group_id UUID;
BEGIN
    FOR teacher_rec IN SELECT * FROM temp_teacher_info LOOP
        -- Get auth user ID
        SELECT id INTO auth_user_id 
        FROM auth.users 
        WHERE email = teacher_rec.email;

        -- Get first course ID for department
        SELECT c.id INTO course_id
        FROM courses c
        JOIN departments d ON c.department_id = d.id
        WHERE d.code = teacher_rec.department_code
        LIMIT 1;

        -- Get first group ID for department
        SELECT sg.id INTO group_id
        FROM student_groups sg
        JOIN departments d ON sg.department_id = d.id
        WHERE d.code = teacher_rec.department_code
        LIMIT 1;

        -- Create teacher-course-group association
        INSERT INTO teacher_course_groups (
            teacher_id,
            course_id,
            group_id,
            academic_period
        ) VALUES (
            auth_user_id,
            course_id,
            group_id,
            '2024-S1'
        );

        RAISE NOTICE 'Linked teacher % to course and group', teacher_rec.email;
    END LOOP;
END $$;

-- Clean up
DROP TABLE temp_teacher_info;

-- Verification Queries
SELECT 'Email Pattern Check' as check_type,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL'
    END as result,
    COUNT(*) as invalid_count
FROM auth.users 
WHERE raw_app_meta_data->>'role' = 'teacher'
AND email NOT LIKE 'teacher%@university.edu';

SELECT 'Profile Count Check' as check_type,
    CASE 
        WHEN COUNT(*) = 4 THEN 'PASS'
        ELSE 'FAIL'
    END as result,
    COUNT(*) as count
FROM profiles 
WHERE role = 'teacher';

SELECT 'Teacher Profile Count Check' as check_type,
    CASE 
        WHEN COUNT(*) = 4 THEN 'PASS'
        ELSE 'FAIL'
    END as result,
    COUNT(*) as count
FROM teacher_profiles;

SELECT 'Course Assignment Check' as check_type,
    CASE 
        WHEN COUNT(*) = 4 THEN 'PASS'
        ELSE 'FAIL'
    END as result,
    COUNT(*) as count
FROM teacher_course_groups;

-- Detailed Profile Verification
SELECT 
    p.id,
    p.first_name,
    p.last_name,
    p.role,
    tp.employee_id,
    d.name as department,
    u.email,
    u.raw_user_meta_data->>'department' as auth_department
FROM profiles p
JOIN teacher_profiles tp ON p.id = tp.id
JOIN departments d ON tp.department_id = d.id
JOIN auth.users u ON p.id = u.id
WHERE p.role = 'teacher'
ORDER BY p.last_name, p.first_name;

-- Course Assignment Verification
SELECT 
    p.first_name || ' ' || p.last_name as teacher_name,
    c.code as course_code,
    sg.name as student_group,
    tcg.academic_period,
    u.email
FROM teacher_course_groups tcg
JOIN profiles p ON tcg.teacher_id = p.id
JOIN courses c ON tcg.course_id = c.id
JOIN student_groups sg ON tcg.group_id = sg.id
JOIN auth.users u ON p.id = u.id
ORDER BY teacher_name, course_code;

-- Email Pattern Consistency Check
SELECT 'Email Format Consistency' as check_type,
    CASE 
        WHEN COUNT(*) = 0 THEN 'PASS'
        ELSE 'FAIL: ' || COUNT(*) || ' mismatches found'
    END as result
FROM auth.users u
LEFT JOIN profiles p ON u.id = p.id
WHERE u.raw_app_meta_data->>'role' = 'teacher'
AND NOT (
    u.email ~ '^teacher[0-9]{4}@university\.edu$'
);

COMMIT;

/*
Next Steps:
1. Review all verification query results
2. Check email pattern consistency
3. Verify profile-auth linkage
4. Test authentication flow with updated users
5. Verify teacher access to assigned courses and groups
*/