import 'package:flutter/material.dart';

/// HUD 切角绘制器 — L 形直角护角
///
/// 在矩形面板四角绘制科技风 L 形直角线，
/// 模拟机甲控制台 / 全息 HUD 界面边框风格。
/// 纯 Flutter 代码实现，不使用 PNG 素材。
class HUDCornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  const HUDCornerPainter({
    this.color = const Color(0xAA00FFFF),
    this.cornerLength = 12.0,
    this.strokeWidth = 1.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    final w = size.width;
    final h = size.height;
    final L = cornerLength;

    // 绘制四个角的 L 形护角
    for (final path in [
      // 左上
      Path()
        ..moveTo(0, L)
        ..lineTo(0, 0)
        ..lineTo(L, 0),
      // 右上
      Path()
        ..moveTo(w - L, 0)
        ..lineTo(w, 0)
        ..lineTo(w, L),
      // 右下
      Path()
        ..moveTo(w, h - L)
        ..lineTo(w, h)
        ..lineTo(w - L, h),
      // 左下
      Path()
        ..moveTo(L, h)
        ..lineTo(0, h)
        ..lineTo(0, h - L),
    ]) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HUDCornerPainter old) =>
      old.color != color ||
      old.cornerLength != cornerLength ||
      old.strokeWidth != strokeWidth;
}
