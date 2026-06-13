import 'package:astral/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// HUD 风格字母头像
///
/// 取用户名首字母大写，圆形背景 + 1px 青色边框。
/// 颜色基于 hashCode 确定性分配，同一用户名永远同色。
class HUDAvatar extends StatelessWidget {
  final String username;
  final double size;

  const HUDAvatar({
    super.key,
    required this.username,
    this.size = 36,
  });

  // HUD 兼容色调色板
  static const _avatarColors = [
    0xFF00D8FF, // cyan
    0xFF31F0FF, // highlight
    0xFF0088AA, // dim cyan
    0xFF2244CC, // blue
    0xFF33AA88, // teal
    0xFF6677CC, // periwinkle
    0xFF22AA66, // green
    0xFF8866CC, // purple
    0xFFCC6644, // orange
    0xFF4488AA, // steel blue
  ];

  Color _getColor(String name) {
    if (name.isEmpty) return Color(_avatarColors[0]);
    final hash = name.hashCode;
    return Color(_avatarColors[hash.abs() % _avatarColors.length]);
  }

  String _getLetter(String name) {
    if (name.isEmpty) return '?';
    return name.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getColor(username);
    final letter = _getLetter(username);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        border: Border.all(
          color: bgColor.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: size * 0.42,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
