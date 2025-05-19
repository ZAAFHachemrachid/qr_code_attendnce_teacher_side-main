import 'package:flutter_riverpod/flutter_riverpod.dart';

final academicPeriodsProvider = Provider<List<String>>((ref) {
  // Generate last 2 years + current year + next year
  final currentYear = DateTime.now().year;
  return [
    (currentYear - 2).toString(),
    (currentYear - 1).toString(),
    currentYear.toString(),
    (currentYear + 1).toString(),
  ];
});

final currentAcademicPeriodProvider = StateProvider<String>((ref) {
  return DateTime.now().year.toString();
});
