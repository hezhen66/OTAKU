import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/constants/small_window_adapter.dart';
import 'package:astral/core/navigation.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class BottomNav extends StatelessWidget {
  final List<NavigationItem> navigationItems;
  final ColorScheme colorScheme;

  const BottomNav({
    super.key,
    required this.navigationItems,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallWindow = SmallWindowAdapter.shouldApplyAdapter(context);

    return Watch((context) {
      final selectedIndex = ServiceManager().uiState.selectedIndex.value;

      return Container(
        decoration: BoxDecoration(
          color: AppTheme.bgPanel,
          border: Border(top: BorderSide(color: AppTheme.glassBorder)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppTheme.bgPanel,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppTheme.primaryGlow,
          unselectedItemColor: AppTheme.textSecondary,
          showUnselectedLabels: !isSmallWindow,
          selectedFontSize: isSmallWindow ? 10 : 12,
          unselectedFontSize: isSmallWindow ? 8 : 10,
          elevation: 0,
          items: navigationItems
              .map(
                (item) => BottomNavigationBarItem(
                  icon: Icon(item.icon, size: isSmallWindow ? 20 : 24),
                  activeIcon: Icon(item.activeIcon, size: isSmallWindow ? 20 : 24),
                  label: item.label,
                ),
              )
              .toList(),
          currentIndex: selectedIndex,
          onTap: (index) {
            if (navigationItems[index].onTap != null) {
              navigationItems[index].onTap!();
              return;
            }
            ServiceManager().uiState.selectedIndex.value = index;
          },
        ),
      );
    });
  }
}
