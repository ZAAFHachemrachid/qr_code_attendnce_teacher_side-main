import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course.dart';
import '../providers/academic_period_provider.dart';
import '../providers/teacher_classes_provider.dart';
import 'qr_code_generator_screen.dart';
import '../../../core/widgets/skeleton_container.dart';

class ClassesScreen extends ConsumerWidget {
  const ClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsyncValue = ref.watch(teacherClassesProvider);
    final currentPeriod = ref.watch(currentAcademicPeriodProvider);
    final periods = ref.watch(academicPeriodsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Classes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildPeriodSelector(context, ref, currentPeriod),
          Expanded(
            child: classesAsyncValue.when(
              loading: () => ListView.builder(
                itemCount: 3,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) => _buildSkeletonCard(context),
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
                        ref
                            .read(teacherClassesProvider.notifier)
                            .refreshClasses();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (classes) => classes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 64,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Classes Found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No classes available for academic year $currentPeriod',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => ref
                                .read(teacherClassesProvider.notifier)
                                .refreshClasses(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(teacherClassesProvider.notifier)
                          .refreshClasses(),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Academic Year',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: currentPeriod,
            items: periods.map((year) {
              return DropdownMenuItem(
                value: year,
                child: Text(
                  year,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: year == DateTime.now().year.toString()
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
            onChanged: (newPeriod) {
              if (newPeriod != null) {
                ref.read(currentAcademicPeriodProvider.notifier).state =
                    newPeriod;
              }
            },
            underline: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonContainer(width: 200, height: 20),
          const SizedBox(height: 8),
          Row(
            children: [
              const SkeletonContainer(width: 100, height: 16),
              const SizedBox(width: 16),
              const SkeletonContainer(width: 80, height: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ClassInfo classInfo,
      [WidgetRef? ref]) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showClassDetails(context, classInfo),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${classInfo.code} - ${classInfo.title}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (ref != null) ...[
                    IconButton(
                      icon: const Icon(Icons.qr_code, size: 20),
                      onPressed: () {
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
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Semester ${classInfo.semester}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${classInfo.creditHours} Credits',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (classInfo.schedule.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  classInfo.schedule,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ClassDetailScreen(classInfo: classInfo),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.05, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
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

  Widget _buildDetailRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color:
              Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimaryContainer
                  .withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.classInfo.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.classInfo.code,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withOpacity(0.8),
                      ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                    Icons.description_outlined, widget.classInfo.description),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(Icons.school_outlined,
                          'Year ${widget.classInfo.yearOfStudy}, Semester ${widget.classInfo.semester}'),
                    ),
                    Expanded(
                      child: _buildDetailRow(Icons.timer_outlined,
                          '${widget.classInfo.creditHours} Credit Hours'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(Icons.groups_outlined,
                          '${widget.classInfo.students} Students'),
                    ),
                    Expanded(
                      child: _buildDetailRow(Icons.category_outlined,
                          widget.classInfo.type.name.toUpperCase()),
                    ),
                  ],
                ),
                if (widget.classInfo.schedule.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      Icons.calendar_today_outlined, widget.classInfo.schedule),
                ],
                const SizedBox(height: 16),
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
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (type == 'Course')
            Text(
              'Master class for ${widget.classInfo.code}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
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
