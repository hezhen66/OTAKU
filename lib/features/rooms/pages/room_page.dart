import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/utils/ui/random_name.dart';
import 'package:astral/shared/utils/dialogs/add_room_dialog.dart';
import 'package:astral/shared/utils/dialogs/edit_room_dialog.dart';
import 'package:astral/shared/utils/data/room_share_helper.dart';
import 'package:astral/shared/widgets/cards/room_card.dart';
import 'package:astral/shared/widgets/common/room_reorder_sheet.dart';
import 'package:flutter/material.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/services/server_connection_manager.dart';
import 'package:astral/core/models/room.dart';
import 'package:uuid/uuid.dart';
import 'package:signals_flutter/signals_flutter.dart';

class RoomPage extends StatefulWidget { const RoomPage({super.key}); @override State<RoomPage> createState() => _RoomPageState(); }

class _RoomPageState extends State<RoomPage> {
  final _services = ServiceManager();

  void _showPasteDialog() {
    showDialog(context: context, barrierColor: const Color(0xFF0F141C).withValues(alpha: 0.25), builder: (ctx) {
      String shareCode = '';
      return Material(type: MaterialType.transparency, child: Dialog(backgroundColor: Colors.transparent, elevation: 0, child: Container(width: 400, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF141D2A).withValues(alpha: 0.88), border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.55), width: 1)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('导入房间', style: TextStyle(fontFamily: 'Orbitron', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.none)),
          const SizedBox(height: 16),
          TextField(onChanged: (v) => shareCode = v, decoration: const InputDecoration(hintText: '请输入分享码或链接', border: OutlineInputBorder()), style: const TextStyle(color: Colors.white), maxLines: 3),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () async { Navigator.of(ctx).pop(); await RoomShareHelper.importFromClipboard(context); }, icon: const Icon(Icons.paste), label: const Text('从剪贴板导入'))),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('取消')), const SizedBox(width: 8),
            TextButton(onPressed: () async { if (shareCode.isNotEmpty) { Navigator.of(ctx).pop(); await RoomShareHelper.importRoom(context, shareCode); } }, child: const Text('导入')),
          ]),
        ]),
      )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final isConnected = _services.connectionState.connectionState.watch(context);
      final selectedRoom = _services.roomState.selectedRoom.watch(context);
      final rooms = _services.roomState.rooms.watch(context);
      if (isConnected == CoState.idle) { _services.uiState.maxPlayers.value = 0; _services.uiState.connectingRoomId.value = null; }
      if (selectedRoom != null && isConnected == CoState.connected) {
        _services.uiState.maxPlayers.value = selectedRoom.maxPlayers;
        if (_services.uiState.connectingRoomId.value == null) {
          _services.uiState.connectingRoomId.value = selectedRoom.id;
        }
      }
      return Scaffold(backgroundColor: Colors.transparent,
        body: GestureDetector(
          onTap: () => _services.roomState.selectRoom(null),
          behavior: HitTestBehavior.translucent,
          child: LayoutBuilder(builder: (context, ct) {
                final big = ct.maxWidth >= 900;
                return Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: GridView.builder(cacheExtent: 500,
                    gridDelegate: big
                        ? const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 2.7)
                        : const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 180),
                    itemCount: rooms.length,
                    itemBuilder: (_, i) => _RoomListTile(key: ValueKey(rooms[i].id), room: rooms[i], isSelected: selectedRoom?.id == rooms[i].id,
                      onTap: () => _services.room.setRoom(rooms[i]),
                      onJoin: () async {
                        final rid = rooms[i].id;
                        final existing = _services.uiState.connectingRoomId.value;
                        final isConn = _services.connectionState.connectionState.value;
                        if (existing != null && isConn != CoState.connected && existing != rid) return;
                        _services.room.setRoom(rooms[i]);
                        _services.uiState.maxPlayers.value = rooms[i].maxPlayers;
                        _services.uiState.connectingRoomId.value = rid;
                        final ok = await ServerConnectionManager.instance.connect();
                        if (_services.uiState.connectingRoomId.value != rid) return;
                        if (ok != true && mounted) {
                          _services.uiState.connectingRoomId.value = null;
                          _showJoinError(context, ok, rooms[i].maxPlayers);
                        }
                      },
                      onEdit: () => showEditRoomDialog(context, room: rooms[i]),
                      onDelete: () => _services.room.deleteRoom(rooms[i].id),
                      onShare: () => RoomShareHelper.showShareDialog(context, rooms[i]),
                    ),
                  ),
                );
              })),
        floatingActionButton: AnimatedOpacity(
          opacity: isConnected != CoState.idle ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: IgnorePointer(ignoring: isConnected != CoState.idle, child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(heroTag: 'room_sort', onPressed: () => RoomReorderSheet.show(context, _services.roomState.rooms.value), child: const Icon(Icons.sort)),
          const SizedBox(width: 16),
          FloatingActionButton(heroTag: 'paste', onPressed: _showPasteDialog, child: const Icon(Icons.paste)),
          const SizedBox(width: 16),
          FloatingActionButton(heroTag: 'add', onPressed: () => showAddRoomDialog(context), child: const Icon(Icons.add)),
        ]))),
      );
    });
  }
}

