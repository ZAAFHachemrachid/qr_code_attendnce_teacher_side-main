import 'package:flutter/material.dart';

class TeacherSidebarNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const TeacherSidebarNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      extended: isExpanded,
      minExtendedWidth: 200,
      elevation: 2,
      useIndicator: true,
      minWidth: 72,
      groupAlignment: -1, // Align items to top
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(
            isExpanded ? Icons.chevron_left : Icons.chevron_right,
          ),
          onPressed: onExpandToggle,
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home, size: 24),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.timeline, size: 24),
          label: Text('Timeline'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.class_, size: 24),
          label: Text('Class'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people, size: 24),
          label: Text('Students'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person, size: 24),
          label: Text('Profile'),
        ),
      ],
      trailing: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.help, size: 24),
              onPressed: () {
                // TODO: Implement help
                debugPrint('Help pressed');
              },
              tooltip: 'Help',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelType: isExpanded
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
    );
  }
}
