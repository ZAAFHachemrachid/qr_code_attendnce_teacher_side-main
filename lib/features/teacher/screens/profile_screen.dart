import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/teacher_profile_provider.dart';
import '../providers/teacher_classes_provider.dart';
import 'teacher_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(teacherProfileProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: profileAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading profile: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        data: (profile) => ListView(
          children: [
            const SizedBox(height: 32),
            Center(
              child: CircleAvatar(
                radius: 64,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                child: const Icon(Icons.person, size: 64),
              ),
            ),
            const SizedBox(height: 24),
            if (profile != null) ...[
              Center(
                child: Text(
                  '${profile.firstName} ${profile.lastName}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Employee ID: ${profile.employeeId}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoCard(
                context,
                'Contact Information',
                [
                  if (profile.phone != null)
                    _buildInfoRow('Phone', profile.phone!),
                ],
              ),
              const SizedBox(height: 16),
              if (profile.departmentId != null) ...[
                _buildInfoCard(
                  context,
                  'Academic Information',
                  [
                    _buildInfoRow('Department',
                        '${profile.departmentName} (${profile.departmentCode})'),
                    Consumer(
                      builder: (context, ref, _) {
                        final classesAsync = ref.watch(teacherClassesProvider);
                        return classesAsync.when(
                          data: (classes) {
                            final totalGroups = classes.fold(
                              0,
                              (sum, cls) => sum + cls.groups.length,
                            );
                            return Column(
                              children: [
                                _buildInfoRow(
                                  'Current Classes',
                                  '${classes.length} Active Classes',
                                ),
                                _buildInfoRow(
                                  'Student Groups',
                                  '$totalGroups Groups',
                                ),
                              ],
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (_, __) => const Text('Error loading classes'),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              Consumer(
                builder: (context, ref, _) {
                  final classesAsync = ref.watch(teacherClassesProvider);
                  return classesAsync.when(
                    data: (classes) {
                      if (classes.isEmpty) {
                        return _buildInfoCard(
                          context,
                          'Classes & Groups',
                          [
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No classes assigned yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return _buildInfoCard(
                        context,
                        'Classes & Groups',
                        [
                          for (final cls in classes) ...[
                            _buildClassCard(
                              context,
                              cls.title,
                              cls.groups.map((g) => g.name).join(', '),
                              cls.students,
                            ),
                            if (cls != classes.last) const SizedBox(height: 8),
                          ],
                        ],
                      );
                    },
                    loading: () => _buildInfoCard(
                      context,
                      'Classes & Groups',
                      [
                        const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ),
                    error: (_, __) => _buildInfoCard(
                      context,
                      'Classes & Groups',
                      [
                        const Center(
                          child: Text(
                            'Error loading classes',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TeacherSettingsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(String label, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context,
    String className,
    String groups,
    int studentCount,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          className,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.group, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(groups),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('$studentCount students'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            // TODO: Navigate to class details
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming soon')),
            );
          },
        ),
      ),
    );
  }
}
