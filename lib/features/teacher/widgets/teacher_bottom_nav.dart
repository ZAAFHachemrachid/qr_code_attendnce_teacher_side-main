import 'package:flutter/material.dart';

class TeacherBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onSettingsTap;

  const TeacherBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: kBottomNavigationBarHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTap,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              backgroundColor: Colors.transparent,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: [
                _buildNavigationBarItem(Icons.dashboard, 'Dashboard'),
                _buildNavigationBarItem(Icons.calendar_today, 'Schedule'),
                _buildNavigationBarItem(Icons.class_, 'Classes'),
                _buildNavigationBarItem(Icons.person, 'Profile'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: onSettingsTap,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: _Tile(
        icon: icon,
        label: label,
        isSelected: false,
      ),
      activeIcon: _Tile(
        icon: icon,
        label: label,
        isSelected: true,
      ),
      label: '',
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const _Tile({
    required this.icon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.primaryColor : theme.unselectedWidgetColor;

    return SizedBox(
      width: 90.0,
      height: 56.0,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              key: const ValueKey('icon'),
              flex: 3,
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),
            Expanded(
              key: const ValueKey('label'),
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  height: 1.0,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
