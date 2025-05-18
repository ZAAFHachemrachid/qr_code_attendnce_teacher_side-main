import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/teacher_class.dart';
import '../models/course.dart';

final dummyTeacherClassesProvider =
    StateNotifierProvider<DummyTeacherClassesNotifier, AsyncValue<List<TeacherClass>>>(
  (ref) => DummyTeacherClassesNotifier(),
);

class DummyTeacherClassesNotifier extends StateNotifier<AsyncValue<List<TeacherClass>>> {
  static const int maxDummyClasses = 3;

  DummyTeacherClassesNotifier() : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(
        List.generate(
          maxDummyClasses,
          (index) {
            final classType = ClassType.values[index % ClassType.values.length];
            final allGroups = [
              CourseGroup(
                id: 'group-${index + 1}-A',
                name: 'Group ${index + 1}A',
                academicYear: DateTime.now().year,
                currentYear: 1 + (index % 3),
                section: 'A',
                studentCount: 20 + index * 5,
              ),
              CourseGroup(
                id: 'group-${index + 1}-B',
                name: 'Group ${index + 1}B',
                academicYear: DateTime.now().year,
                currentYear: 1 + (index % 3),
                section: 'B',
                studentCount: 18 + index * 4,
              ),
              CourseGroup(
                id: 'group-${index + 1}-C',
                name: 'Group ${index + 1}C',
                academicYear: DateTime.now().year,
                currentYear: 1 + (index % 3),
                section: 'C',
                studentCount: 22 + index * 3,
              ),
            ];
            List<CourseGroup> groups;
            if (classType == ClassType.course) {
              groups = allGroups;
            } else {
              groups = [allGroups[0]];
            }
            return TeacherClass(
              id: 'dummy-class-$index',
              code: 'CLS${100 + index}',
              title: 'Dummy Class ${index + 1}',
              description: 'This is a dummy class for demonstration purposes.',
              creditHours: 3,
              yearOfStudy: 1 + (index % 3),
              semester: 'SPRING',
              academicPeriod: DateTime.now().year.toString(),
              groups: groups,
              schedule: 'Mon ${8 + index}:00 - ${10 + index}:00',
              type: classType,
            );
          },
        ),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void refreshDummyClasses() async {
    await _initialize();
  }

  void clearDummyClasses() {
    state = const AsyncValue.data([]);
  }
}