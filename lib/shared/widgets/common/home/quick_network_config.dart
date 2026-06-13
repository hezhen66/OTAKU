import 'dart:io';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/widgets/common/home_box.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';

class QuickNetworkConfig extends StatelessWidget {
  const QuickNetworkConfig({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final services = ServiceManager();

    return Watch((context) {
      final disableP2p = services.networkConfigState.disableP2p.watch(context);
      final enableUdpBroadcastRelay = services
          .networkConfigState
          .enableUdpBroadcastRelay
          .watch(context);
      final firewallStatus = services.firewallState.firewallStatus.watch(
        context,
      );

      return HomeBox(
        widthSpan: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 3, height: 18, color: const Color(0xFF00E5FF)),
                const SizedBox(width: 8),
                const Text('快捷网络配置',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 10),

            // 强制中转开关
            _buildSwitchRow(
              icon: Icons.route, label: '强制中转',
              desc: '禁用P2P直连，所有流量经服务器中转',
              value: disableP2p,
              onChanged: (v) => services.networkConfig.updateDisableP2p(v),
            ),
            if (Platform.isWindows) ...[
              const SizedBox(height: 6),
              _buildSwitchRow(
                icon: Icons.settings_input_antenna, label: '广播转发',
                desc: 'Windows：将局域网 UDP 广播转发到虚拟网',
                value: enableUdpBroadcastRelay,
                onChanged: (v) => services.networkConfig.updateEnableUdpBroadcastRelay(v),
              ),
              const SizedBox(height: 6),
              _buildSwitchRow(
                icon: Icons.shield, label: LocaleKeys.firewall.tr(),
                desc: firewallStatus ? LocaleKeys.firewall_enabled.tr() : LocaleKeys.firewall_disabled.tr(),
                value: firewallStatus,
                onChanged: (v) => services.firewall.setFirewall(v),
              ),
            ],
          ],
        ),
      );
    });
  }
}

Widget _buildSwitchRow({
  required IconData icon, required String label, required String desc,
  required bool value, required ValueChanged<bool> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.15),
      border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2), width: 0.8),
    ),
    child: Row(children: [
      Icon(icon, size: 18, color: value ? const Color(0xFF00E5FF) : Colors.white38),
      const SizedBox(width: 10),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
          const SizedBox(height: 1),
          Text(desc, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.5))),
        ]),
      ),
      const SizedBox(width: 4),
      Switch(overlayColor: WidgetStateProperty.all(Colors.transparent), value: value, onChanged: onChanged),
    ]),
  );
}
