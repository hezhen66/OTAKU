import 'dart:io';

import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/states/connection_state.dart' show CoState;
import 'package:astral/core/constants/small_window_adapter.dart';
import 'package:astral/shared/widgets/common/windows_controls.dart';
import 'package:astral/shared/widgets/common/theme_selector.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:window_manager/window_manager.dart';

/// HUD 风格顶部状态栏
///
/// 44px 高度，三区布局：
/// - 左：Logo 图片 + "ASTRAL" 文字
/// - 中：连接状态文字 [SYSTEM ONLINE] / [CONNECTING...] / [DISCONNECTED]
/// - 右：主题切换 + 语言切换 + 窗口控制
class StatusBar extends StatelessWidget implements PreferredSizeWidget {
  const StatusBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(AppTheme.statusBarHeight);

  @override
  Widget build(BuildContext context) {
    final bool isSmallWindow = SmallWindowAdapter.shouldApplyAdapter(context);

    // 小窗口简化版
    if (isSmallWindow) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(36),
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1622).withValues(alpha: 0.96),
              border: Border(bottom: BorderSide(color: const Color(0xFF00E5FF).withValues(alpha: 0.55))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Image.asset('assets/logo.png', height: 20, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                const SizedBox(width: 6),
                Text('ASTRAL', style: AppTheme.hudMono(color: AppTheme.primary).copyWith(decoration: TextDecoration.none)),
                const Spacer(),
                _buildThemeColorBtn(context),
              ],
            ),
          ),
        ),
      );
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(AppTheme.statusBarHeight),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onPanStart: (details) {
            if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
              windowManager.startDragging();
            }
          },
          child: Container(
            height: AppTheme.statusBarHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF0F1622).withValues(alpha: 0.96),
              border: Border(bottom: BorderSide(color: const Color(0xFF00E5FF).withValues(alpha: 0.55))),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // ── 左：Logo ──────────────────────
                Image.asset(
                  'assets/logo.png',
                  height: 26,
                  errorBuilder: (_, __, ___) => const Icon(Icons.gamepad, color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 8),
                Text(
                  'OTAKU',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGlow,
                    letterSpacing: 3,
                    decoration: TextDecoration.none,
                  ),
                ),
                const Spacer(),
                // ── 中/右：状态文字 ────────────────
                _buildConnectionStatus(),
                const SizedBox(width: 20),
                // ── 右：控制按钮 ───────────────────
                _buildThemeColorBtn(context),
                const SizedBox(width: 4),
                _buildLanguageSelector(context),
                const SizedBox(width: 4),
                if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
                  const WindowControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GreenDot(),
        SizedBox(width: 8),
        Text(
          'ONLINE',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: kOnlineGreen,
            letterSpacing: 2,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeColorBtn(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.color_lens, size: 18, color: AppTheme.textSecondary),
      onPressed: () => showThemeColorPicker(context),
      tooltip: '主题色',
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      style: IconButton.styleFrom(
        foregroundColor: AppTheme.textSecondary,
        hoverColor: AppTheme.primary.withValues(alpha: 0.1),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: Icon(Icons.language, size: 18, color: AppTheme.textSecondary),
      tooltip: LocaleKeys.language.tr(),
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
      style: IconButton.styleFrom(
        foregroundColor: AppTheme.textSecondary,
      ),
      onSelected: (Locale locale) {
        String langCode = locale.countryCode != null
            ? '${locale.languageCode}_${locale.countryCode}'
            : locale.languageCode;
        ServiceManager().theme.updateLanguage(langCode);
        context.setLocale(locale);
      },
      itemBuilder: (BuildContext context) => [
        _langItem(const Locale('zh'), '简体中文', '🇨🇳'),
        _langItem(const Locale('en'), 'English', '🇺🇸'),
        _langItem(const Locale('ja'), '日本語', '🇯🇵'),
        _langItem(const Locale('ko'), '한국어', '🇰🇷'),
        _langItem(const Locale('ru'), 'Русский', '🇷🇺'),
        _langItem(const Locale('fr'), 'Français', '🇫🇷'),
        _langItem(const Locale('de'), 'Deutsch', '🇩🇪'),
        _langItem(const Locale('es'), 'Español', '🇪🇸'),
      ],
    );
  }

  static const kOnlineGreen = Color(0xFF22CC66);

  PopupMenuItem<Locale> _langItem(Locale locale, String label, String flag) {
    return PopupMenuItem(
      value: locale,
      child: Row(
        children: [
          Text(flag),
          const SizedBox(width: 8),
          Text(label, style: AppTheme.hudBody(fontSize: 13)),
        ],
      ),
    );
  }
}

class _GreenDot extends StatelessWidget {
  const _GreenDot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6, height: 6,
      decoration: BoxDecoration(
        color: StatusBar.kOnlineGreen, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: StatusBar.kOnlineGreen.withValues(alpha: 0.6), blurRadius: 4)],
      ),
    );
  }
}
