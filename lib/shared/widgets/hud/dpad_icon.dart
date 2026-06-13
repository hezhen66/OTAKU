import 'package:flutter/material.dart';

/// 纯代码十字键（D-Pad）图标 — 上下左右四块，中心十字空隙
class DPadIcon extends StatelessWidget {
  final Color color;
  final double size;

  const DPadIcon({super.key, required this.color, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 上
          Positioned(top: 0, child: Container(width: 7, height: 7, color: color)),
          // 下
          Positioned(bottom: 0, child: Container(width: 7, height: 7, color: color)),
          // 左
          Positioned(left: 0, child: Container(width: 7, height: 7, color: color)),
          // 右
          Positioned(right: 0, child: Container(width: 7, height: 7, color: color)),
        ],
      ),
    );
  }
}
