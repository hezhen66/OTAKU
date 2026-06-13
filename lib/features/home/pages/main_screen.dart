import 'dart:io';

import 'package:astral/shared/utils/dialogs/add_room_dialog.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/states/connection_state.dart' show CoState;
import 'package:astral/features/home/pages/home_page.dart';
import 'package:astral/features/rooms/pages/room_page.dart';
import 'package:astral/features/rooms/pages/connected_room_page.dart';
import 'package:astral/features/explore/pages/explore_page.dart';
import 'package:astral/features/settings/pages/settings_main_page.dart';
import 'package:astral/shared/widgets/hud/hud_scaffold.dart';
import 'package:astral/shared/widgets/hud/hud_toast.dart';
import 'package:astral/shared/widgets/hud/snow_effect.dart';
import 'package:astral/core/states/connection_state.dart' show SystemEventType;
import 'package:flutter/material.dart';
import 'package:astral/core/navigation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, WindowListener {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.addListener(this);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      ServiceManager().uiState.updateScreenSplitWidth(screenWidth);
    });

    // 自动更新检查已禁用
  }

  @override
  void dispose() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      windowManager.removeListener(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setAppBackground(bool isInBackground) {
    if (ServiceManager().uiState.isInBackground.value != isInBackground) {
      ServiceManager().uiState.setBackground(isInBackground);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _setAppBackground(false);
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _setAppBackground(true);
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    ServiceManager().uiState.updateScreenSplitWidth(screenWidth);

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void onWindowMinimize() => _setAppBackground(true);

  @override
  void onWindowBlur() => _setAppBackground(true);

  @override
  void onWindowRestore() => _setAppBackground(false);

  @override
  void onWindowFocus() => _setAppBackground(false);

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final connState = ServiceManager().connectionState.connectionState.watch(context);
      final isConnected = connState == CoState.connected;
      final currentIndex = ServiceManager().uiState.selectedIndex.value;

      final items = [
        NavigationItem(icon: Icons.gamepad, activeIcon: Icons.gamepad, label: '主页', page: const HomePage()),
        NavigationItem(icon: Icons.add_circle_outline, activeIcon: Icons.add_circle_outline, label: '创建房间',
            page: const SizedBox.shrink(), onTap: () => showAddRoomDialog(context)),
        NavigationItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_outlined, label: '浏览房间', page: const RoomPage()),
        if (isConnected)
          NavigationItem(icon: Icons.link, activeIcon: Icons.link, label: '联机房间', page: const ConnectedRoomPage()),
        NavigationItem(icon: Icons.build_outlined, activeIcon: Icons.build_outlined, label: '联机工具', page: const ExplorePage()),
        NavigationItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_outlined, label: '设置', page: const SettingsMainPage()),
      ];
      final pages = items.map((i) => i.page).toList();
      final itemCount = items.length;

      if (currentIndex >= itemCount && itemCount > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (ServiceManager().uiState.selectedIndex.value >= itemCount) {
            ServiceManager().uiState.selectedIndex.value = 0;
          }
        });
      }

      final safeIndex = (currentIndex >= 0 && currentIndex < itemCount) ? currentIndex : 0;

      final showSnow = ServiceManager().uiState.isSnowEnabled.watch(context);
      final sysEvent = ServiceManager().connectionState.systemEvent.watch(context);
      // 系统事件 → Toast
      if (sysEvent != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final e = sysEvent!;
          switch (e.type) {
            case SystemEventType.kicked:
              final msg = e.message ?? '';
              if (msg.startsWith('inherit:')) {
                HudToast.hostTransferred(context, msg.substring(9));
              } else {
                HudToast.kicked(context, by: msg.isNotEmpty ? msg : null);
              }
            case SystemEventType.roomFull:
              HudToast.roomFull(context);
            case SystemEventType.disconnected:
              HudToast.disconnected(context);
            case SystemEventType.reconnecting:
              HudToast.reconnecting(context);
            case SystemEventType.reconnected:
              HudToast.reconnected(context);
          }
          ServiceManager().connectionState.systemEvent.value = null; // 消费
        });
      }

      return Stack(
        children: [
          HUDScaffold(
            items: items,
            currentIndex: safeIndex,
            onTabChanged: (index) => ServiceManager().uiState.selectedIndex.value = index,
            child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: IndexedStack(key: ValueKey(safeIndex), index: safeIndex, children: pages),
        ),
      ),
      if (showSnow) const SnowEffect(),
    ]);
    });
  }
}
