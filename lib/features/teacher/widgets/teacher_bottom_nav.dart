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

    // Navigation items data
    final items = [
      (Icons.home, 'Home', 'Navigate to Home'),
      (Icons.timeline, 'Timeline', 'Navigate to Timeline'),
      (Icons.class_, 'Class', 'Navigate to Class'),
      (Icons.people, 'Students', 'View Students'),
      (Icons.person, 'Profile', 'Navigate to Profile'),
    ];

    return BottomAppBar(
      height: 72.0,
      elevation: 2.0,
      shadowColor: theme.colorScheme.primary.withOpacity(0.1),
      surfaceTintColor: theme.colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final (icon, label, semanticLabel) = items[index];
          return Expanded(
            child: Center(
              child: _Tile(
                icon: icon,
                label: label,
                isSelected: currentIndex == index,
                semanticLabel: semanticLabel,
                onTap: () => onTap(index),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _Tile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final String semanticLabel;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.semanticLabel,
    required this.onTap,
  });

  @override
  State<_Tile> createState() => _TileState();
}

class _TileState extends State<_Tile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  final GlobalKey _iconKey = GlobalKey();
  bool _isTapWithinBounds = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
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

  bool _isWithinIconBounds(Offset localPosition) {
    if (_iconKey.currentContext == null) return false;
    final RenderBox iconBox =
        _iconKey.currentContext!.findRenderObject() as RenderBox;
    final Size iconSize = iconBox.size;

    // Use 24x24 hit target while keeping visual size at 18x18
    const hitTargetSize = 24.0;
    return localPosition.dx >= (iconSize.width - hitTargetSize) / 2 &&
        localPosition.dx <= (iconSize.width + hitTargetSize) / 2 &&
        localPosition.dy >= (iconSize.height - hitTargetSize) / 2 &&
        localPosition.dy <= (iconSize.height + hitTargetSize) / 2;
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
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  final RenderBox? box =
                      _iconKey.currentContext?.findRenderObject() as RenderBox?;
                  if (box != null) {
                    final Offset center = box.size.center(Offset.zero);
                    _isTapWithinBounds = _isWithinIconBounds(center);
                    if (_isTapWithinBounds) {
                      widget.onTap();
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Icon(
                      key: _iconKey,
                      widget.icon,
                      size: 18,
                      color: color,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.isSelected)
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Center(
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
