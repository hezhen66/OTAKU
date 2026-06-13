import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/widgets/hud/hud_corner_painter.dart';
import 'package:flutter/material.dart';

/// 半透明面板 — 无 BackdropFilter，零闪烁
class FrostedGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final Color? glowColor;
  final bool hasCornerCuts;
  final bool showGlow;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const FrostedGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 4,
    this.borderColor,
    this.glowColor,
    this.hasCornerCuts = false,
    this.showGlow = false,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? AppTheme.cardBorder;
    final radius = BorderRadius.circular(borderRadius);

    Widget content = Padding(padding: padding, child: child);

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: AppTheme.primary.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: content,
      );
    }

    if (hasCornerCuts) {
      content = Stack(children: [
        content,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: HUDCornerPainter(
                color: AppTheme.borderCyan,
                cornerLength: AppTheme.cornerLength,
                strokeWidth: AppTheme.cornerStroke,
              ),
            ),
          ),
        ),
      ]);
    }

    Widget panel = Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.glassBg,
            borderRadius: radius,
            border: Border.all(color: effectiveBorder, width: 1),
            boxShadow: showGlow && glowColor != null
                ? [BoxShadow(color: glowColor!.withValues(alpha: 0.25), blurRadius: 10, spreadRadius: 1)]
                : null,
          ),
          child: content,
        ),
      ),
    );

    if (width != null || height != null) {
      return SizedBox(width: width, height: height, child: panel);
    }
    return panel;
  }
}
