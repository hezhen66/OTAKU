import 'package:astral/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// HUD 按钮变体
enum HUDButtonVariant {
  /// 标准操作：青色线框 + 发光（如 CREATE、JOIN）
  standard,

  /// 正向操作：亮绿（如 QUICK JOIN）
  success,

  /// 警告/配置：琥珀橙（如 SELECT EXE）
  warning,

  /// 危险操作：暗红（如 DEL）
  danger,
}

/// HUD 风格按钮 — 幽灵按钮 + 发光边框
///
/// 效果：透明/半透明底 + 1px 彩色边框 + BoxShadow 发光
/// 悬停：发光增强 + 轻微上浮
/// 点击：能量脉冲动画
class HUDButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final HUDButtonVariant variant;
  final double? width;
  final double height;
  final EdgeInsetsGeometry padding;
  final bool compact;

  const HUDButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = HUDButtonVariant.standard,
    this.width,
    this.height = 38,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.compact = false,
  });

  /// 快捷构造：文字按钮
  factory HUDButton.text(
    String label, {
    VoidCallback? onPressed,
    HUDButtonVariant variant = HUDButtonVariant.standard,
    double? width,
    bool compact = false,
    Key? key,
  }) {
    return HUDButton(
      key: key,
      onPressed: onPressed,
      variant: variant,
      width: width,
      compact: compact,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Orbitron',
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w600,
          letterSpacing: compact ? 1.5 : 2,
        ),
      ),
    );
  }

  @override
  State<HUDButton> createState() => _HUDButtonState();
}

class _HUDButtonState extends State<HUDButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  Color get _borderColor {
    switch (widget.variant) {
      case HUDButtonVariant.standard:
        return _isHovered ? AppTheme.primaryGlow : AppTheme.primary;
      case HUDButtonVariant.success:
        return _isHovered ? const Color(0xFF33FF88) : const Color(0xFF22CC66);
      case HUDButtonVariant.warning:
        return _isHovered ? const Color(0xFFFFAA33) : const Color(0xFFCC8800);
      case HUDButtonVariant.danger:
        return _isHovered ? const Color(0xFFFF6666) : const Color(0xFFCC3333);
    }
  }

  Color get _glowColor => _borderColor.withValues(alpha: 0.35);

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;
    final borderColor = disabled ? AppTheme.glassBorder : _borderColor;
    final glowColor = disabled ? Colors.transparent : _glowColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onPressed?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.compact ? widget.height - 6 : widget.height,
          transform: Matrix4.identity()
            ..translate(0.0, _isPressed ? 1.0 : (_isHovered ? -1.0 : 0.0), 0.0),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.primary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.panelRadius),
            border: Border.all(
              color: borderColor,
              width: _isHovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor,
                blurRadius: _isHovered ? 12 : 6,
                spreadRadius: _isHovered ? 2 : 1,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style: AppTheme.hudBody(color: AppTheme.textPrimary),
            textAlign: TextAlign.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
