import 'package:flutter/material.dart';

/// 全屏下雪粒子特效（纯视觉，防挡点击）
class SnowEffect extends StatefulWidget {
  const SnowEffect({super.key});

  @override
  State<SnowEffect> createState() => _SnowEffectState();
}

class _SnowEffectState extends State<SnowEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          size: Size.infinite,
          painter: _SnowPainter(t: _ctrl.value),
        ),
      ),
    );
  }
}

class _SnowPainter extends CustomPainter {
  final double t;
  _SnowPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = _SeededRandom(42);
    // 绘制约 120 个雪点
    for (int i = 0; i < 126; i++) {
      final x = (rng.next() * size.width + (rng.next() - 0.5) * 40) % size.width;
      var y = (rng.next() * size.height + t * size.height) % size.height;
      // 漂移: 左右微摆
      final drift = sin((t * 3 + i * 0.7) * 2 * 3.14159) * 8;
      y = (y + drift) % size.height;
      if (y < 0) y += size.height;
      final radius = 1.0 + rng.next() * 1.5;
      final alpha = 0.15 + rng.next() * 0.35;
      final paint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_SnowPainter old) => old.t != t;
}

double sin(double x) {
  double r = 0;
  x = x % (2 * 3.141592653589793);
  double term = x;
  for (int n = 1; n < 10; n++) {
    r += term;
    term *= -x * x / ((2 * n) * (2 * n + 1));
  }
  return r;
}

class _SeededRandom {
  int _seed;
  _SeededRandom(this._seed);
  double next() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }
}
