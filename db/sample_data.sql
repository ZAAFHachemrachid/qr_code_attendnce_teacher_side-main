-- Sample Data Script - Two Phase Approach
-- Phase 1: Database Structure Creation

BEGIN;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

------------------------------------------
-- Phase 1: Database Structure Creation
------------------------------------------
DO $$
DECLARE
    -- Department Variables
    cs_dept_id UUID := uuid_generate_v4();
    math_dept_id UUID := uuid_generate_v4();
    phys_dept_id UUID := uuid_generate_v4();
    ele_dept_id UUID := uuid_generate_v4();

    -- Student Group Variables
    cs_2a_group_id UUID := uuid_generate_v4();
    cs_2b_group_id UUID := uuid_generate_v4();
    math_2a_group_id UUID := uuid_generate_v4();
    math_2b_group_id UUID := uuid_generate_v4();

    -- Course Variables
    cs_201_id UUID := uuid_generate_v4();
    cs_202_id UUID := uuid_generate_v4();
    cs_203_id UUID := uuid_generate_v4();
    math_201_id UUID := uuid_generate_v4();
    math_202_id UUID := uuid_generate_v4();
    math_203_id UUID := uuid_generate_v4();

    -- Temporary Teacher IDs (will be updated in Phase 2)
    teacher1_temp_id UUID := uuid_generate_v4();
    teacher2_temp_id UUID := uuid_generate_v4();
    teacher3_temp_id UUID := uuid_generate_v4();
    teacher4_temp_id UUID := uuid_generate_v4();

