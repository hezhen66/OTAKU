import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/widgets/hud/frosted_glass.dart';
import 'package:astral/src/rust/api/simple.dart';
import 'package:astral/shared/utils/helpers/platform_version_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:signals_flutter/signals_flutter.dart';

class MiniUserCard extends StatefulWidget {
  final KVNodeInfo player;
  final ColorScheme colorScheme;
  final String? localIPv4;

  const MiniUserCard({
    super.key,
    required this.player,
    required this.colorScheme,
    required this.localIPv4,
  });

  @override
  State<MiniUserCard> createState() => _MiniUserCardState();
}

class _MiniUserCardState extends State<MiniUserCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final localIPv4 = ServiceManager().networkConfigState.ipv4.watch(context);

      final player = widget.player;
      final colorScheme = widget.colorScheme;
      final displayName = player.hostname.startsWith('PublicServer_')
          ? player.hostname.substring('PublicServer_'.length)
          : player.hostname;
      final connectionType = _mapConnectionType(player.cost, player.ipv4, localIPv4);
      final connectionTypeColor = _getConnectionTypeColor(connectionType, colorScheme);
      final latencyColor = _getLatencyColor(player.latencyMs);
      final lossColor = _getPacketLossColor(player.lossRate);
      final natDifficulty = _mapNatType(player.nat);
      final natDifficultyColor = _getNatTypeColor(natDifficulty);
      final natDifficultyIcon = _getNatTypeIcon(natDifficulty);

      return MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: FrostedGlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          borderColor: isHovered ? AppTheme.primary : AppTheme.glassBorder,
          showGlow: isHovered,
          glowColor: AppTheme.primary,
          borderRadius: AppTheme.panelRadius,
          onTap: () {
            Clipboard.setData(ClipboardData(text: player.ipv4));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已复制IP地址: ${player.ipv4}'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: AppTheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Tooltip(
                      message: displayName,
                      child: Text(
                        displayName,
                        style: AppTheme.hudBody(fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: connectionTypeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      connectionType,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  if (connectionType != '本机') ...[
                    const SizedBox(width: 10),
                    Icon(Icons.timer_outlined, size: 16, color: latencyColor),
                    Text(
                      '${player.latencyMs.toStringAsFixed(0)}ms',
                      style: TextStyle(
                        color: latencyColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.error_outline, size: 16, color: lossColor),
                    Text(
                      '${player.lossRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: lossColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  if (player.ipv4 != '' && player.ipv4 != "0.0.0.0")
                    Icon(Icons.lan_outlined, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Tooltip(
                      message: player.ipv4,
                      child: Text(
                        (player.ipv4 != '' && player.ipv4 != "0.0.0.0")
                            ? player.ipv4
                            : "",
                        style: AppTheme.hudBody(fontSize: 13, color: AppTheme.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    PlatformVersionParser.getPlatformIcon(player.version),
                    size: 16,
                    color: AppTheme.primary,
                  ),
                  Text(
                    PlatformVersionParser.getVersionNumber(player.version),
                    style: AppTheme.hudBody(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  if (connectionType != '本机' && player.nat.isNotEmpty) ...[
                    const SizedBox(width: 10),
                    Icon(natDifficultyIcon, size: 16, color: natDifficultyColor),
                    Text(
                      natDifficulty,
                      style: TextStyle(
                        color: natDifficultyColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                  if (player.tunnelProto != '') ...[
                    const SizedBox(width: 10),
                    Icon(Icons.router, size: 16, color: AppTheme.primary),
                    Text(
                      _formatTunnelProto(player.tunnelProto),
                      style: AppTheme.hudBody(fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── 以下静态辅助方法与原版完全相同 ──

String _mapNatType(String natType) {
  switch (natType) {
    case 'Unknown': return '未知';
    case 'OpenInternet': return '传奇';
    case 'NoPat': return '传奇';
    case 'FullCone': return '史诗';
    case 'Restricted': return '优质';
    case 'PortRestricted': return '优质';
    case 'Symmetric': return '困难';
    case 'SymUdpFirewall': return '普通';
    case 'SymmetricEasyInc': return '普通';
    case 'SymmetricEasyDec': return '普通';
    default: return '未知';
  }
}

IconData _getNatTypeIcon(String natType) {
  switch (natType) {
    case '传奇': return Icons.workspace_premium;
    case '史诗': return Icons.military_tech;
    case '优质': return Icons.verified;
    case '普通': return Icons.circle;
    case '困难': return Icons.block;
    default: return Icons.help_outline;
  }
}

Color _getNatTypeColor(String natType) {
  switch (natType) {
    case '传奇': return const Color(0xFFFF6B00);
    case '史诗': return const Color(0xFFA335EE);
    case '优质': return const Color(0xFF0070DD);
    case '普通': return const Color(0xFF1EFF00);
    case '困难': return const Color(0xFF9D9D9D);
    default: return Colors.grey;
  }
}

String _formatTunnelProto(String proto) {
  return proto.split(',').map((p) {
    final trimmed = p.trim();
    if (RegExp(r'^tcp$').hasMatch(trimmed)) return 'tcp4';
    if (RegExp(r'^udp$').hasMatch(trimmed)) return 'udp4';
    return trimmed;
  }).join(',');
}

Color _getConnectionTypeColor(String connectionType, ColorScheme colorScheme) {
  String lowerType = connectionType.toLowerCase();
  if (lowerType.contains('server') || lowerType.contains('服务器')) return Colors.deepPurple;
  if (lowerType.contains('p2p') || lowerType.contains('直链')) return Colors.green;
  if (lowerType.contains('relay') || lowerType.contains('中转')) return Colors.orange;
  if (lowerType.contains('direct') || lowerType.contains('本机')) return colorScheme.primary;
  return Colors.grey;
}

String _mapConnectionType(int connType, String ip, String thisip) {
  if (ip == "0.0.0.0") return '服务器';
  if (thisip.isNotEmpty && ip == thisip) return '本机';
  if (connType == 1) return '直链';
  if (connType >= 2) return '中转';
  return '未知';
}

Color _getLatencyColor(double latency) {
  if (latency < 50) return Colors.green;
  if (latency < 100) return Colors.orange;
  return Colors.red;
}

Color _getPacketLossColor(double lossRate) {
  if (lossRate < 1.0) return Colors.green;
  if (lossRate < 5.0) return Colors.orange;
  return Colors.red;
}
