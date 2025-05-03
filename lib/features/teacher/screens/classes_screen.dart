import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import '../providers/teacher_classes_provider.dart';
import 'qr_code_generator_screen.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsyncValue = ref.watch(teacherClassesProvider);
    final currentPeriod = ref.watch(currentAcademicPeriodProvider);
    final periods = ref.watch(academicPeriodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          _buildPeriodSelector(context, ref, currentPeriod),
          Expanded(
            child: classesAsyncValue.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading classes: ${error.toString()}',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(teacherClassesProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (classes) => classes.isEmpty
                  ? Center(
                      child: Text(
                        'No classes found for academic year $currentPeriod',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () =>
                          ref.read(teacherClassesProvider.notifier).refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: classes.length,
                        itemBuilder: (context, index) {
                          final teacherClass = classes[index];
                          return _buildClassCard(
                              context, teacherClass.toClassInfo(), ref);
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    WidgetRef ref,
    String currentPeriod,
  ) {
    final periods = ref.watch(academicPeriodsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          const Text('Academic Year: '),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: currentPeriod,
            items: periods.map((year) {
              return DropdownMenuItem(
                value: year,
                child: Text(
                  year,
                  style: TextStyle(
                    fontWeight: year == DateTime.now().year.toString()
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newPeriod) {
              if (newPeriod != null) {
                ref.read(academicPeriodProvider.notifier).state = newPeriod;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassInfo classInfo,
      [WidgetRef? ref]) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showClassDetails(context, classInfo),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classInfo.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${classInfo.code}',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () {
                      if (ref == null) return;

                      final teacherClass = ref
                          .read(teacherClassesProvider)
                          .value
                          ?.firstWhere(
                            (tc) => tc.id == classInfo.id,
                            orElse: () => throw Exception('Class not found'),
                          );
                      if (teacherClass != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRCodeGeneratorScreen(
                              teacherClass: teacherClass,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 4),
                  Text(classInfo.schedule),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.people, size: 16),
                  const SizedBox(width: 4),
                  Text('${classInfo.students} students'),
                ],
              ),
              if (classInfo.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  classInfo.description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showClassDetails(BuildContext context, ClassInfo classInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClassDetailScreen(classInfo: classInfo),
      ),
    );
  }
}

class ClassDetailScreen extends ConsumerStatefulWidget {
  final ClassInfo classInfo;

  const ClassDetailScreen({super.key, required this.classInfo});

  @override
  ConsumerState<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends ConsumerState<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, Map<String, bool>> _expandedGroups = {
    'TD': {},
    'TP': {},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classInfo.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.classInfo.code,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 16),
                          const SizedBox(width: 4),
                          Text('${widget.classInfo.students} students'),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final teacherClass =
                        ref.read(teacherClassesProvider).value?.firstWhere(
                              (tc) => tc.id == widget.classInfo.id,
                              orElse: () => throw Exception('Class not found'),
                            );
                    if (teacherClass != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QRCodeGeneratorScreen(
                            teacherClass: teacherClass,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Generate QR'),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Course'),
              Tab(text: 'TD'),
              Tab(text: 'TP'),
            ],
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Theme.of(context).colorScheme.outlineVariant,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGroupsTab('Course'),
                _buildGroupsTab('TD'),
                _buildGroupsTab('TP'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab(String type) {
    final groups = widget.classInfo.groups;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$type Groups',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (groups.isEmpty)
            const Center(
              child: Text('No groups found'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  child: ListTile(
                    title: Text(group.name),
                    subtitle: Text(
                      'Year ${group.currentYear}, Section ${group.section}',
                    ),
                    trailing: Text(
                      '${group.studentCount} students',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
