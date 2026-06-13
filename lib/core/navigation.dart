import 'package:flutter/material.dart';

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget page;
  final VoidCallback? onTap; // 如果设置，点击时执行而不是切换页面

  const NavigationItem({
    required this.icon,
    IconData? activeIcon,
    required this.label,
    required this.page,
    this.onTap,
  }) : activeIcon = activeIcon ?? icon;
}
