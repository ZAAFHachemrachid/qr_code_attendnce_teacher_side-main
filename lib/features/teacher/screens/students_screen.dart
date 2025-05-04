import 'package:flutter/material.dart';
import '../../student/screens/student_profile_screen.dart';
import '../widgets/enhanced_student_view.dart';
import '../widgets/enhanced_student_card.dart';
import 'attendance_history_sheet.dart';

class StudentDetailsSheet extends StatelessWidget {
  final StudentData student;

  const StudentDetailsSheet({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                child: Text(
                  student.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      'ID: ${student.id}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(context, 'Email', student.email ?? 'Not set'),
          _buildInfoRow(context, 'Group', student.groupName),
          _buildInfoRow(
              context, 'Attendance', '${student.attendanceRate.toInt()}%'),
          _buildInfoRow(context, 'Status', student.status.toUpperCase()),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                context,
                Icons.message,
                'Message',
                () {
                  Navigator.pop(context);
                  // TODO: Implement messaging
                },
              ),
              _buildActionButton(
                context,
                Icons.edit,
                'Edit',
                () {
                  Navigator.pop(context);
                  // TODO: Implement edit
                },
              ),
              _buildActionButton(
                context,
                Icons.event_note,
                'Attendance',
                () {
                  Navigator.pop(context);
                  // TODO: Show attendance history
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class AddStudentDialog extends StatefulWidget {
  const AddStudentDialog({super.key});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedGroup = 'Group 1';

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Student'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGroup,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  border: OutlineInputBorder(),
                ),
                items: ['Group 1', 'Group 2', 'Group 3', 'Group 4']
                    .map((group) => DropdownMenuItem(
                          value: group,
                          child: Text(group),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedGroup = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                StudentData(
                  id: _idController.text,
                  name: _nameController.text,
                  email: _emailController.text.isEmpty
                      ? null
                      : _emailController.text,
                  groupName: _selectedGroup,
                  attendanceRate: 100, // Default for new students
                ),
              );
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

enum BatchAction {
  message('Message', Icons.message),
  changeGroup('Change Group', Icons.group),
  markAttendance('Mark Attendance', Icons.event_note),
  export('Export Data', Icons.download);

  final String label;
  final IconData icon;
  const BatchAction(this.label, this.icon);
}

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<StudentData> _selectedStudents = [];

  // Sample student data
  final List<StudentData> _students = List.generate(
    20,
    (index) => StudentData(
      id: 'S${index + 1000}',
      name: 'Student ${index + 1}',
      email: 'student${index + 1}@example.com',
      groupName: 'Group ${(index % 4) + 1}',
      attendanceRate: (70 + (index % 30)).toDouble(),
      status: index % 5 == 0 ? 'inactive' : 'active',
    ),
  );

  void _handleStudentTap(StudentData student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileScreen(
          studentData: student,
        ),
      ),
    );
  }

  void _handleQuickAction(String action, StudentData student) {
    switch (action) {
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudentProfileScreen(
              studentData: student,
            ),
          ),
        );
        break;
      case 'message':
        _showMessageDialog([student]);
        break;
      case 'attendance':
        _showAttendanceHistory(student);
        break;
    }
  }

  void _showAttendanceHistory(StudentData student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: AttendanceHistorySheet(student: student),
      ),
    );
  }

  void _showMessageDialog(List<StudentData> students) {
    final recipientText = students.length == 1
        ? students.first.name
        : '${students.length} students';

    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message to $recipientText'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Type your message here...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This message will be sent to ${students.length} student(s)',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final message = messageController.text;
              if (message.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a message'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              // TODO: Implement actual message sending
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Message sent to ${students.length} student(s)',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    ).then((_) => messageController.dispose());
  }

  void _handleSelectionChange(List<StudentData> selectedStudents) {
    setState(() {
      _selectedStudents = selectedStudents;
    });
  }

  Future<void> _showAddStudentDialog() async {
    final result = await showDialog<StudentData>(
      context: context,
      builder: (context) => const AddStudentDialog(),
    );

    if (result != null) {
      setState(() {
        _students.add(result);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully')),
        );
      }
    }
  }

  void _handleBatchAction(BatchAction action) {
    switch (action) {
      case BatchAction.message:
        _showMessageDialog(_selectedStudents);
        break;
      case BatchAction.changeGroup:
        _showChangeGroupDialog(_selectedStudents);
        break;
      case BatchAction.markAttendance:
        _showBatchAttendanceDialog(_selectedStudents);
        break;
      case BatchAction.export:
        _exportStudentData(_selectedStudents);
        break;
    }
  }

  void _showChangeGroupDialog(List<StudentData> students) {
    // TODO: Implement group change dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Group change coming soon')),
    );
  }

  void _showBatchAttendanceDialog(List<StudentData> students) {
    // TODO: Implement batch attendance marking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Batch attendance coming soon')),
    );
  }

  void _exportStudentData(List<StudentData> students) {
    // TODO: Implement data export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          if (_selectedStudents.isNotEmpty)
            PopupMenuButton<BatchAction>(
              icon: const Icon(Icons.more_vert),
              tooltip: 'Batch Actions',
              itemBuilder: (context) => BatchAction.values
                  .map(
                    (action) => PopupMenuItem(
                      value: action,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(action.icon),
                          const SizedBox(width: 8),
                          Text(action.label),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onSelected: _handleBatchAction,
            ),
        ],
      ),
      body: EnhancedStudentView(
        students: _students,
        onStudentTap: _handleStudentTap,
        onSelectionChange: _handleSelectionChange,
        enableMultiSelect: true,
        onActionSelected: _handleQuickAction,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddStudentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
