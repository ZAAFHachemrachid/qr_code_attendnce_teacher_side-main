import 'package:flutter/material.dart';

class NavigationItem {
  final String title;
  final IconData icon;
  final Function()? onTap;
  final bool isSelected;

  const NavigationItem({
    required this.title,
    required this.icon,
    this.onTap,
    this.isSelected = false,
  });

  String get label => title;

  NavigationItem copyWith({
    String? title,
    IconData? icon,
    Function()? onTap,
    bool? isSelected,
  }) {
    return NavigationItem(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      onTap: onTap ?? this.onTap,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
