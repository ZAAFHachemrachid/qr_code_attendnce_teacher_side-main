import 'package:flutter/material.dart';
import 'enhanced_student_card.dart';

enum SortOption {
  name('Name', Icons.sort_by_alpha),
  id('ID', Icons.tag),
  group('Group', Icons.group),
  attendance('Attendance', Icons.percent);

  final String label;
  final IconData icon;
  const SortOption(this.label, this.icon);
}

class FilterOptions {
  final double? minAttendance;
  final String? groupFilter;
  final String? statusFilter;

  const FilterOptions({
    this.minAttendance,
    this.groupFilter,
    this.statusFilter,
  });
}

enum StudentViewMode {
  list,
  grid,
  compact;

  IconData get icon {
    switch (this) {
      case StudentViewMode.list:
        return Icons.view_list;
      case StudentViewMode.grid:
        return Icons.grid_view;
      case StudentViewMode.compact:
        return Icons.view_headline;
    }
  }

  String get label {
    switch (this) {
      case StudentViewMode.list:
        return 'List';
      case StudentViewMode.grid:
        return 'Grid';
      case StudentViewMode.compact:
        return 'Compact';
    }
  }
}

class EnhancedStudentView extends StatefulWidget {
  final List<StudentData> students;
  final void Function(StudentData)? onStudentTap;
  final void Function(List<StudentData>)? onSelectionChange;
  final bool enableMultiSelect;
  final void Function(String, StudentData)? onActionSelected;

  const EnhancedStudentView({
    super.key,
    required this.students,
    this.onStudentTap,
    this.onSelectionChange,
    this.enableMultiSelect = false,
    this.onActionSelected,
  });

  @override
  State<EnhancedStudentView> createState() => _EnhancedStudentViewState();
}

class _EnhancedStudentViewState extends State<EnhancedStudentView> {
  StudentViewMode _currentViewMode = StudentViewMode.list;
  final Set<String> _selectedStudentIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  SortOption _currentSort = SortOption.name;
  bool _sortAscending = true;
  FilterOptions _filterOptions = const FilterOptions();

  // Get unique group names for filter dropdown
  List<String> get _uniqueGroups =>
      widget.students.map((s) => s.groupName).toSet().toList()..sort();

