import 'package:flutter/material.dart';

/// 统一的 HUD 提示弹窗 — 所有系统通知共用此格式
///
/// 后端接上后直接调用对应方法即可。
class HudToast {
  static const _bg = Color(0xE60A1622);
  static const _duration = Duration(seconds: 3);
  static const _margin = EdgeInsets.only(bottom: 600, left: 20, right: 20);

  /// 被踢出房间
  static void kicked(BuildContext context, {String? by}) {
    final who = (by != null && by.isNotEmpty) ? '被 $by ' : '你被';
    _show(context, '⚠️ ${who}踢出了房间', Colors.redAccent);
  }

  /// 房间已满
  static void roomFull(BuildContext context) {
    _show(context, '⚠️ 房间已满，无法加入', const Color(0xFFFFAA33));
  }

  /// 网络断开
  static void disconnected(BuildContext context) {
    _show(context, '⚠️ 网络连接已断开', Colors.redAccent);
  }

  /// 尝试重连
  static void reconnecting(BuildContext context) {
    _show(context, '⟳ 正在重新连接...', const Color(0xFF00D8FF));
  }

  /// 重连成功
  static void reconnected(BuildContext context) {
    _show(context, '✓ 已重新连接', const Color(0xFF22CC66));
  }

  /// 被房主转让
  static void hostTransferred(BuildContext context, String newHost) {
    _show(context, '👑 $newHost 已成为新房主', const Color(0xFFFFCC00));
  }

  static void _show(BuildContext context, String msg, Color accent) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Container(
            width: 3, height: 18,
            margin: const EdgeInsets.only(right: 10),
            color: accent,
          ),
          Expanded(
            child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ]),
        backgroundColor: _bg,
        duration: _duration,
        margin: _margin,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
