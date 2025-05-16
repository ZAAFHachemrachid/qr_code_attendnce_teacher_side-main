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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return BottomAppBar(
      height: kBottomNavigationBarHeight + bottomPadding + 16.0,
      padding: EdgeInsets.only(bottom: bottomPadding + 16.0),
      elevation: 8.0,
      shadowColor: theme.colorScheme.primary.withOpacity(0.2),
      surfaceTintColor: theme.colorScheme.surface,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: Colors.transparent,
        selectedFontSize: 12,
        unselectedFontSize: 12,
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
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
        builder: (context, constraints) => SizedBox(
          height: 60.0,
          width: constraints.maxWidth,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isSelected)
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: 4,
                    width: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Icon(
                      widget.icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight:
                          widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                      height: 1.0,
                    ),
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
