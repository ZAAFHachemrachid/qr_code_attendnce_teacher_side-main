import 'package:flutter/material.dart';

class TeacherBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const TeacherBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BottomAppBar(
      height: 101.0, // Reduced height for navigation
      elevation: 4.0,
      shadowColor: theme.colorScheme.primary.withOpacity(0.2),
      surfaceTintColor: theme.colorScheme.surface,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          _buildNavigationBarItem(Icons.home, 'Home', 'Navigate to Home'),
          _buildNavigationBarItem(
              Icons.timeline, 'Timeline', 'Navigate to Timeline'),
          _buildNavigationBarItem(Icons.class_, 'Class', 'Navigate to Class'),
          _buildNavigationBarItem(Icons.people, 'Students', 'View Students'),
          _buildNavigationBarItem(
              Icons.person, 'Profile', 'Navigate to Profile'),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavigationBarItem(
      IconData icon, String label, String semanticLabel) {
    return BottomNavigationBarItem(
      icon: _Tile(
        icon: icon,
        label: label,
        isSelected: false,
        semanticLabel: semanticLabel,
      ),
      activeIcon: _Tile(
        icon: icon,
        label: label,
        isSelected: true,
        semanticLabel: semanticLabel,
      ),
      label: '',
      tooltip: semanticLabel,
    );
  }
}

class _Tile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String semanticLabel;

  const _Tile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.semanticLabel,
  });

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate( // Reduced scale animation
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_Tile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final color = widget.isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withOpacity(0.64);

    return Semantics(
      selected: widget.isSelected,
      label: widget.semanticLabel,
      child: LayoutBuilder(
        builder: (context, constraints) => Container(
          constraints: BoxConstraints(
            minWidth: 56, // Minimum width for touch target
            minHeight: 42, // Adjusted height for new container size
          ),
          width: constraints.maxWidth,
          child: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                widget.icon,
                size: 20,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
