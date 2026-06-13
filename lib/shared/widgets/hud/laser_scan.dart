import 'package:flutter/material.dart';

/// 全屏横向激光扫描特效 — 宽幅霓虹光晕，慢速滑落
class LaserScanBackground extends StatefulWidget {
  final double speed;
  const LaserScanBackground({super.key, this.speed = 6.0});

  @override
  State<LaserScanBackground> createState() => _LaserScanBackgroundState();
}

class _LaserScanBackgroundState extends State<LaserScanBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.speed.toInt()),
    )..repeat();
    _anim = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return IgnorePointer(
          child: LayoutBuilder(builder: (context, constraints) {
            final h = constraints.maxHeight;
            final y = h * _anim.value - 35;
            return Stack(children: [
              Positioned(
                top: y,
                left: 0,
                right: 0,
                child: Container(
                  height: 70,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x0500F5FF),
                        Color(0x2200F5FF),
                        Color(0xAA00F5FF),
                        Color(0x2200F5FF),
                        Color(0x0500F5FF),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.25, 0.45, 0.5, 0.55, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
            ]);
          }),
        );
      },
    );
  }
}