  List<StudentData> get _filteredAndSortedStudents {
    List<StudentData> students = widget.students;

    // Apply filters
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      students = students.where((student) {
        return student.name.toLowerCase().contains(query) ||
            student.id.toLowerCase().contains(query) ||
            student.groupName.toLowerCase().contains(query) ||
            (student.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (_filterOptions.minAttendance != null) {
      students = students
          .where((s) => s.attendanceRate >= _filterOptions.minAttendance!)
          .toList();
    }

    if (_filterOptions.groupFilter != null) {
      students = students
          .where((s) => s.groupName == _filterOptions.groupFilter)
          .toList();
    }

    if (_filterOptions.statusFilter != null) {
      students = students
          .where((s) => s.status == _filterOptions.statusFilter)
          .toList();
    }

    // Apply sorting
    students.sort((a, b) {
      int comparison;
      switch (_currentSort) {
        case SortOption.name:
          comparison = a.name.compareTo(b.name);
          break;
        case SortOption.id:
          comparison = a.id.compareTo(b.id);
          break;
        case SortOption.group:
          comparison = a.groupName.compareTo(b.groupName);
          break;
        case SortOption.attendance:
          comparison = a.attendanceRate.compareTo(b.attendanceRate);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return students;
  }

  void _toggleStudentSelection(String studentId) {
    setState(() {
      if (_selectedStudentIds.contains(studentId)) {
        _selectedStudentIds.remove(studentId);
      } else {
        _selectedStudentIds.add(studentId);
      }
      widget.onSelectionChange?.call(
        widget.students
            .where((s) => _selectedStudentIds.contains(s.id))
            .toList(),
      );
    });
  }

  void _handleStudentTap(StudentData student) {
    if (widget.enableMultiSelect) {
      _toggleStudentSelection(student.id);
    } else {
      widget.onStudentTap?.call(student);
    }
  }

  Widget _buildToolbar() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // View mode selector
                ...StudentViewMode.values.map((mode) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: IconButton(
                      onPressed: () => setState(() => _currentViewMode = mode),
                      icon: Icon(mode.icon),
                      color: _currentViewMode == mode
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      tooltip: mode.label,
                    ),
                  );
                }),
                const Spacer(),
                // Sort options
                DropdownButton<SortOption>(
                  value: _currentSort,
                  items: SortOption.values.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(option.icon, size: 20),
                          const SizedBox(width: 8),
                          Text(option.label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        if (_currentSort == value) {
                          _sortAscending = !_sortAscending;
                        } else {
                          _currentSort = value;
                          _sortAscending = true;
                        }
                      });
                    }
                  },
                ),
                IconButton(
                  icon: Icon(_sortAscending
                      ? Icons.arrow_upward
                      : Icons.arrow_downward),
                  onPressed: () =>
                      setState(() => _sortAscending = !_sortAscending),
                  tooltip: _sortAscending ? 'Ascending' : 'Descending',
                ),
                const SizedBox(width: 8),
                // Filter button
                PopupMenuButton<void>(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filter',
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        title: const Text('Group'),
                        trailing: DropdownButton<String?>(
                          value: _filterOptions.groupFilter,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All'),
                            ),
                            ..._uniqueGroups.map(
                              (group) => DropdownMenuItem(
                                value: group,
                                child: Text(group),
                              ),
                            ),
                          ],
                          onChanged: (value) => setState(() {
                            _filterOptions = FilterOptions(
                              groupFilter: value,
                              minAttendance: _filterOptions.minAttendance,
                              statusFilter: _filterOptions.statusFilter,
                            );
                          }),
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        title: const Text('Min. Attendance'),
                        trailing: DropdownButton<double?>(
                          value: _filterOptions.minAttendance,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All'),
                            ),
                            ...([75.0, 80.0, 85.0, 90.0, 95.0].map(
                              (rate) => DropdownMenuItem(
                                value: rate,
                                child: Text('≥ $rate%'),
                              ),
                            )),
                          ],
                          onChanged: (value) => setState(() {
                            _filterOptions = FilterOptions(
                              groupFilter: _filterOptions.groupFilter,
                              minAttendance: value,
                              statusFilter: _filterOptions.statusFilter,
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search students...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildStudentList() {
    final students = _filteredAndSortedStudents;

    switch (_currentViewMode) {
      case StudentViewMode.grid:
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return EnhancedStudentCard(
              student: student,
              onTap: () => _handleStudentTap(student),
              isSelected: _selectedStudentIds.contains(student.id),
              onActionSelected: widget.onActionSelected != null
                  ? (action) => widget.onActionSelected!(action, student)
                  : null,
            );
          },
        );

      case StudentViewMode.compact:
        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: EnhancedStudentCard(
                student: student,
                onTap: () => _handleStudentTap(student),
                isSelected: _selectedStudentIds.contains(student.id),
                isCompact: true,
                onActionSelected: widget.onActionSelected != null
                    ? (action) => widget.onActionSelected!(action, student)
                    : null,
              ),
            );
          },
        );

      case StudentViewMode.list:
      default:
        return ListView.builder(
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: EnhancedStudentCard(
                student: student,
                onTap: () => _handleStudentTap(student),
                isSelected: _selectedStudentIds.contains(student.id),
                onActionSelected: widget.onActionSelected != null
                    ? (action) => widget.onActionSelected!(action, student)
                    : null,
              ),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        _buildToolbar(),
        if (_selectedStudentIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_selectedStudentIds.length} selected',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                // Batch action buttons
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    // TODO: Implement batch messaging
                  },
                  tooltip: 'Message Selected',
                ),
                IconButton(
                  icon: const Icon(Icons.group),
                  onPressed: () {
                    // TODO: Implement batch group assignment
                  },
                  tooltip: 'Assign to Group',
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => setState(() => _selectedStudentIds.clear()),
                  child: const Text('Clear Selection'),
                ),
              ],
            ),
          ),
        Expanded(
          child: _buildStudentList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