class _RoomListTile extends StatefulWidget {
  final Room room; final bool isSelected; final VoidCallback onTap;
  final VoidCallback? onJoin; final VoidCallback? onEdit; final VoidCallback? onDelete; final VoidCallback? onShare;
  const _RoomListTile({super.key, required this.room, required this.isSelected, required this.onTap,
    this.onJoin, this.onEdit, this.onDelete, this.onShare});
  @override State<_RoomListTile> createState() => _RoomListTileState();
}

class _RoomListTileState extends State<_RoomListTile> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final bd = widget.isSelected ? const Color(0xFF00E5FF) : _h ? const Color(0xFF00E5FF).withValues(alpha: 0.5) : const Color(0xFF1E3A5A);
    final small = MediaQuery.of(context).size.width < 900;
    return MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false),
      child: GestureDetector(onTap: widget.onTap,
        child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF0A1622).withValues(alpha: 0.66), border: Border.all(color: bd, width: 0.8)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 3, height: 20, color: const Color(0xFF00E5FF)), const SizedBox(width: 10),
              Expanded(child: Text(widget.room.name, style: AppTheme.hudBody(fontSize: 16, color: Colors.white).copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (widget.onEdit != null) ...[ AnimatedOpacity(duration: const Duration(milliseconds: 150), opacity: _h ? 1.0 : 0.0, child: _EditIcon(t: widget.onEdit!)), const SizedBox(width: 6) ],
                Icon(Icons.people_outline, size: 14, color: AppTheme.textSecondary), const SizedBox(width: 4),
                Text('0/${widget.room.maxPlayers}', style: AppTheme.hudMono(color: AppTheme.textSecondary).copyWith(fontSize: 11)),
              ]),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const SizedBox(width: 13),
              Icon(widget.room.encrypted ? Icons.lock : Icons.lock_open, size: 14, color: widget.room.encrypted ? const Color(0xFFFFAA00) : AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(widget.room.encrypted ? 'SECURE' : 'PUBLIC', style: TextStyle(fontFamily: 'Orbitron', fontSize: 13, color: widget.room.encrypted ? const Color(0xFFFFAA00) : AppTheme.textSecondary, letterSpacing: 1.5, decoration: TextDecoration.none)),
            ]),
            const SizedBox(height: 16),
            Wrap(spacing: small ? 4 : 8, runSpacing: 4, children: [
              _JoinBtn(
                room: widget.room,
                isSelected: widget.isSelected,
                isConnected: ServiceManager().connectionState.connectionState.value == CoState.connected,
                onJoin: widget.onJoin ?? widget.onTap,
                onDisconnect: () async {
                  await ServerConnectionManager.instance.disconnect();
                },
                small: small,
              ),
              if (widget.onShare != null) _Btn(l: small ? '' : 'SHARE', i: Icons.share, t: widget.onShare!),
              if (widget.onDelete != null) _Btn(l: small ? '' : 'DEL', i: Icons.delete, t: widget.onDelete!, del: true),
            ]),
          ]),
        ),
      ),
    )
    ;
  }
}

class _Btn extends StatefulWidget {
  final String l; final IconData? i; final VoidCallback t; final bool del;
  const _Btn({required this.l, this.i, required this.t, this.del = false});
  @override State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    final c = widget.del ? const Color(0xFF5F7588).withValues(alpha: 0.65) : const Color(0xFF5F7588);
    final bd = widget.del ? const Color(0xFFCF6666) : const Color(0xFF00E5FF);
    final bg = widget.del ? const Color(0x187A2E2E) : const Color(0x1800E5FF);
    return MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false),
      child: GestureDetector(onTap: widget.t,
        child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(color: bg, border: Border.all(color: _h ? bd : bd.withValues(alpha: 0.65), width: 0.65)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.i != null) ...[ Icon(widget.i, size: 13, color: _h ? bd : c), const SizedBox(width: 5) ],
            Text(widget.l, style: TextStyle(fontFamily: 'Orbitron', fontSize: 13, fontWeight: FontWeight.w500, color: _h ? bd : c, letterSpacing: 1.5, decoration: TextDecoration.none)),
          ]),
        ),
      ),
    );
  }
}

