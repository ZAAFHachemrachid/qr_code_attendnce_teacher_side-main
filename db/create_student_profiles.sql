-- Create student profiles from auth users
-- Links auth.users to profiles and creates student profile entries
-- Maintains group size limits and generates student numbers

-- Start transaction
BEGIN;

-- Function to distribute students into groups
CREATE OR REPLACE FUNCTION distribute_students_to_groups(
    p_department_id UUID,
    p_academic_year INTEGER,
    p_group_size INTEGER DEFAULT 15
) RETURNS TABLE (
    student_id UUID,
    group_id UUID,
    student_number VARCHAR
) AS $$
DECLARE
    v_department_code VARCHAR;
    v_student_count INTEGER;
    v_num_groups INTEGER;
BEGIN
    -- Get department code
    SELECT code INTO v_department_code
    FROM departments
    WHERE id = p_department_id;

    -- Calculate total number of students and required groups
    SELECT COUNT(*) INTO v_student_count
    FROM auth.users u
    WHERE u.email LIKE '%@student.%'
    AND NOT EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.id = u.id
    );

    -- Calculate number of groups needed (using integer division + 1 if there's remainder)
    v_num_groups := (v_student_count + p_group_size - 1) / p_group_size;

    -- Create groups as needed
    INSERT INTO student_groups (department_id, academic_year, current_year, section, name)
    SELECT 
        p_department_id,
        p_academic_year,
        1, -- Assuming new students start at year 1
        'Group-' || n,
        v_department_code || '-G' || LPAD(n::TEXT, 2, '0')
    FROM generate_series(1, v_num_groups) n;

    -- Return student distribution with generated student numbers
    RETURN QUERY
    WITH numbered_students AS (
        SELECT 
            u.id,
            ROW_NUMBER() OVER (ORDER BY u.email) AS rn
        FROM auth.users u
        WHERE u.email LIKE '%@student.%'
        AND NOT EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = u.id
        )
    ),
    group_assignments AS (
        SELECT 
            ns.id AS student_id,
            sg.id AS group_id,
            (
                p_academic_year::TEXT || '-' || -- Year component
                v_department_code || '-' ||      -- Department code component
                LPAD(ns.rn::TEXT, 3, '0')       -- Sequential number component
            )::VARCHAR AS student_number
        FROM numbered_students ns
        JOIN student_groups sg ON 
            sg.department_id = p_department_id AND
            sg.academic_year = p_academic_year AND
            ((ns.rn - 1) / p_group_size + 1) = 
            (REGEXP_REPLACE(sg.section, 'Group-', '')::integer)
    )
    SELECT * FROM group_assignments;
END;
$$ LANGUAGE plpgsql;

-- Create profiles for unassigned students
DO $$
DECLARE
    v_department_id UUID;
    v_academic_year INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
    v_student record;
BEGIN
    -- Get CS department ID (assuming it exists)
    SELECT id INTO v_department_id
    FROM departments
    WHERE code = 'CS'
    LIMIT 1;

    -- Distribute students and create profiles
    FOR v_student IN
        SELECT *
        FROM distribute_students_to_groups(v_department_id, v_academic_year)
    LOOP
        -- Create base profile
        INSERT INTO profiles (
            id,
            first_name,
            last_name,
            role,
            created_at,
            updated_at
        )
        SELECT
            u.id,
            SPLIT_PART(u.raw_user_meta_data->>'full_name', ' ', 1),
            SPLIT_PART(u.raw_user_meta_data->>'full_name', ' ', 2),
            'student',
            NOW(),
            NOW()
        FROM auth.users u
        WHERE u.id = v_student.student_id
        AND NOT EXISTS (
            SELECT 1 FROM profiles p
            WHERE p.id = u.id
        );

        -- Create student profile
        INSERT INTO student_profiles (
            id,
            student_number,
            group_id,
            created_at,
            updated_at
        ) VALUES (
            v_student.student_id,
            v_student.student_number,
            v_student.group_id,
            NOW(),
            NOW()
        );
    END LOOP;
END;
$$;

-- Verification queries
DO $$
DECLARE
    v_total_students INTEGER;
    v_assigned_students INTEGER;
    v_group_distribution TEXT;
BEGIN
    -- Check total number of student profiles created
    SELECT COUNT(*) INTO v_total_students
    FROM student_profiles;

    IF v_total_students = 0 THEN
        RAISE WARNING 'No student profiles were created';
        RETURN;
    END IF;

    -- Check number of students assigned to groups
    SELECT COUNT(*) INTO v_assigned_students
    FROM student_profiles
    WHERE group_id IS NOT NULL;

    -- Get group size distribution using a CTE to avoid nested aggregates
    WITH group_counts AS (
        SELECT 
            g.section,
            COUNT(sp.id) as student_count
        FROM student_groups g
        LEFT JOIN student_profiles sp ON sp.group_id = g.id
        GROUP BY g.id, g.section
        ORDER BY g.section
    )
    SELECT string_agg(
        'Group ' || section || ': ' || student_count::TEXT || ' students',
        E'\n'
        ORDER BY section
    ) INTO v_group_distribution
    FROM group_counts;

    -- Raise notice with verification results
    RAISE NOTICE 'Verification Results:';
    RAISE NOTICE '------------------------';
    RAISE NOTICE 'Total student profiles: %', v_total_students;
    RAISE NOTICE 'Assigned to groups: %', v_assigned_students;
    
    IF v_assigned_students < v_total_students THEN
        RAISE WARNING 'Some students were not assigned to groups: % unassigned', 
            v_total_students - v_assigned_students;
    END IF;

    IF v_group_distribution IS NULL THEN
        RAISE WARNING 'No groups were created';
    ELSE
        RAISE NOTICE 'Group Distribution:';
        RAISE NOTICE '%', v_group_distribution;
    END IF;
END;
$$;

-- Commit transaction
COMMIT;