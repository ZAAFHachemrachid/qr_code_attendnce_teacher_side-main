# Database Sample Data Plan

## Overview
This document outlines the sample data structure for departments and courses in our university database system.

## Department Data
We will create 5 key departments:

1. Computer Science & Engineering (CSE)
2. Electrical Engineering (EE)
3. Mechanical Engineering (ME)
4. Civil Engineering (CE)
5. Mathematics & Physics (MP)

## SQL Insert Statements for Departments
```sql
INSERT INTO departments (name, code) VALUES
('Computer Science & Engineering', 'CSE'),
('Electrical Engineering', 'EE'),
('Mechanical Engineering', 'ME'),
('Civil Engineering', 'CE'),
('Mathematics & Physics', 'MP');
```

## Course Data Structure
For each department, courses will be organized by:
- Year of study (1-5)
- Semester (semester1-semester5)
- Credit hours (typically 3-4)

## SQL Insert Statements for Courses
```sql
-- Computer Science Courses
INSERT INTO courses (code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
('CSE101', 'Introduction to Programming', 'Fundamental concepts of programming using Python', 4, (SELECT id FROM departments WHERE code = 'CSE'), 1, 'semester1'),
('CSE102', 'Data Structures', 'Basic data structures and algorithms', 4, (SELECT id FROM departments WHERE code = 'CSE'), 1, 'semester2'),
('CSE201', 'Database Systems', 'Introduction to database design and SQL', 3, (SELECT id FROM departments WHERE code = 'CSE'), 2, 'semester1'),
('CSE301', 'Software Engineering', 'Software development lifecycle and methodologies', 3, (SELECT id FROM departments WHERE code = 'CSE'), 3, 'semester1');

-- Electrical Engineering Courses
INSERT INTO courses (code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
('EE101', 'Circuit Analysis', 'Basic electrical circuit analysis and design', 4, (SELECT id FROM departments WHERE code = 'EE'), 1, 'semester1'),
('EE102', 'Digital Electronics', 'Introduction to digital logic and circuits', 4, (SELECT id FROM departments WHERE code = 'EE'), 1, 'semester2'),
('EE201', 'Signals and Systems', 'Analysis of continuous and discrete signals', 3, (SELECT id FROM departments WHERE code = 'EE'), 2, 'semester1');

-- Mechanical Engineering Courses
INSERT INTO courses (code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
('ME101', 'Engineering Mechanics', 'Fundamental principles of mechanics', 4, (SELECT id FROM departments WHERE code = 'ME'), 1, 'semester1'),
('ME102', 'Thermodynamics', 'Basic concepts of thermal energy and heat transfer', 4, (SELECT id FROM departments WHERE code = 'ME'), 1, 'semester2'),
('ME201', 'Fluid Mechanics', 'Behavior of fluids and fluid systems', 3, (SELECT id FROM departments WHERE code = 'ME'), 2, 'semester1');

-- Civil Engineering Courses
INSERT INTO courses (code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
('CE101', 'Structural Analysis', 'Basic principles of structural engineering', 4, (SELECT id FROM departments WHERE code = 'CE'), 1, 'semester1'),
('CE102', 'Construction Materials', 'Properties and applications of construction materials', 4, (SELECT id FROM departments WHERE code = 'CE'), 1, 'semester2'),
('CE201', 'Soil Mechanics', 'Fundamentals of soil behavior and engineering', 3, (SELECT id FROM departments WHERE code = 'CE'), 2, 'semester1');

-- Mathematics & Physics Courses
INSERT INTO courses (code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
('MP101', 'Calculus I', 'Differential and integral calculus', 4, (SELECT id FROM departments WHERE code = 'MP'), 1, 'semester1'),
('MP102', 'Physics Mechanics', 'Classical mechanics and Newton laws', 4, (SELECT id FROM departments WHERE code = 'MP'), 1, 'semester2'),
('MP201', 'Linear Algebra', 'Vector spaces and linear transformations', 3, (SELECT id FROM departments WHERE code = 'MP'), 2, 'semester1');
```

## Implementation Steps
1. First execute the department inserts to create the departments
2. Then execute the course inserts to populate the courses table
3. Verify the data after insertion