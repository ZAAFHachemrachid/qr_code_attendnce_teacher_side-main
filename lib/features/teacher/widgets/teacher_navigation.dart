import 'package:flutter/material.dart';

class TeacherNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const TeacherNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExpanded ? 240 : 72,
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
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              children: [
                _buildNavItem(
                  context: context,
                  icon: Icons.home,
                  label: 'Home',
                  tooltip: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.timeline,
                  label: 'Timeline',
                  tooltip: 'Timeline',
                  index: 1,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.class_,
                  label: 'Classes',
                  tooltip: 'Manage Classes',
                  index: 2,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.people,
                  label: 'Students',
                  tooltip: 'View Students',
                  index: 3,
                ),
                _buildNavItem(
                  context: context,
                  icon: Icons.person,
                  label: 'Profile',
                  tooltip: 'Profile & Help',
                  index: 4,
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isExpanded) ...[
            Text(
              'Navigation',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
          ],
          IconButton(
            icon: Icon(
              isExpanded ? Icons.chevron_left : Icons.chevron_right,
              size: 20,
            ),
            onPressed: onExpandToggle,
            tooltip: isExpanded ? 'Collapse' : 'Expand',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String tooltip,
    required int index,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = currentIndex == index;

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primaryContainer
                  : isHovered
                      ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: Tooltip(
                message: !isExpanded ? tooltip : '',
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onDestinationSelected(index),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: isExpanded ? 10 : 14,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 24,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        if (isExpanded) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(BuildContext context) {
    return const SizedBox(height: 8);
  }
}