import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../../../screens/role_selection_screen.dart';

class RoleGuard extends ConsumerWidget {
  final String requiredRole;
  final Widget child;

  const RoleGuard({
    super.key,
    required this.requiredRole,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userRoleProvider).when(
          data: (role) {
            if (role != requiredRole) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const RoleSelectionScreen(
                      error:
                          'Unauthorized access. Please log in with correct credentials.',
                    ),
                  ),
                );
              });
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return child;
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stackTrace) {
            debugPrint('Role guard error: $error\n$stackTrace');
            return const Scaffold(
              body: Center(
                child: Text('Error verifying role. Please try again.'),
              ),
            );
          },
        );
  }
}
