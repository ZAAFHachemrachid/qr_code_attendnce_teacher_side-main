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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16), // Top padding
          IconButton(
            icon: Icon(
              isExpanded ? Icons.chevron_left : Icons.chevron_right,
              color: colorScheme.onSurface.withOpacity(0.64),
            ),
            onPressed: onExpandToggle,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: NavigationRail(
              extended: isExpanded,
              minExtendedWidth: 200,
              elevation: 2,
              useIndicator: true,
              indicatorColor: colorScheme.primaryContainer,
              minWidth: 72,
              labelType: isExpanded ? null : NavigationRailLabelType.selected,
              groupAlignment: -0.2, // Slightly move up to account for bottom space
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
              trailing: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: IconButton(
                  icon: Icon(
                    Icons.help,
                    size: 24,
                    color: colorScheme.onSurface.withOpacity(0.64),
                  ),
                  onPressed: () {
                    // TODO: Implement help
                    debugPrint('Help pressed');
                  },
                  tooltip: 'Help',
                ),
              ),
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              selectedLabelTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
              unselectedLabelTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurface.withOpacity(0.64),
              ),
              selectedIconTheme: IconThemeData(
                size: 24,
                color: colorScheme.primary,
              ),
              unselectedIconTheme: IconThemeData(
                size: 24,
                color: colorScheme.onSurface.withOpacity(0.64),
              ),
              backgroundColor: colorScheme.surface,
            ),
          ),
          const SizedBox(height: 16), // Bottom padding
        ],
      ),
    );
  }
}
