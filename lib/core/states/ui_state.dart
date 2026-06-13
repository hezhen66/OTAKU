import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// UI状态（纯Signal，临时状态，不需要持久化）
class UIState {
  static const _bgKey = 'saved_background_path';
  static const _listKey = 'saved_custom_backgrounds';

  // 屏幕与设备
  final screenSplitWidth = signal(480.0);
  final isDesktop = signal(false);
  final navLockedToLeft = signal(false);

  // 导航与交互
  final selectedIndex = signal(0);
  final hoveredIndex = signal<int?>(null);
  final isInBackground = signal(false);

  // 应用名称
  final appName = signal('Astral');

  // 背景图
  final backgroundAsset = signal('assets/backgrounds/bg_main.png');

  // 连接中的房间 ID（隔离不同房间的连接状态）
  final connectingRoomId = signal<int?>(null);

  // 房主索引（转让时更新）
  final hostIndex = signal(0);

  // 房间人数（常态 0/0，创建房间时更新）
  final maxPlayers = signal(0);

  // 下雪特效开关（持久化）
  static const _snowKey = 'snow_enabled';
  final isSnowEnabled = signal(false);

  Future<void> loadSnowEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    isSnowEnabled.value = prefs.getBool(_snowKey) ?? false;
  }

  Future<void> setSnowEnabled(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_snowKey, v);
    isSnowEnabled.value = v;
  }

  // 自定义背景路径列表
  final customBackgrounds = signal<List<String>>([]);

  // 持久化背景路径
  Future<void> loadSavedBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_bgKey);
    if (saved != null && saved.isNotEmpty) {
      backgroundAsset.value = saved;
    }
    final list = prefs.getStringList(_listKey);
    if (list != null) {
      customBackgrounds.value = list;
    }
  }

  Future<void> saveBackgroundPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_bgKey, path);
  }

  Future<void> saveBackgroundList(List<String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_listKey, paths);
  }

  // 简单的状态更新
  void updateScreenWidth(double width) {
    screenSplitWidth.value = width;
    isDesktop.value = width > 480;
  }

  void updateScreenSplitWidth(double width) {
    screenSplitWidth.value = width;
    isDesktop.value = width > 480;
  }

  void selectTab(int index) {
    selectedIndex.value = index;
  }

  void setHovered(int? index) {
    hoveredIndex.value = index;
  }

  void resetHover() {
    hoveredIndex.value = null;
  }

  void setBackground(bool value) {
    isInBackground.value = value;
  }
}
