import 'package:astral/shared/widgets/hud/hud_background.dart';
import 'package:astral/shared/widgets/hud/player_list_panel.dart';
import 'package:astral/shared/widgets/navigation/left_nav.dart';
import 'package:astral/shared/widgets/navigation/bottom_nav.dart';
import 'package:astral/shared/widgets/common/status_bar.dart';
import 'package:astral/core/navigation.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/constants/small_window_adapter.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HUDScaffold extends StatelessWidget {
  final List<NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final Widget child;

  const HUDScaffold({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTabChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
        final width = MediaQuery.of(context).size.width;
        final showLeft = width >= 900;
        final isSmallWindow = SmallWindowAdapter.shouldApplyAdapter(context);

        return Watch((context) {
          final bgAsset = ServiceManager().uiState.backgroundAsset.watch(context);
          return HUDScaffoldBackground(
            backgroundAsset: bgAsset,
            child: Column(
              children: [
                if (!isSmallWindow) const StatusBar(),
                Expanded(
                  child: Row(
                    children: [
                      if (showLeft && !isSmallWindow)
                        LeftNav(items: items, colorScheme: Theme.of(context).colorScheme),
                      Expanded(
                        child: Container(
                          color: const Color(0xFF0F1622).withValues(alpha: 0.35),
                          child: child,
                        ),
                      ),
                      if (showLeft && !isSmallWindow) const PlayerListPanel(),
                    ],
                  ),
                ),
                if (!showLeft || isSmallWindow)
                  BottomNav(navigationItems: items, colorScheme: Theme.of(context).colorScheme),
              ],
            ),
          );
        });
  }
}
