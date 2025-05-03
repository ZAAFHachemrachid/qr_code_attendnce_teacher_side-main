-- Database Structure Creation Script
-- This script creates the basic academic structure without any user-related data

BEGIN;

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

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

BEGIN
    ------------------------------------------
    -- 1. Insert Departments 
    ------------------------------------------
    INSERT INTO departments (id, name, code) VALUES
    (cs_dept_id, 'Computer Science', 'CS'),
    (math_dept_id, 'Mathematics', 'MATH'),
    (phys_dept_id, 'Physics', 'PHY'),
    (ele_dept_id, 'Electronics', 'ELE');

    -- Verify departments
    RAISE NOTICE 'Departments created: %', (SELECT count(*) FROM departments);

    ------------------------------------------
    -- 2. Insert Student Groups
    ------------------------------------------
    INSERT INTO student_groups (id, department_id, academic_year, current_year, section, name) VALUES
    -- Computer Science Groups
    (cs_2a_group_id, cs_dept_id, 2024, 2, 'A', 'CS-2A-2024'),
    (cs_2b_group_id, cs_dept_id, 2024, 2, 'B', 'CS-2B-2024'),
    -- Mathematics Groups
    (math_2a_group_id, math_dept_id, 2024, 2, 'A', 'MATH-2A-2024'),
    (math_2b_group_id, math_dept_id, 2024, 2, 'B', 'MATH-2B-2024');

    -- Verify student groups
    RAISE NOTICE 'Student groups created: %', (SELECT count(*) FROM student_groups);

    ------------------------------------------
    -- 3. Insert Courses
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

    -- Verify courses
    RAISE NOTICE 'Courses created: %', (SELECT count(*) FROM courses);

    ------------------------------------------
    -- 4. Link Courses to Groups
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

    -- Verify group courses
    RAISE NOTICE 'Group-course associations created: %', (SELECT count(*) FROM group_courses);

END $$;

-- Final Verification Queries
SELECT 'Departments' as entity, count(*) as count FROM departments;
SELECT 'Student Groups' as entity, count(*) as count FROM student_groups;
SELECT 'Courses' as entity, count(*) as count FROM courses;
SELECT 'Group Courses' as entity, count(*) as count FROM group_courses;

-- Detailed Verification Queries
SELECT d.name as department, count(c.*) as course_count 
FROM departments d 
LEFT JOIN courses c ON d.id = c.department_id 
GROUP BY d.name;

SELECT sg.name as student_group, count(gc.*) as assigned_courses 
FROM student_groups sg 
LEFT JOIN group_courses gc ON sg.id = gc.group_id 
GROUP BY sg.name;

COMMIT;