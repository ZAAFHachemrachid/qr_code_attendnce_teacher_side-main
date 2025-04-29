import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
      leading: IconButton(
        icon: Icon(
          isExpanded ? Icons.chevron_left : Icons.chevron_right,
        ),
        onPressed: onExpandToggle,
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
      trailing: Column(
        children: [
          Expanded(child: SizedBox()), // Push settings to bottom
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: onSettingsTap,
          ),
          IconButton(
            icon: Icon(Icons.help),
            onPressed: () {
              // TODO: Implement help
              debugPrint('Help pressed');
            },
          ),
          SizedBox(height: 8),
        ],
      ),
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelType: isExpanded
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.selected,
    );
  }
}
