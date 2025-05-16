import 'package:flutter/material.dart';
import 'teacher_bottom_nav.dart';
import 'teacher_sidebar_nav.dart';

class TeacherResponsiveLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;
  final Function(int) onNavigationTap;

  const TeacherResponsiveLayout({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onNavigationTap,
  });

  @override
  State<TeacherResponsiveLayout> createState() =>
      _TeacherResponsiveLayoutState();
}

class _TeacherResponsiveLayoutState extends State<TeacherResponsiveLayout> {
  static const double _breakpoint = 768;

  bool _isSidebarExpanded = true;

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _breakpoint;

        // Desktop layout with sidebar
        if (isDesktop) {
          return Row(
            children: [
              SizedBox(
                width: _isSidebarExpanded ? 240.0 : 72.0,
                child: TeacherSidebarNav(
                  currentIndex: widget.currentIndex,
                  onTap: widget.onNavigationTap,
                  isExpanded: _isSidebarExpanded,
                  onExpandToggle: _toggleSidebar,
                ),
              ),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints.expand(),
                  child: widget.child,
                ),
              ),
            ],
          );
        }

        // Mobile layout with bottom navigation
        return Scaffold(
          body: Container(
            constraints: const BoxConstraints.expand(),
            child: widget.child,
          ),
          bottomNavigationBar: TeacherBottomNav(
            currentIndex: widget.currentIndex,
            onTap: widget.onNavigationTap,
          ),
        );
      },
    );
  }
}
