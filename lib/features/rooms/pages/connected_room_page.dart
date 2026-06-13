import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/services/server_connection_manager.dart';
import 'package:astral/core/models/room.dart';
import 'package:astral/features/home/pages/user_page.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ConnectedRoomPage extends StatelessWidget {
  const ConnectedRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final selectedRoom = ServiceManager().roomState.selectedRoom.watch(context);
      final isConnected = ServiceManager().connectionState.connectionState.watch(context);

      if (selectedRoom == null || isConnected != CoState.connected) {
        return Center(child: Text('未连接', style: AppTheme.hudBody(color: AppTheme.textSecondary).copyWith(decoration: TextDecoration.none)));
      }

      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(children: [
          _ConnectedBanner(room: selectedRoom),
          Expanded(child: Theme(data: Theme.of(context).copyWith(scaffoldBackgroundColor: Colors.transparent), child: const UserPage())),
        ]),
      );
    });
  }
}

class _ConnectedBanner extends StatefulWidget {
  final Room room;
  const _ConnectedBanner({required this.room});
  @override State<_ConnectedBanner> createState() => _ConnectedBannerState();
}

class _ConnectedBannerState extends State<_ConnectedBanner> {
  bool _hovered = false;

  void _disconnect() async {
    ServiceManager().uiState.connectingRoomId.value = null;
    await ServerConnectionManager.instance.disconnect();
    if (mounted) ServiceManager().uiState.selectedIndex.value = 2;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF030A10).withValues(alpha: 0.85),
          border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.55), width: 0.65),
        ),
        child: Row(children: [
          Text('当前房间: ${widget.room.name}', style: AppTheme.hudBody(color: Colors.white)),
          const Spacer(),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              onTap: _disconnect,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _hovered ? Colors.red.withValues(alpha: 0.12) : const Color(0xFF22CC66).withValues(alpha: 0.08),
                  border: Border.all(color: _hovered ? Colors.redAccent : const Color(0xFF22CC66), width: 0.65),
                ),
                child: Text(_hovered ? '断开连接' : '已连接',
                    style: TextStyle(fontFamily: 'Orbitron', fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _hovered ? Colors.redAccent : const Color(0xFF22CC66),
                        letterSpacing: 2, decoration: TextDecoration.none)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

