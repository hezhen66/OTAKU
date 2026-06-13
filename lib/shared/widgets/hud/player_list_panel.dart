import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/widgets/hud/hud_toast.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/src/rust/api/p2p.dart' show broadcastKick;
import 'package:astral/core/states/connection_state.dart' show CoState, SystemEvent, SystemEventType;
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class PlayerListPanel extends StatelessWidget {
  const PlayerListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final netStatus = ServiceManager().connectionState.netStatus.watch(context);
      final connState = ServiceManager().connectionState.connectionState.watch(context);
      final maxPlayers = ServiceManager().uiState.maxPlayers.watch(context);
      final localIPv4 = ServiceManager().networkConfigState.ipv4.watch(context);
      final hostIndex = ServiceManager().uiState.hostIndex.watch(context);

      final isConnected = connState == CoState.connected;
      final allNodes = (isConnected && netStatus != null) ? netStatus.nodes : <dynamic>[];
      final nodes = allNodes.where((n) {
        final h = (n.hostname as String?) ?? '';
        final ip = (n.ipv4 as String?) ?? '';
        final ct = (n.connType as String?) ?? '';
        return !h.startsWith('PublicServer_') && ip != '0.0.0.0' && ct != 'server';
      }).toList();
      final currentCount = nodes.length;

      return Material(
        color: Colors.transparent,
        child: Container(
          width: AppTheme.rightPanelWidth,
          decoration: BoxDecoration(
            color: AppTheme.bgPanel,
            border: Border(left: BorderSide(color: AppTheme.subtleDivider, width: 1)),
          ),
          child: Column(children: [
            _buildHeader(currentCount, maxPlayers),
            Divider(color: AppTheme.subtleDivider, height: 1),
            Expanded(
              child: currentCount > 0
                  ? ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: currentCount,
                      itemBuilder: (ctx, i) => _PlayerTile(node: nodes[i], index: i, localIPv4: localIPv4, hostIndex: hostIndex),
                    )
                  : _buildEmptyState(),
            ),
            const SizedBox(height: 10),
            Divider(color: AppTheme.subtleDivider, height: 1),
            const SizedBox(height: 8),
            _buildBottomStatus(),
          ]),
        ),
      );
    });
  }

  Widget _buildBottomStatus() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _GreenDotSmall(),
        SizedBox(width: 8),
        Text('SERVER ONLINE', style: TextStyle(fontFamily: 'Orbitron', fontSize: 11,
            fontWeight: FontWeight.w500, color: AppTheme.textSecondary,
            letterSpacing: 1.5, decoration: TextDecoration.none)),
      ]),
    );
  }

  Widget _buildHeader(int current, int max) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 3, height: 16, decoration: BoxDecoration(
              color: const Color(0xFF00FFFF), borderRadius: BorderRadius.circular(2),
              boxShadow: [BoxShadow(color: const Color(0xFF00FFFF).withValues(alpha: 0.6), blurRadius: 4)])),
          const SizedBox(width: 8),
          Text('PLAYER', style: AppTheme.hudLabel()),
        ]),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(
              color: const Color(0xFF22CC66), shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF22CC66).withValues(alpha: 0.6), blurRadius: 4)])),
          const SizedBox(width: 6),
          Text('$current / $max', style: AppTheme.hudMono(
              color: current > 0 ? AppTheme.primaryGlow : AppTheme.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.people_outline, size: 40, color: AppTheme.textSecondary.withValues(alpha: 0.25)),
        const SizedBox(height: 12),
        Text('WAITING FOR', style: AppTheme.hudLabel()),
        Text('PLAYERS', style: AppTheme.hudLabel()),
      ]),
    );
  }

}

class _PlayerTile extends StatefulWidget {
  final dynamic node;
  final int index;
  final String localIPv4;
  final int hostIndex;
  const _PlayerTile({required this.node, required this.index, required this.localIPv4, required this.hostIndex});
  @override State<_PlayerTile> createState() => _PlayerTileState();
}