class _EditIcon extends StatefulWidget {
  final VoidCallback t; const _EditIcon({required this.t});
  @override State<_EditIcon> createState() => _EditIconState();
}

class _EditIconState extends State<_EditIcon> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false),
      child: GestureDetector(onTap: widget.t,
        child: AnimatedContainer(duration: const Duration(milliseconds: 150), width: 28, height: 28,
          decoration: BoxDecoration(color: _h ? Colors.white10 : Colors.transparent, shape: BoxShape.circle),
          child: Icon(Icons.edit, size: 14, color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

void addEncryptedRoom(bool e, String? n, String? rn, String? pw, {int maxPlayers = 0, bool isLanMode = false}) {
  final room = Room(name: n ?? RandomName(), encrypted: e,
    roomName: e ? Uuid().v4() : (rn ?? ""), password: e ? Uuid().v4() : (pw ?? ""),
    messageKey: e ? Uuid().v4() : "", maxPlayers: maxPlayers, tags: []);
  room.isLanMode = isLanMode;
  ServiceManager().room.addRoom(room);
}

class _JoinBtn extends StatefulWidget {
  final Room room; final bool isSelected; final bool isConnected;
  final VoidCallback onJoin; final VoidCallback onDisconnect; final bool small;
  const _JoinBtn({required this.room, required this.isSelected, required this.isConnected,
    required this.onJoin, required this.onDisconnect, required this.small});
  @override State<_JoinBtn> createState() => _JoinBtnState();
}

class _JoinBtnState extends State<_JoinBtn> {
  bool _h = false;
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final connState = ServiceManager().connectionState.connectionState.watch(context);
      final connectingRoomId = ServiceManager().uiState.connectingRoomId.watch(context);
      final connecting = connectingRoomId == widget.room.id && connState != CoState.connected;
      final connected = connectingRoomId == widget.room.id && connState == CoState.connected;
      final label = _h && connected ? '断开连接'
          : connecting ? (widget.small ? '' : '加载中')
          : connected ? '已连接'
          : (widget.small ? '' : 'JOIN');
      final icon = _h && connected ? Icons.link_off
          : connecting ? null
          : connected ? Icons.link : Icons.login;
      final bd = (_h && connected) ? Colors.redAccent
          : connecting ? const Color(0xFF00E5FF)
          : (_h ? const Color(0xFF00E5FF) : const Color(0xFF00E5FF).withValues(alpha: 0.65));
      final textColor = (_h && connected) ? Colors.redAccent
          : connecting ? const Color(0xFF00E5FF)
          : (connected ? const Color(0xFF22CC66) : (_h ? const Color(0xFF00E5FF) : const Color(0xFF5F7588)));
      final bg = (_h && connected) ? Colors.red.withValues(alpha: 0.12)
          : (_h ? const Color(0x1800E5FF) : const Color(0x1800E5FF));
      return MouseRegion(cursor: SystemMouseCursors.click, onEnter: (_) => setState(() => _h = true), onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: connecting ? null : (_h && connected ? widget.onDisconnect : widget.onJoin),
          child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: bg, border: Border.all(color: bd, width: 0.65)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (connecting) ...[
                SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF00E5FF))),
                const SizedBox(width: 12),
              ] else ...[
                Icon(icon!, size: 13, color: textColor), const SizedBox(width: 5)
              ],
              Text(label, style: TextStyle(fontFamily: 'Orbitron', fontSize: 13, fontWeight: FontWeight.w500, color: textColor, letterSpacing: 1.5, decoration: TextDecoration.none)),
            ]),
          ),
        ),
      );
    });
  }
}

void _showJoinError(BuildContext context, bool? ok, int maxPlayers) {
  String msg;
  if (ok == null) {
    msg = '❌ 无法加入：该房间人数已满！';
  } else {
    msg = '⚠️ 网络错误：连接服务器超时，请检查网络后重试。';
  }
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white)),
    backgroundColor: const Color(0xE60A1622),
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(bottom: 600, left: 20, right: 20),
    duration: const Duration(seconds: 3),
  ));
}
