import 'package:flutter/material.dart';
import 'navigation_item.dart';
import 'animated_navigation_rail.dart';

class SidebarNavigation extends StatelessWidget {
  final String title;
  final List<NavigationItem> items;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapsed;

  const SidebarNavigation({
    super.key,
    required this.title,
    required this.items,
    this.isCollapsed = false,
    this.onToggleCollapsed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedNavigationRail(
      title: title,
      items: items,
      isCollapsed: isCollapsed,
      onToggleCollapsed: onToggleCollapsed,
    );
  }
}
