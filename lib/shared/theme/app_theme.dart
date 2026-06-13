import 'package:flutter/material.dart';

/// Astral HUD Sci-Fi Theme — 固定配色系统
///
/// 取代 Material 3 的 colorSchemeSeed 动态配色，
/// 锁定 AAA 游戏联机大厅 / 机甲控制台风格。
class AppTheme {
  AppTheme._();

  // ── 背景 ──────────────────────────────────────
  static const Color bgDark = Color(0xFF050B15);
  static const Color bgPanel = Color(0xD90F1622); // 85% 战术深青黑
  static const Color bgPanelLight = Color(0xB30F1D35);

  // ── 主色（青色系）────────────────────────────
  static const Color primary = Color(0xFF00D8FF);
  static const Color primaryGlow = Color(0xFF31F0FF);
  static const Color primaryDim = Color(0xFF0088AA);

  // ── 文字 ──────────────────────────────────────
  static const Color textPrimary = Color(0xFFE6F7FF);
  static const Color textSecondary = Color(0x99E6F7FF); // rgba(230,247,255,0.6)

  // ── 边框 ──────────────────────────────────────
  static const Color borderCyan = Color(0x5500FFFF); // ~33% 青色
  static const Color borderGlow = Color(0xAA00FFFF);

  // ── 磨砂玻璃 ──────────────────────────────────
  static const Color glassBg = Color(0x990A1622); // 60% 浏览房间同色
  static const Color cardBorder = Color(0xFF1E2D3D); // 冷色边框
  static const Color glassBorder = Color(0x33FFFFFF); // 20% 白边
  static const Color subtleDivider = Color(0x261A3A4B); // ~15% 暗青蓝，若隐若现

  // ── UI 常量 ───────────────────────────────────
  static const double leftNavWidth = 68.0;
  static const double rightPanelWidth = 240.0;
  static const double statusBarHeight = 44.0;
  static const double panelRadius = 4.0;
  static const double glassBlurSigma = 10.0;
  static const double cornerLength = 12.0;
  static const double cornerStroke = 1.5;

  // ── HUD 文字样式 ──────────────────────────────

  /// 正文：中文 / 混排（MiSans，所有 UI 内容默认用这个）
  static TextStyle hudBody({Color? color, double? fontSize}) => TextStyle(
    fontFamily: 'MiSans',
    fontSize: fontSize ?? 14,
    fontWeight: FontWeight.w400,
    color: color ?? textPrimary,
    height: 1.5,
  );

  /// 大标题：英文科技风 — 纤细、宽字距、扁平
  static TextStyle hudTitle({Color? color}) => TextStyle(
    fontFamily: 'Orbitron',
    fontFamilyFallback: const ['MiSans'],
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: color ?? primary,
    letterSpacing: 2.5,
    height: 1.0,
  );

  /// 区块标签：英文宽字距 — 极细、极限字距
  static TextStyle hudLabel({Color? color}) => TextStyle(
    fontFamily: 'Orbitron',
    fontFamilyFallback: const ['MiSans'],
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: color ?? textSecondary,
    letterSpacing: 2.5,
    height: 1.0,
  );

  /// 科技等宽：英文数字
  /// 科技等宽：英文数字 — 纤细、扁平
  static TextStyle hudMono({Color? color}) => TextStyle(
    fontFamily: 'Orbitron',
    fontFamilyFallback: const ['MiSans'],
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? primary,
    letterSpacing: 2.0,
    height: 1.0,
  );

  // ── 生成 Material ThemeData ────────────────────

  /// 根据选中主题色生成 ThemeData
  static ThemeData build(Color accent) =>
      _buildTheme(Brightness.dark, bgDark, bgPanel, accent);

  /// 暗色 HUD 主题（主用）
  static ThemeData get hudDark => _buildTheme(Brightness.dark, bgDark, bgPanel, primary);

  /// 亮色 HUD 主题（暗基调中稍亮）
  static ThemeData get hudLight =>
      _buildTheme(Brightness.dark, const Color(0xFF0A1628), const Color(0xBF0F1D35));

  static ThemeData _buildTheme(
    Brightness brightness,
    Color scaffoldBg,
    Color surfaceColor, [
    Color accent = primary,
  ]) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: textPrimary,
      primaryContainer: bgPanel,
      onPrimaryContainer: textPrimary,
      secondary: primaryGlow,
      onSecondary: textPrimary,
      surface: surfaceColor,
      onSurface: textPrimary,
      surfaceContainerLow: bgPanel,
      surfaceContainer: bgPanelLight,
      surfaceContainerHighest: const Color(0x801A2A40),
      error: const Color(0xFFFF4444),
      onError: Colors.white,
      outline: borderCyan,
      outlineVariant: glassBorder,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: Colors.transparent,
      dividerColor: glassBorder,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      iconTheme: IconThemeData(color: textSecondary, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgPanel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(panelRadius),
          borderSide: BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(panelRadius),
          borderSide: BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(panelRadius),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: hudBody(color: textSecondary, fontSize: 13),
        hintStyle: hudBody(color: textSecondary.withValues(alpha: 0.5), fontSize: 13),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary.withValues(alpha: 0.4);
          }
          return Colors.white24;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(panelRadius)),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: bgPanel,
          border: Border.all(color: borderCyan),
          borderRadius: BorderRadius.circular(panelRadius),
        ),
        textStyle: hudBody(fontSize: 12),
      ),
      textTheme: Typography.material2021().white.apply(fontFamily: 'MiSans'),
      primaryTextTheme: Typography.material2021().white.apply(fontFamily: 'MiSans'),
    );
  }
}
