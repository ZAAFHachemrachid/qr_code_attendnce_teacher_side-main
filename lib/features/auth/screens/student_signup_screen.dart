import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/department.dart';
import '../models/student_group.dart';
import '../providers/auth_provider.dart';
import '../providers/department_providers.dart';

class StudentSignupScreen extends ConsumerStatefulWidget {
  const StudentSignupScreen({super.key});

  @override
  ConsumerState<StudentSignupScreen> createState() =>
      _StudentSignupScreenState();
}

class _StudentSignupScreenState extends ConsumerState<StudentSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _studentNumberController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    final selectedGroup = ref.read(selectedGroupProvider);
    if (selectedGroup == null) {
      setState(() {
        _error = 'Please select a group';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(authServiceProvider).signUpStudent(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            studentNumber: _studentNumberController.text.trim(),
            groupId: selectedGroup.id,
          );

      if (mounted) {
        Navigator.of(context).pop(); // Return to login screen
      }
    } on AuthException catch (error) {
      setState(() {
        _error = error.message;
      });
    } catch (error) {
      setState(() {
        _error = 'An unexpected error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDepartmentDropdown() {
    final departments = ref.watch(departmentsProvider);
    final selectedDepartment = ref.watch(selectedDepartmentProvider);

    return departments.when(
      data: (depts) => DropdownButtonFormField<Department>(
        value: selectedDepartment,
        decoration: const InputDecoration(
          labelText: 'Department',
          border: OutlineInputBorder(),
        ),
        items: depts.map((dept) {
          return DropdownMenuItem<Department>(
            value: dept,
            child: Text('${dept.code} - ${dept.name}'),
          );
        }).toList(),
        onChanged: (value) {
          ref.read(selectedDepartmentProvider.notifier).state = value;
          // Clear selected group when department changes
          ref.read(selectedGroupProvider.notifier).state = null;
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a department';
          }
          return null;
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Failed to load departments'),
    );
  }

  Widget _buildGroupDropdown() {
    final selectedDepartment = ref.watch(selectedDepartmentProvider);
    final groups = ref.watch(
      studentGroupsProvider(selectedDepartment?.id),
    );
    final selectedGroup = ref.watch(selectedGroupProvider);

    return groups.when(
      data: (groupList) => DropdownButtonFormField<StudentGroup>(
        value: selectedGroup,
        decoration: const InputDecoration(
          labelText: 'Student Group',
          border: OutlineInputBorder(),
        ),
        items: groupList.map((group) {
          return DropdownMenuItem<StudentGroup>(
            value: group,
            child: Text(group.displayName),
          );
        }).toList(),
        onChanged: (value) {
          ref.read(selectedGroupProvider.notifier).state = value;
        },
        validator: (value) {
          if (value == null) {
            return 'Please select a group';
          }
          return null;
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Text('Failed to load student groups'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Signup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _studentNumberController,
                decoration: const InputDecoration(
                  labelText: 'Student Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Student number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildDepartmentDropdown(),
              const SizedBox(height: 16),
              _buildGroupDropdown(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                  );
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6AB19B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
