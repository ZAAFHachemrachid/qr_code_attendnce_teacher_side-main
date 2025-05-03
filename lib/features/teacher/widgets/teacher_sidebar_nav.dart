import 'package:flutter/material.dart';

class TeacherSidebarNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isExpanded;
  final VoidCallback onExpandToggle;
  final VoidCallback onSettingsTap;

  const TeacherSidebarNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isExpanded,
    required this.onExpandToggle,
    required this.onSettingsTap,
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
          icon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.calendar_today),
          label: Text('Schedule'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.class_),
          label: Text('Classes'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
      trailing: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Spacer(), // Push settings to bottom
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: onSettingsTap,
            ),
            const SizedBox(height: 8),
            IconButton(
              icon: const Icon(Icons.help),
              onPressed: () {
                // TODO: Implement help
                debugPrint('Help pressed');
              },
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
