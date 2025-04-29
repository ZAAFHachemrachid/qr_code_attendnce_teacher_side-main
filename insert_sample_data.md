# SQL Insert Statements for Sample Data

## Departments Insert
```sql
INSERT INTO departments (name, code) VALUES
('Computer Science & Engineering', 'CSE'),
('Electrical Engineering', 'EE'), 
('Mechanical Engineering', 'ME'),
('Civil Engineering', 'CE'),
('Mathematics & Physics', 'MP');
```

## Courses Insert
```sql
-- Computer Science Courses
INSERT INTO courses (code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
('CSE101', 'Introduction to Programming', 'Fundamental concepts of programming using Python', 4, (SELECT id FROM departments WHERE code = 'CSE'), 1, 'semester1'),
('CSE102', 'Data Structures', 'Basic data structures and algorithms', 4, (SELECT id FROM departments WHERE code = 'CSE'), 1, 'semester2'),
('CSE201', 'Database Systems', 'Introduction to database design and SQL', 3, (SELECT id FROM departments WHERE code = 'CSE'), 2, 'semester1'),
('CSE202', 'Operating Systems', 'Fundamentals of operating system design', 3, (SELECT id FROM departments WHERE code = 'CSE'), 2, 'semester2'),
('CSE301', 'Software Engineering', 'Software development lifecycle and methodologies', 3, (SELECT id FROM departments WHERE code = 'CSE'), 3, 'semester1'),
('CSE302', 'Computer Networks', 'Network protocols and architecture', 3, (SELECT id FROM departments WHERE code = 'CSE'), 3, 'semester2'),
('CSE401', 'Artificial Intelligence', 'Introduction to AI and machine learning', 4, (SELECT id FROM departments WHERE code = 'CSE'), 4, 'semester1'),
('CSE402', 'Web Development', 'Modern web technologies and frameworks', 3, (SELECT id FROM departments WHERE code = 'CSE'), 4, 'semester2'),
('CSE403', 'Cybersecurity', 'Network security and cryptography', 3, (SELECT id FROM departments WHERE code = 'CSE'), 4, 'semester3'),
('CSE404', 'Cloud Computing', 'Distributed systems and cloud services', 3, (SELECT id FROM departments WHERE code = 'CSE'), 4, 'semester4');

-- Electrical Engineering Courses
INSERT INTO courses (code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
('EE101', 'Circuit Analysis', 'Basic electrical circuit analysis and design', 4, (SELECT id FROM departments WHERE code = 'EE'), 1, 'semester1'),
('EE102', 'Digital Electronics', 'Introduction to digital logic and circuits', 4, (SELECT id FROM departments WHERE code = 'EE'), 1, 'semester2'),
('EE201', 'Signals and Systems', 'Analysis of continuous and discrete signals', 3, (SELECT id FROM departments WHERE code = 'EE'), 2, 'semester1'),
('EE202', 'Microprocessors', 'Architecture and programming of microprocessors', 3, (SELECT id FROM departments WHERE code = 'EE'), 2, 'semester2'),
('EE301', 'Control Systems', 'Feedback control system analysis', 3, (SELECT id FROM departments WHERE code = 'EE'), 3, 'semester1'),
('EE302', 'Power Systems', 'Electric power generation and distribution', 3, (SELECT id FROM departments WHERE code = 'EE'), 3, 'semester2'),
('EE401', 'Communication Systems', 'Analog and digital communications', 4, (SELECT id FROM departments WHERE code = 'EE'), 4, 'semester1'),
('EE402', 'VLSI Design', 'Very Large Scale Integration circuits', 3, (SELECT id FROM departments WHERE code = 'EE'), 4, 'semester2'),
('EE403', 'Embedded Systems', 'Real-time embedded system design', 3, (SELECT id FROM departments WHERE code = 'EE'), 4, 'semester3'),
('EE404', 'Robotics', 'Introduction to robotics and automation', 3, (SELECT id FROM departments WHERE code = 'EE'), 4, 'semester4');

-- Mechanical Engineering Courses
INSERT INTO courses (code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
('ME101', 'Engineering Mechanics', 'Fundamental principles of mechanics', 4, (SELECT id FROM departments WHERE code = 'ME'), 1, 'semester1'),
('ME102', 'Thermodynamics', 'Basic concepts of thermal energy and heat transfer', 4, (SELECT id FROM departments WHERE code = 'ME'), 1, 'semester2'),
('ME201', 'Fluid Mechanics', 'Behavior of fluids and fluid systems', 3, (SELECT id FROM departments WHERE code = 'ME'), 2, 'semester1'),
('ME202', 'Machine Design', 'Principles of mechanical component design', 3, (SELECT id FROM departments WHERE code = 'ME'), 2, 'semester2'),
('ME301', 'Heat Transfer', 'Principles of heat transfer and applications', 3, (SELECT id FROM departments WHERE code = 'ME'), 3, 'semester1'),
('ME302', 'Manufacturing Processes', 'Modern manufacturing methods', 3, (SELECT id FROM departments WHERE code = 'ME'), 3, 'semester2'),
('ME401', 'Automotive Engineering', 'Vehicle systems and dynamics', 4, (SELECT id FROM departments WHERE code = 'ME'), 4, 'semester1'),
('ME402', 'HVAC Systems', 'Heating, ventilation, and air conditioning', 3, (SELECT id FROM departments WHERE code = 'ME'), 4, 'semester2'),
('ME403', 'Industrial Automation', 'Automation in manufacturing', 3, (SELECT id FROM departments WHERE code = 'ME'), 4, 'semester3'),
('ME404', 'Energy Systems', 'Renewable and conventional energy systems', 3, (SELECT id FROM departments WHERE code = 'ME'), 4, 'semester4');

-- Civil Engineering Courses
INSERT INTO courses (code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
('CE101', 'Structural Analysis', 'Basic principles of structural engineering', 4, (SELECT id FROM departments WHERE code = 'CE'), 1, 'semester1'),
('CE102', 'Construction Materials', 'Properties and applications of construction materials', 4, (SELECT id FROM departments WHERE code = 'CE'), 1, 'semester2'),
('CE201', 'Soil Mechanics', 'Fundamentals of soil behavior and engineering', 3, (SELECT id FROM departments WHERE code = 'CE'), 2, 'semester1'),
('CE202', 'Hydraulics', 'Flow of water in civil engineering systems', 3, (SELECT id FROM departments WHERE code = 'CE'), 2, 'semester2'),
('CE301', 'Reinforced Concrete', 'Design of reinforced concrete structures', 3, (SELECT id FROM departments WHERE code = 'CE'), 3, 'semester1'),
('CE302', 'Transportation Engineering', 'Highway and traffic engineering', 3, (SELECT id FROM departments WHERE code = 'CE'), 3, 'semester2'),
('CE401', 'Foundation Engineering', 'Design of building foundations', 4, (SELECT id FROM departments WHERE code = 'CE'), 4, 'semester1'),
('CE402', 'Environmental Engineering', 'Water and wastewater treatment', 3, (SELECT id FROM departments WHERE code = 'CE'), 4, 'semester2'),
('CE403', 'Construction Management', 'Project planning and management', 3, (SELECT id FROM departments WHERE code = 'CE'), 4, 'semester3'),
('CE404', 'Steel Structures', 'Design of steel building components', 3, (SELECT id FROM departments WHERE code = 'CE'), 4, 'semester4');

-- Mathematics & Physics Courses
INSERT INTO courses (code, title, description, credit_hours, department_id, year_of_study, semester) VALUES
('MP101', 'Calculus I', 'Differential and integral calculus', 4, (SELECT id FROM departments WHERE code = 'MP'), 1, 'semester1'),
('MP102', 'Physics Mechanics', 'Classical mechanics and Newton laws', 4, (SELECT id FROM departments WHERE code = 'MP'), 1, 'semester2'),
('MP201', 'Linear Algebra', 'Vector spaces and linear transformations', 3, (SELECT id FROM departments WHERE code = 'MP'), 2, 'semester1'),
('MP202', 'Quantum Physics', 'Introduction to quantum mechanics', 3, (SELECT id FROM departments WHERE code = 'MP'), 2, 'semester2'),
('MP301', 'Differential Equations', 'Ordinary and partial differential equations', 3, (SELECT id FROM departments WHERE code = 'MP'), 3, 'semester1'),
('MP302', 'Statistical Physics', 'Thermodynamics and statistical mechanics', 3, (SELECT id FROM departments WHERE code = 'MP'), 3, 'semester2'),
('MP401', 'Complex Analysis', 'Functions of complex variables', 4, (SELECT id FROM departments WHERE code = 'MP'), 4, 'semester1'),
('MP402', 'Electromagnetic Theory', 'Maxwells equations and applications', 3, (SELECT id FROM departments WHERE code = 'MP'), 4, 'semester2'),
('MP403', 'Numerical Methods', 'Computational mathematics', 3, (SELECT id FROM departments WHERE code = 'MP'), 4, 'semester3'),
('MP404', 'Particle Physics', 'Elementary particles and interactions', 3, (SELECT id FROM departments WHERE code = 'MP'), 4, 'semester4');
```

Copy these INSERT statements and execute them in your database to populate the departments and courses tables. Make sure to execute the departments insert first, as the courses depend on the department IDs.