BEGIN
    ------------------------------------------
    -- 1. Insert Departments 
    ------------------------------------------
    INSERT INTO departments (id, name, code) VALUES
    (cs_dept_id, 'Computer Science', 'CS'),
    (math_dept_id, 'Mathematics', 'MATH'),
    (phys_dept_id, 'Physics', 'PHY'),
    (ele_dept_id, 'Electronics', 'ELE');

    ------------------------------------------
    -- 2. Create Teacher Profile Structures
    ------------------------------------------
    -- Create base profiles with temporary IDs
    INSERT INTO profiles (id, first_name, last_name, role, phone) VALUES
    (teacher1_temp_id, 'John', 'Smith', 'teacher', '+1234567890'),
    (teacher2_temp_id, 'Sarah', 'Johnson', 'teacher', '+1234567891'),
    (teacher3_temp_id, 'Michael', 'Brown', 'teacher', '+1234567892'),
    (teacher4_temp_id, 'Emily', 'Davis', 'teacher', '+1234567893');

    -- Create teacher profiles with temporary IDs
    INSERT INTO teacher_profiles (id, department_id, employee_id) VALUES
    (teacher1_temp_id, cs_dept_id, 'EMP001'),
    (teacher2_temp_id, cs_dept_id, 'EMP002'),
    (teacher3_temp_id, math_dept_id, 'EMP003'),
    (teacher4_temp_id, math_dept_id, 'EMP004');

    ------------------------------------------
    -- 3. Insert Student Groups
    ------------------------------------------
    INSERT INTO student_groups (id, department_id, academic_year, current_year, section, name) VALUES
    -- Computer Science Groups
    (cs_2a_group_id, cs_dept_id, 2024, 2, 'A', 'CS-2A-2024'),
    (cs_2b_group_id, cs_dept_id, 2024, 2, 'B', 'CS-2B-2024'),
    -- Mathematics Groups
    (math_2a_group_id, math_dept_id, 2024, 2, 'A', 'MATH-2A-2024'),
    (math_2b_group_id, math_dept_id, 2024, 2, 'B', 'MATH-2B-2024');

    ------------------------------------------
    -- 4. Insert Courses
    ------------------------------------------
    INSERT INTO courses (id, code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
    -- Computer Science Courses
    (cs_201_id, 'CS201', 'Data Structures', 'Advanced data structures and algorithms', 3, cs_dept_id, 2, 'semester1'),
    (cs_202_id, 'CS202', 'Database Systems', 'Introduction to database management systems', 3, cs_dept_id, 2, 'semester1'),
    (cs_203_id, 'CS203', 'Operating Systems', 'Fundamentals of operating systems', 3, cs_dept_id, 2, 'semester1'),
    -- Mathematics Courses
    (math_201_id, 'MATH201', 'Linear Algebra', 'Vectors, matrices and linear transformations', 3, math_dept_id, 2, 'semester1'),
    (math_202_id, 'MATH202', 'Calculus III', 'Multivariate calculus and applications', 3, math_dept_id, 2, 'semester1'),
    (math_203_id, 'MATH203', 'Probability', 'Introduction to probability theory', 3, math_dept_id, 2, 'semester1');

    ------------------------------------------
    -- 5. Link Courses to Groups
    ------------------------------------------
    INSERT INTO group_courses (group_id, course_id, academic_period) VALUES
    -- CS-2A Group Courses
    (cs_2a_group_id, cs_201_id, '2024-S1'),
    (cs_2a_group_id, cs_202_id, '2024-S1'),
    (cs_2a_group_id, cs_203_id, '2024-S1'),
    -- CS-2B Group Courses
    (cs_2b_group_id, cs_201_id, '2024-S1'),
    (cs_2b_group_id, cs_202_id, '2024-S1'),
    (cs_2b_group_id, cs_203_id, '2024-S1'),
    -- MATH-2A Group Courses
    (math_2a_group_id, math_201_id, '2024-S1'),
    (math_2a_group_id, math_202_id, '2024-S1'),
    (math_2a_group_id, math_203_id, '2024-S1'),
    -- MATH-2B Group Courses
    (math_2b_group_id, math_201_id, '2024-S1'),
    (math_2b_group_id, math_202_id, '2024-S1'),
    (math_2b_group_id, math_203_id, '2024-S1');

    ------------------------------------------
    -- 6. Link Teachers to Courses and Groups (using temporary IDs)
    ------------------------------------------
    INSERT INTO teacher_course_groups (teacher_id, course_id, group_id, academic_period) VALUES
    -- CS Teachers
    (teacher1_temp_id, cs_201_id, cs_2a_group_id, '2024-S1'),
    (teacher1_temp_id, cs_201_id, cs_2b_group_id, '2024-S1'),
    (teacher2_temp_id, cs_202_id, cs_2a_group_id, '2024-S1'),
    (teacher2_temp_id, cs_202_id, cs_2b_group_id, '2024-S1'),
    -- Math Teachers
    (teacher3_temp_id, math_201_id, math_2a_group_id, '2024-S1'),
    (teacher3_temp_id, math_201_id, math_2b_group_id, '2024-S1'),
    (teacher4_temp_id, math_202_id, math_2a_group_id, '2024-S1'),
    (teacher4_temp_id, math_202_id, math_2b_group_id, '2024-S1');

    -- Save temporary IDs for Phase 2
    CREATE TEMPORARY TABLE temp_teacher_ids (
        temp_id UUID,
        email TEXT,
        department TEXT
    );

    INSERT INTO temp_teacher_ids (temp_id, email, department) VALUES
    (teacher1_temp_id, 'john.smith@example.com', 'CS'),
    (teacher2_temp_id, 'sarah.johnson@example.com', 'CS'),
    (teacher3_temp_id, 'michael.brown@example.com', 'MATH'),
    (teacher4_temp_id, 'emily.davis@example.com', 'MATH');

END $$;

COMMIT;

------------------------------------------
-- Phase 2: Auth User Creation and Linking
------------------------------------------
/*
IMPORTANT: Follow these steps to create users and link profiles:

1. Create Teachers in Supabase Dashboard:
   - Go to Authentication > Users
   - Click "Create User"
   - For each teacher, create a user with:
     * Email: [email from temp_teacher_ids]
     * Password: teacher123
     * User Metadata: 
       {
         "role": "teacher",
         "department": "[department from temp_teacher_ids]"
       }

2. Run the following SQL to update profile IDs:
*/

BEGIN;

-- Update teacher profile IDs
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN SELECT * FROM temp_teacher_ids LOOP
        -- Get the auth user ID
        WITH auth_user AS (
            SELECT id FROM auth.users WHERE email = r.email
        )
        -- Update the profile and teacher_profile tables
        UPDATE profiles 
        SET id = (SELECT id FROM auth_user)
        WHERE id = r.temp_id;

        UPDATE teacher_profiles 
        SET id = (SELECT id FROM auth_user)
        WHERE id = r.temp_id;

        UPDATE teacher_course_groups
        SET teacher_id = (SELECT id FROM auth_user)
        WHERE teacher_id = r.temp_id;
    END LOOP;
END $$;

-- Clean up
DROP TABLE temp_teacher_ids;

-- Verification Queries
SELECT 'Checking Departments' as check_type, count(*) as count FROM departments;
SELECT 'Checking Student Groups' as check_type, count(*) as count FROM student_groups;
SELECT 'Checking Courses' as check_type, count(*) as count FROM courses;
SELECT 'Checking Group Courses' as check_type, count(*) as count FROM group_courses;
SELECT 'Checking Teacher Profiles' as check_type, count(*) as count FROM teacher_profiles;
SELECT 'Checking Teacher Course Groups' as check_type, count(*) as count FROM teacher_course_groups;

-- Verify teacher profile linking
SELECT 
    p.id,
    p.first_name,
    p.last_name,
    tp.employee_id,
    u.email,
    u.raw_user_meta_data->>'department' as department
FROM profiles p
JOIN teacher_profiles tp ON p.id = tp.id
JOIN auth.users u ON p.id = u.id
WHERE p.role = 'teacher';

COMMIT;

/*
Note: Student creation is handled separately and should follow a similar pattern:
1. Create student auth users in batches via Supabase Dashboard or API
2. Update the profiles and student_profiles tables with the correct auth user IDs
*/