class _PlayerTileState extends State<_PlayerTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final hostname = (node.hostname as String?) ?? 'Unknown';
    final latencyMs = (node.latencyMs is double) ? node.latencyMs as double
        : (node.latencyMs is int) ? (node.latencyMs as int).toDouble() : 0.0;
    final connType = (node.connType as String?) ?? 'unknown';
    final ip = (node.ipv4 as String?) ?? '';
    final isHost = widget.index == widget.hostIndex;
    final isSelf = ip == widget.localIPv4;
    final hoverBg = _hovered ? const Color(0xFF00E5FF).withValues(alpha: 0.03) : Colors.transparent;

    return GestureDetector(
      onSecondaryTapUp: (d) => _showPlayerMenu(context, d.globalPosition, hostname, isHost, isSelf, widget.index, ip),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
              color: hoverBg,
              border: Border(bottom: BorderSide(color: AppTheme.subtleDivider))),
          child: Row(children: [
            _buildAvatar(hostname, node),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(hostname, style: AppTheme.hudBody(fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (isHost) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.workspace_premium, size: 14, color: const Color(0xFFFFCC00)),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(_statusLabel(connType), style: TextStyle(fontFamily: 'MiSans', fontSize: 10,
                    color: _statusColor(connType), letterSpacing: 0.5)),
              ]),
            ),
            const SizedBox(width: 6),
            Column(children: [
              Text('${latencyMs.toStringAsFixed(0)}ms',
                  style: AppTheme.hudMono(color: _latColor(latencyMs)).copyWith(fontSize: 10)),
              const SizedBox(height: 2),
              Icon(_connIcon(connType), color: _connColor(connType), size: 12),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, dynamic n) {
    const colors = [0xFF00D8FF, 0xFF31F0FF, 0xFF0088AA, 0xFF2244CC,
      0xFF33AA88, 0xFF6677CC, 0xFF22AA66, 0xFF8866CC, 0xFFCC6644, 0xFF4488AA];
    final bgColor = Color(colors[name.hashCode.abs() % colors.length]);
    final letter = name.isNotEmpty ? name.characters.first.toUpperCase() : '?';
    return Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: bgColor.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: bgColor.withValues(alpha: 0.7), width: 1)),
      child: Center(child: Text(letter, style: const TextStyle(fontFamily: 'Orbitron',
          fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary))),
    );
  }

  Color _latColor(double ms) {
    if (ms < 50) return const Color(0xFF22CC66);
    if (ms < 120) return const Color(0xFFCC8800);
    return const Color(0xFFCC3333);
  }

  String _statusLabel(String t) {
    switch (t.toLowerCase()) {
      case 'server': return '[在线]';
      case 'direct': return '[游戏中]';
      case 'relay': return '[等待中]';
      case 'local': return '[本地]';
      default: return '[在线]';
    }
  }

  Color _statusColor(String t) {
    switch (t.toLowerCase()) {
      case 'server': return const Color(0xFF22CC66);
      case 'direct': return const Color(0xFF00D8FF);
      case 'relay': return AppTheme.textSecondary;
      case 'local': return AppTheme.primaryGlow;
      default: return const Color(0xFF22CC66);
    }
  }

  IconData _connIcon(String t) {
    switch (t.toLowerCase()) {
      case 'server': return Icons.dns;
      case 'relay': return Icons.swap_horiz;
      case 'direct': return Icons.cable;
      case 'local': return Icons.home;
      default: return Icons.link;
    }
  }

  Color _connColor(String t) {
    switch (t.toLowerCase()) {
      case 'server': return const Color(0xFF22CC66);
      case 'relay': return const Color(0xFFCC8800);
      case 'direct': return AppTheme.primary;
      case 'local': return AppTheme.primaryGlow;
      default: return AppTheme.textSecondary;
    }
  }
}

