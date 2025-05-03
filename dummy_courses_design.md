# Handling Students Without Courses - Frontend Implementation Design

## 1. Overview
This document outlines the frontend implementation approach for handling students without assigned courses using a dummy course system. This ensures students without real courses have a consistent UI experience while clearly indicating their pending status.

## 2. Models and State Management

### 2.1. Dummy Course Model
```dart
class DummyCourse extends ClassInfo {
  final bool isDummy;
  
  DummyCourse({
    required String id,
    required String studentId,
    required int academicYear,
    required String semester,
  }) : isDummy = true,
       super(
         id: id,
         code: 'DUMMY-$academicYear-$semester',
         title: 'Pending Course Assignment',
         description: 'Temporary course for unassigned students',
         creditHours: 0,
         yearOfStudy: academicYear,
         semester: semester,
         groups: [DummyGroup()],
         schedule: 'TBA',
         type: ClassType.course,
       );
}

class DummyGroup extends CourseGroup {
  DummyGroup() : super(
    id: 'dummy',
    name: 'Unassigned Group',
    academicYear: DateTime.now().year,
    currentYear: DateTime.now().year,
    section: 'UA',
    studentCount: 1,
  );
}
```

### 2.2. State Management
```dart
class DummyCourseNotifier extends StateNotifier<List<DummyCourse>> {
  final StudentProfileProvider _profileProvider;
  
  DummyCourseNotifier(this._profileProvider);
  
  Future<void> checkAndCreateDummyCourse() async {
    final student = await _profileProvider.getCurrentStudent();
    if (!await _hasValidCourses(student)) {
      state = [
        DummyCourse(
          id: 'dummy-${student.id}',
          studentId: student.id,
          academicYear: DateTime.now().year,
          semester: _getCurrentSemester(),
        )
      ];
    }
  }
  
  bool _hasValidCourses(StudentProfile student) {
    // Check if student has valid course assignments
    // Implementation details here
  }
  
  String _getCurrentSemester() {
    // Logic to determine current semester
    // Implementation details here
  }
}
```

## 3. UI Implementation

### 3.1. Student Dashboard Modifications
```dart
class StudentDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(coursesProvider);
    final dummyCourses = ref.watch(dummyCourseProvider);
    
    return Column(
      children: [
        if (dummyCourses.isNotEmpty)
          DummyCourseWarningBanner(),
        CoursesList(
          courses: [...courses, ...dummyCourses],
          isDummyEnabled: false,
        ),
      ],
    );
  }
}

class DummyCourseWarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.amber.shade100,
      child: Text(
        'Your course assignment is pending. Please contact your administrator.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
```

### 3.2. Course List Item Modifications
```dart
class CourseListItem extends StatelessWidget {
  final ClassInfo course;
  
  @override
  Widget build(BuildContext context) {
    if (course is DummyCourse) {
      return DummyCourseCard();
    }
    return RegularCourseCard(course: course);
  }
}

class DummyCourseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.pending_outlined),
        title: Text('Pending Course Assignment'),
        subtitle: Text('Please contact administration'),
        trailing: Icon(Icons.warning_amber_rounded),
      ),
    );
  }
}
```

## 4. Implementation Steps

1. Create Models
   - Implement `DummyCourse` and `DummyGroup` classes
   - Add necessary extensions to `ClassInfo` for dummy course handling

2. State Management
   - Create `DummyCourseNotifier` for managing dummy course state
   - Integrate with existing `StudentProfileProvider`
   - Implement course validation logic

3. UI Components
   - Add `DummyCourseWarningBanner` component
   - Modify `CourseListItem` to handle dummy courses
   - Create `DummyCourseCard` component

4. Testing
   - Unit tests for dummy course creation logic
   - Widget tests for UI components
   - Integration tests for state management

## 5. Error Handling and Edge Cases

1. Handle transition states when courses are assigned
2. Graceful degradation when course data is unavailable
3. Clear error messages for administrative contact
4. Proper state updates when dummy status changes

## 6. Accessibility Considerations

1. Clear visual indicators for dummy course status
2. Proper semantic labels for screen readers
3. High contrast warning messages
4. Keyboard navigation support
