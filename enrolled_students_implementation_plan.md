# Enrolled Students Implementation Plan

## Database Query
```sql
SELECT 
    p.first_name,
    p.last_name,
    sp.student_number,
    sg.name as group_name,
    sg.section,
    sg.current_year
FROM 
    student_profiles sp
    JOIN profiles p ON sp.id = p.id
    JOIN student_groups sg ON sp.group_id = sg.id
    JOIN group_courses gc ON sg.id = gc.group_id
    JOIN courses c ON gc.course_id = c.id
WHERE 
    c.id = :course_id
    AND gc.academic_period = :academic_period;
```

## Data Models

### Student Profile Model
```dart
class StudentProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String studentNumber;
  final String groupName;
  final String section;
  final int currentYear;
}
```

## Service Layer

### Teacher Students Service
- `fetchEnrolledStudents(courseId, academicPeriod)`
- `getStudentAttendanceStats(courseId, studentId)`

## UI Components

### Enrolled Students Tab
1. Students List View:
   - StudentCard widget for each student
   - Shows name, ID, group info
   - Attendance stats summary
   - Sort/filter options

2. Header Section:
   - Total students count
   - Group-wise breakdown
   - Search/filter controls

### Student Card Widget
- Student name and ID
- Group info
- Attendance percentage
- Quick action buttons
  - View detailed attendance
  - Add note
  - Mark special status

## State Management
```dart
final enrolledStudentsProvider = FutureProvider.family<List<StudentProfile>, String>(
  (ref, courseId) => teacherStudentsService.fetchEnrolledStudents(courseId)
);
```

## Implementation Phases

### Phase 1: Core Features
1. Create data models
2. Implement service layer
3. Basic UI with students list
4. Basic state management

### Phase 2: UI Enhancements
1. Add sort/filter functionality
2. Improve card design
3. Add loading states
4. Error handling

### Phase 3: Additional Features
1. Student attendance stats
2. Search functionality
3. Group-wise view toggle
4. Export options

## Navigation and Integration
- Add "Students" tab in course details
- Link to individual student profiles
- Connect with attendance history