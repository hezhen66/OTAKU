import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/widgets/hud/frosted_glass.dart';
import 'package:astral/shared/widgets/hud/hud_button.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/models/room.dart';
import 'package:flutter/material.dart';

const _noBorder = InputDecoration(
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  filled: true,
  fillColor: AppTheme.bgPanelLight,
  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
);

const _textStyle = TextStyle(
  fontFamily: 'MiSans',
  fontSize: 14,
  color: AppTheme.textPrimary,
  decoration: TextDecoration.none,
);

Future<void> showEditRoomDialog(BuildContext context, {required Room room}) async {
  if (room.customParam.isNotEmpty) {
    showDialog(
      context: context,
      builder: (context) {
        return Material(
          type: MaterialType.transparency,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: FrostedGlassPanel(
              padding: const EdgeInsets.all(20),
              hasCornerCuts: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('无法编辑房间', style: AppTheme.hudBody(fontSize: 18)),
                  const SizedBox(height: 16),
                  Icon(Icons.lock, size: 48, color: AppTheme.primary),
                  const SizedBox(height: 16),
                  Text('此房间包含自定义服务器配置', style: AppTheme.hudBody()),
                  const SizedBox(height: 8),
                  Text('含有自定义参数的房间不可编辑，只能删除。',
                      style: AppTheme.hudBody(fontSize: 12, color: AppTheme.textSecondary),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  HUDButton.text('GOT IT', compact: true, onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
          ),
        );
      },
    );
    return;
  }

  final nameCtrl = TextEditingController(text: room.name);
  final roomNameCtrl = TextEditingController(text: room.roomName);
  final pwCtrl = TextEditingController(text: room.password);

  await showDialog(
    context: context,
    builder: (context) {
      return Material(
        type: MaterialType.transparency,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: SizedBox(width: 300,
            child: FrostedGlassPanel(
            padding: const EdgeInsets.all(20),
            hasCornerCuts: true,
            showGlow: true,
            glowColor: AppTheme.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('EDIT ROOM', style: AppTheme.hudTitle()),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: _noBorder.copyWith(labelText: '房间名称'),
                  style: _textStyle,
                ),
                const SizedBox(height: 12),
                Text('房间类型: ${room.encrypted ? "加密房间" : "普通房间"}',
                    style: AppTheme.hudBody(fontSize: 12, color: AppTheme.textSecondary)),
                if (!room.encrypted) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: roomNameCtrl,
                    decoration: _noBorder.copyWith(labelText: '房间号'),
                    style: _textStyle,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: pwCtrl,
                    decoration: _noBorder.copyWith(labelText: '房间密码'),
                    style: _textStyle,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    HUDButton.text('CANCEL', compact: true, onPressed: () {
                      Navigator.of(context).pop();
                    }),
                    const SizedBox(width: 12),
                    HUDButton.text('SAVE', compact: true, onPressed: () {
                      room.name = nameCtrl.text;
                      if (!room.encrypted) {
                        room.roomName = roomNameCtrl.text;
                        room.password = pwCtrl.text;
                      }
                      ServiceManager().room.updateRoom(room);
                      Navigator.of(context).pop();
                    }),
                  ],
                ),
              ],
            ),
            ),
          ),
        ),
      );
    },
  );
}
