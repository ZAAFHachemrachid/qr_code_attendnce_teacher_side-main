-- Enable UUID generation
create extension if not exists "uuid-ossp";

-- Department table
CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    code VARCHAR(10) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Student Groups table
CREATE TABLE student_groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    department_id UUID REFERENCES departments(id),
    academic_year INT NOT NULL,
    current_year INT NOT NULL,
    section VARCHAR(10) NOT NULL,
    name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(department_id, academic_year, section)
);

-- Profiles table (extends Supabase auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(20) CHECK (role IN ('admin', 'teacher', 'student')),
    phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Admin profiles
CREATE TABLE admin_profiles (
    id UUID PRIMARY KEY REFERENCES profiles(id),
    access_level VARCHAR(20) DEFAULT 'limited' CHECK (access_level IN ('super', 'limited')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Student profiles
CREATE TABLE student_profiles (
    id UUID PRIMARY KEY REFERENCES profiles(id),
    student_number VARCHAR(20) UNIQUE NOT NULL,
    group_id UUID REFERENCES student_groups(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Teacher profiles
CREATE TABLE teacher_profiles (
    id UUID PRIMARY KEY REFERENCES profiles(id),
    department_id UUID REFERENCES departments(id),
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Courses
CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    credit_hours INT NOT NULL,
    department_id UUID REFERENCES departments(id),
    year_of_study INT NOT NULL,
    semester VARCHAR(20) CHECK (semester IN ('semester1', 'semester2', 'semester3','semester4','semester5')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Group-Course assignments
CREATE TABLE group_courses (
    group_id UUID REFERENCES student_groups(id),
    course_id UUID REFERENCES courses(id),
    academic_period VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (group_id, course_id, academic_period)
);

-- Teacher-Course-Group relationships
CREATE TABLE teacher_course_groups (
    teacher_id UUID REFERENCES teacher_profiles(id),
    course_id UUID REFERENCES courses(id),
    group_id UUID REFERENCES student_groups(id),
    academic_period VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (teacher_id, course_id, group_id, academic_period)
);

-- Time slots reference table
CREATE TABLE time_slots (
    id SERIAL PRIMARY KEY,
    slot_number INTEGER NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    UNIQUE(slot_number)
);

-- Insert predefined time slots (1.5 hour each with 8 AM start)
INSERT INTO time_slots (slot_number, start_time, end_time) VALUES
(1, '08:00:00', '09:30:00'),
(2, '09:30:00', '11:00:00'),
(3, '11:00:00', '12:30:00'),
(4, '12:30:00', '14:00:00'),
(5, '14:00:00', '15:30:00'),
(6, '15:30:00', '17:00:00');

-- Create a weekly schedule timeline table using time slots
CREATE TABLE weekly_schedule (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id),
    group_id UUID NOT NULL REFERENCES student_groups(id),
    teacher_id UUID NOT NULL REFERENCES teacher_profiles(id),
    type_c VARCHAR(20) CHECK (type_c IN ('TP', 'TD', 'Course')),
    day_of_week VARCHAR(10) CHECK (day_of_week IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')),
    time_slot_id INTEGER NOT NULL REFERENCES time_slots(id),
    room VARCHAR(50) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(course_id, group_id, teacher_id, day_of_week, time_slot_id),
    UNIQUE(day_of_week, time_slot_id, room), -- Ensures room isn't double-booked
    UNIQUE(day_of_week, time_slot_id, group_id), -- Ensures group doesn't have overlapping classes
    UNIQUE(day_of_week, time_slot_id, teacher_id) -- Ensures teacher doesn't have overlapping classes
);

-- Create an index to improve query performance for student schedule lookup
CREATE INDEX idx_weekly_schedule_group ON weekly_schedule(group_id);

-- Create an index to improve query performance for teacher schedule lookup
CREATE INDEX idx_weekly_schedule_teacher ON weekly_schedule(teacher_id);

-- Sessions
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id),
    group_id UUID NOT NULL REFERENCES student_groups(id),
    teacher_id UUID NOT NULL REFERENCES teacher_profiles(id), 
    type_c VARCHAR(20) CHECK (type_c IN ('TP', 'TD', 'Course')),
    title VARCHAR(100),
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(50),
    qr_code TEXT,
    qr_expiry TIMESTAMP WITH TIME ZONE,
    weekly_schedule_id UUID REFERENCES weekly_schedule(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Attendance records
CREATE TABLE attendance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES sessions(id),
    student_id UUID NOT NULL REFERENCES student_profiles(id),
    status VARCHAR(20) CHECK (status IN ('present', 'absent', 'late', 'excused')),
    check_in_time TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (session_id, student_id)
);

-- Create a view for student timeline to easily fetch a student's weekly schedule
CREATE OR REPLACE VIEW student_timeline AS
SELECT 
    ws.id,
    sg.name AS group_name,
    c.title AS course_name,
    c.code AS course_code,
    ws.type_c,
    CONCAT(p.first_name, ' ', p.last_name) AS teacher_name,
    ws.day_of_week,
    ts.start_time,
    ts.end_time,
    ts.slot_number,
    ws.room
FROM 
    weekly_schedule ws
    JOIN student_groups sg ON ws.group_id = sg.id
    JOIN courses c ON ws.course_id = c.id
    JOIN teacher_profiles tp ON ws.teacher_id = tp.id
    JOIN profiles p ON tp.id = p.id
    JOIN time_slots ts ON ws.time_slot_id = ts.id
ORDER BY
    CASE 
        WHEN ws.day_of_week = 'Monday' THEN 1
        WHEN ws.day_of_week = 'Tuesday' THEN 2
        WHEN ws.day_of_week = 'Wednesday' THEN 3
        WHEN ws.day_of_week = 'Thursday' THEN 4
        WHEN ws.day_of_week = 'Friday' THEN 5
        WHEN ws.day_of_week = 'Saturday' THEN 6
        WHEN ws.day_of_week = 'Sunday' THEN 7
    END,
    ts.slot_number;

-- Create a view for teacher timeline to easily fetch a teacher's weekly schedule
CREATE OR REPLACE VIEW teacher_timeline AS
SELECT 
    ws.id,
    c.title AS course_name,
    c.code AS course_code,
    ws.type_c,
    sg.name AS group_name,
    ws.day_of_week,
    ts.start_time,
    ts.end_time,
    ts.slot_number,
    ws.room
FROM 
    weekly_schedule ws
    JOIN teacher_profiles tp ON ws.teacher_id = tp.id
    JOIN courses c ON ws.course_id = c.id
    JOIN student_groups sg ON ws.group_id = sg.id
    JOIN time_slots ts ON ws.time_slot_id = ts.id
ORDER BY
    CASE 
        WHEN ws.day_of_week = 'Monday' THEN 1
        WHEN ws.day_of_week = 'Tuesday' THEN 2
        WHEN ws.day_of_week = 'Wednesday' THEN 3
        WHEN ws.day_of_week = 'Thursday' THEN 4
        WHEN ws.day_of_week = 'Friday' THEN 5
        WHEN ws.day_of_week = 'Saturday' THEN 6
        WHEN ws.day_of_week = 'Sunday' THEN 7
    END,
    ts.slot_number;

-- Create function to generate sessions from weekly schedule for a given date range
CREATE OR REPLACE FUNCTION generate_sessions_from_schedule(
    start_date DATE,
    end_date DATE
) RETURNS VOID AS $$
DECLARE
    curr_date DATE := start_date;
    day_name TEXT;
    rec RECORD;
BEGIN
    WHILE curr_date <= end_date LOOP
        -- Get day name for the current date
        day_name := to_char(curr_date, 'Day');
        day_name := trim(day_name);
        
        -- For each weekly schedule entry matching the day
        FOR rec IN 
            SELECT 
                ws.id, 
                ws.course_id, 
                ws.group_id, 
                ws.teacher_id, 
                ws.type_c, 
                ws.room, 
                ts.start_time, 
                ts.end_time
            FROM 
                weekly_schedule ws
                JOIN time_slots ts ON ws.time_slot_id = ts.id
            WHERE 
                ws.day_of_week = day_name
        LOOP
            -- Insert a session for this date and schedule entry
            INSERT INTO sessions (
                course_id, 
                group_id, 
                teacher_id, 
                type_c, 
                title,
                session_date, 
                start_time, 
                end_time, 
                room, 
                weekly_schedule_id
            ) VALUES (
                rec.course_id,
                rec.group_id,
                rec.teacher_id,
                rec.type_c,
                (SELECT title FROM courses WHERE id = rec.course_id),
                curr_date,
                rec.start_time,
                rec.end_time,
                rec.room,
                rec.id
            );
        END LOOP;
        
        -- Move to the next day
        curr_date := curr_date + INTERVAL '1 day';
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Example usage: Generate sessions for a semester
-- SELECT generate_sessions_from_schedule('2025-01-15', '2025-05-15');