class _GreenDotSmall extends StatelessWidget {
  const _GreenDotSmall();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6, height: 6,
      decoration: BoxDecoration(color: const Color(0xFF22CC66), shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: const Color(0xFF22CC66).withValues(alpha: 0.5), blurRadius: 3)]),
    );
  }
}

void _showPlayerMenu(BuildContext context, Offset pos, String hostname, bool isHost, bool isSelf, int index, String peerIp) {
  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 1, pos.dy + 1),
    color: const Color(0xFF0B141C),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    elevation: 8,
    items: [
      if (!isSelf)
        PopupMenuItem(height: 36, child: Row(children: [
          Icon(Icons.logout, size: 16, color: const Color(0xFFCC3333)),
          const SizedBox(width: 10),
          Text('踢出玩家', style: AppTheme.hudBody(fontSize: 13, color: const Color(0xFFCC3333))),
          const Spacer(),
          Text(hostname, style: AppTheme.hudBody(fontSize: 11, color: AppTheme.textSecondary)),
        ]), onTap: () {
          _showKickDialog(context, hostname, peerIp);
        }),
      if (isHost && !isSelf)
        PopupMenuItem(height: 36, child: Row(children: [
          Icon(Icons.swap_horiz, size: 16, color: AppTheme.primary),
          const SizedBox(width: 10),
          Text('转让房主', style: AppTheme.hudBody(fontSize: 13, color: AppTheme.primary)),
          const Spacer(),
          Text(hostname, style: AppTheme.hudBody(fontSize: 11, color: AppTheme.textSecondary)),
        ]), onTap: () {
          ServiceManager().uiState.hostIndex.value = index;
          HudToast.hostTransferred(context, hostname);
        }),
    ],
  );
}

void _showKickDialog(BuildContext context, String hostname, String peerIp) {
  String mode = 'kick';
  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => Material(
        type: MaterialType.transparency,
        child: Center(child: Container(width: 360, padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF0B141C).withValues(alpha: 0.95),
              border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.55), width: 1)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('踢出 $hostname', style: const TextStyle(fontFamily: 'Orbitron', fontSize: 16,
                fontWeight: FontWeight.bold, color: Colors.white, decoration: TextDecoration.none)),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: Text('仅踢出', style: AppTheme.hudBody(fontSize: 14, color: Colors.white)),
              subtitle: Text('允许重新加入', style: AppTheme.hudBody(fontSize: 11, color: AppTheme.textSecondary)),
              value: 'kick', groupValue: mode, activeColor: AppTheme.primary,
              onChanged: (v) => setState(() => mode = v!),
              tileColor: mode == 'kick' ? AppTheme.primary.withValues(alpha: 0.08) : null,
            ),
            RadioListTile<String>(
              title: Text('踢出并拉黑', style: AppTheme.hudBody(fontSize: 14, color: const Color(0xFFCC3333))),
              subtitle: Text('禁止再次加入', style: AppTheme.hudBody(fontSize: 11, color: AppTheme.textSecondary)),
              value: 'ban', groupValue: mode, activeColor: const Color(0xFFCC3333),
              onChanged: (v) => setState(() => mode = v!),
              tileColor: mode == 'ban' ? Colors.red.withValues(alpha: 0.08) : null,
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(onPressed: () => Navigator.pop(ctx),
                  child: Text('CANCEL', style: TextStyle(fontFamily: 'Orbitron', fontSize: 13, color: AppTheme.textSecondary))),
              const SizedBox(width: 12),
              TextButton(onPressed: () {
                Navigator.pop(ctx);
                debugPrint('踢出模式: $mode, 玩家: $hostname, IP: $peerIp');
                // 通过虚拟网发送踢人通知到目标 peer
                broadcastKick(targetIp: peerIp, peerName: hostname);
                HudToast.kicked(context, by: hostname);
              }, child: Text('确定', style: TextStyle(fontFamily: 'Orbitron', fontSize: 13,
                  fontWeight: FontWeight.bold, color: AppTheme.primary))),
            ]),
          ]),
        )),
      ),
    ),
  );
}
