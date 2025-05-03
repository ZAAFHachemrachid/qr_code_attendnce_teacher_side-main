import 'package:flutter/material.dart';
import '../../features/theme/theme_constants.dart';

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<String> tabs;
  final List<IconData>? icons;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.icons,
  }) : assert(icons == null || icons.length == tabs.length);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      tabs: List.generate(
        tabs.length,
        (index) => Tab(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: 1.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icons != null) ...[
                  Icon(icons![index], size: 18),
                  const SizedBox(width: 8),
                ],
                Text(tabs[index]),
              ],
            ),
          ),
        ),
      ),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        color: AppTheme.colorScheme.primaryContainer,
      ),
      splashBorderRadius: BorderRadius.circular(AppTheme.borderRadius),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
      tabAlignment: TabAlignment.center,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
