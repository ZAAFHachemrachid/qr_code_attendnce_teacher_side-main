import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_code_attendance/features/teacher/services/teacher_classes_service.dart';
import 'package:qr_code_attendance/features/teacher/models/teacher_class.dart';
import 'package:qr_code_attendance/features/teacher/models/course.dart'
    show ClassInfo;
import 'package:qr_code_attendance/features/teacher/models/class_type.dart';

@GenerateNiceMocks([MockSpec<SupabaseClient>()])
import 'teacher_classes_service_test.mocks.dart';

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late TeacherClassesService service;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    service = TeacherClassesService(mockSupabaseClient);
  });

  group('TeacherClassesService', () {
    const teacherId = 'test-teacher-id';
    const academicPeriod = '2024-2025';

    group('getTeacherCourses', () {
      test('should return list of courses on success', () async {
        // Arrange
        final coursesResponse = [
          {
            'course_id': 'course-1',
            'courses': {
              'id': 'course-1',
              'code': 'CS101',
              'title': 'Intro to CS',
              'description': 'Introduction to Computer Science',
              'credit_hours': 3,
              'year_of_study': 1,
              'semester': 1,
            }
          }
        ];

        final groupsResponse = [
          {
            'course_id': 'course-1',
            'student_groups': {
              'id': 'group-1',
              'name': 'Group A',
              'academic_year': '2024-2025',
              'current_year': 1,
              'section': 'A',
              'student_count': 30
            }
          }
        ];

        when(mockSupabaseClient.from('teacher_course_groups').select(any))
            .thenAnswer((_) async => coursesResponse);

        when(mockSupabaseClient
                .from('teacher_course_groups')
                .select(any)
                .eq('teacher_id', teacherId)
                .eq('academic_period', academicPeriod)
                .inFilter('course_id', ['course-1']))
            .thenAnswer((_) async => groupsResponse);

        // Act
        final result =
            await service.getTeacherCourses(teacherId, academicPeriod);

        // Assert
        expect(result, isA<List<ClassInfo>>());
        expect(result.length, 1);
        expect(result.first.id, 'course-1');
        expect(result.first.code, 'CS101');
        verify(mockSupabaseClient.from('teacher_course_groups').select(any))
            .called(2);
      });

      test('should throw exception on API error', () async {
        // Arrange
        when(mockSupabaseClient.from('teacher_course_groups').select(any))
            .thenThrow(Exception('API Error'));

        // Act & Assert
        expect(
          () => service.getTeacherCourses(teacherId, academicPeriod),
          throwsException,
        );
      });
    });

    group('getClassById', () {
      test('should return class details on success', () async {
        // Arrange
        const classId = 'class-1';
        final classResponse = {
          'id': classId,
          'code': 'CS101',
          'title': 'Intro to CS',
          'description': 'Introduction to Computer Science',
          'credit_hours': 3,
          'year_of_study': 1,
          'semester': 1,
          'groups': [
            {
              'id': 'group-1',
              'name': 'Group A',
              'academic_year': '2024-2025',
              'current_year': 1,
              'section': 'A',
              'student_count': 30
            }
          ]
        };

        when(mockSupabaseClient
                .from('courses')
                .select(any)
                .eq('id', classId)
                .single())
            .thenAnswer((_) async => classResponse);

        // Act
        final result = await service.getClassById(classId);

        // Assert
        expect(result, isA<TeacherClass>());
        expect(result.id, classId);
        expect(result.code, 'CS101');
        verify(mockSupabaseClient.from('courses').select(any)).called(1);
      });

      test('should throw exception when class not found', () async {
        // Arrange
        const classId = 'non-existent';
        when(mockSupabaseClient
                .from('courses')
                .select(any)
                .eq('id', classId)
                .single())
            .thenThrow(Exception('Not found'));

        // Act & Assert
        expect(
          () => service.getClassById(classId),
          throwsException,
        );
      });
    });

    group('createClass', () {
      test('should create and return new class', () async {
        // Arrange
        final newClass = TeacherClass(
          id: 'new-class',
          code: 'CS102',
          title: 'Programming',
          description: 'Introduction to Programming',
          creditHours: 3,
          yearOfStudy: 1,
          semester: '1',
          academicPeriod: '2024-2025',
          type: ClassType.course,
          groups: [],
          schedule: 'Mon, Wed 10:00',
        );

        final response = {
          'id': 'new-class',
          'code': 'CS102',
          'title': 'Programming',
          'description': 'Introduction to Programming',
          'credit_hours': 3,
          'year_of_study': 1,
          'semester': 1,
          'academic_period': '2024-2025',
          'type': 'course'
        };

        when(mockSupabaseClient.from('courses').insert(any).select().single())
            .thenAnswer((_) async => response);

        // Act
        final result = await service.createClass(newClass);

        // Assert
        expect(result, isA<TeacherClass>());
        expect(result.code, newClass.code);
        expect(result.title, newClass.title);
        verify(mockSupabaseClient.from('courses').insert(any)).called(1);
      });

      test('should throw exception on create error', () async {
        // Arrange
        final newClass = TeacherClass(
          id: 'new-class',
          code: 'CS102',
          title: 'Programming',
          description: 'Introduction to Programming',
          creditHours: 3,
          yearOfStudy: 1,
          semester: '1',
          academicPeriod: '2024-2025',
          type: ClassType.course,
          groups: [],
          schedule: 'Mon, Wed 10:00',
        );

        when(mockSupabaseClient.from('courses').insert(any).select().single())
            .thenThrow(Exception('Create failed'));

        // Act & Assert
        expect(
          () => service.createClass(newClass),
          throwsException,
        );
      });
    });

    group('updateClass', () {
      test('should update and return updated class', () async {
        // Arrange
        final updatedClass = TeacherClass(
          id: 'class-1',
          code: 'CS101-Updated',
          title: 'Updated Course',
          description: 'Updated Description',
          creditHours: 4,
          yearOfStudy: 2,
          semester: '2',
          academicPeriod: '2024-2025',
          type: ClassType.course,
          groups: [],
          schedule: 'Tue, Thu 13:00',
        );

        final response = {
          'id': 'class-1',
          'code': 'CS101-Updated',
          'title': 'Updated Course',
          'description': 'Updated Description',
          'credit_hours': 4,
          'year_of_study': 2,
          'semester': 2,
          'academic_period': '2024-2025',
          'type': 'course'
        };

        when(mockSupabaseClient
                .from('courses')
                .update(any)
                .eq('id', updatedClass.id)
                .select()
                .single())
            .thenAnswer((_) async => response);

        // Act
        final result = await service.updateClass(updatedClass);

        // Assert
        expect(result, isA<TeacherClass>());
        expect(result.code, updatedClass.code);
        expect(result.title, updatedClass.title);
        verify(mockSupabaseClient.from('courses').update(any)).called(1);
      });
    });

    group('deleteClass', () {
      test('should delete class successfully', () async {
        // Arrange
        const classId = 'class-1';
        when(mockSupabaseClient.from('courses').delete().eq('id', classId))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => service.deleteClass(classId),
          returnsNormally,
        );
        verify(mockSupabaseClient.from('courses').delete()).called(1);
      });

      test('should throw exception on delete error', () async {
        // Arrange
        const classId = 'class-1';
        when(mockSupabaseClient.from('courses').delete().eq('id', classId))
            .thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => service.deleteClass(classId),
          throwsException,
        );
      });
    });
  });
}
