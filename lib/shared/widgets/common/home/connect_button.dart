import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/widgets/hud/hud_button.dart';
import 'package:astral/core/models/room.dart';
import 'package:astral/core/models/server_mod.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/services/server_connection_manager.dart';
import 'package:astral/core/services/notification_service.dart';
import 'package:astral/core/services/vpn_manager.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:astral/generated/locale_keys.g.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectButton extends StatefulWidget {
  const ConnectButton({super.key});

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton>
    with SingleTickerProviderStateMixin {
  static const String _npcapTutorialUrl =
      'https://astral.fan/quick-start/download-install/';

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (Platform.isAndroid) {
      NotificationService.instance.initialize();
      VpnManager.instance.plugin?.onVpnServiceStarted.listen((data) {
        VpnManager.instance.configureTunFd(data['fd']);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ServiceManager().startupState.startupAutoConnect.value) {
        _handleConnect();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    final rom = ServiceManager().roomState.selectedRoom.value;
    if (rom == null) return;

    final enabledServers =
        ServiceManager().serverState.servers.value
            .where((server) => server.enable)
            .toList();
    final hasRoomServers = rom.servers.isNotEmpty;

    if (enabledServers.isEmpty && !hasRoomServers) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.add_server_first.tr()),
            action: SnackBarAction(
              label: LocaleKeys.go_add.tr(),
              onPressed: () {
                ServiceManager().uiState.selectedIndex.set(2);
              },
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (Platform.isWindows && _containsFaketcp(rom, enabledServers)) {
      final hasNpcap = await _hasNpcapDriver();
      if (!hasNpcap) {
        if (!mounted) return;
        final shouldOpenTutorial = await _showNpcapRequiredDialog();
        if (shouldOpenTutorial == true) {
          await _openNpcapTutorial();
        }
        return;
      }
    }

    final success = await ServerConnectionManager.instance.connect(isManual: true);
    if (success == false && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('连接失败'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  bool _containsFaketcp(Room room, List<ServerMod> enabledServers) {
    final roomHasFaketcp = room.servers.any(
      (url) => url.toLowerCase().trim().startsWith('faketcp://'),
    );
    final globalHasFaketcp = enabledServers.any(
      (server) =>
          server.faketcp == true ||
          server.url.toLowerCase().trim().startsWith('faketcp://'),
    );
    return roomHasFaketcp || globalHasFaketcp;
  }

  Future<bool> _hasNpcapDriver() async {
    final winDir = Platform.environment['WINDIR'] ?? r'C:\Windows';
    final candidates = <String>[
      '$winDir\\System32\\Npcap\\wpcap.dll',
      '$winDir\\SysWOW64\\Npcap\\wpcap.dll',
      '$winDir\\System32\\drivers\\npcap.sys',
      r'C:\Program Files\Npcap\NPFInstall.exe',
      r'C:\Program Files (x86)\Npcap\NPFInstall.exe',
    ];
    for (final path in candidates) {
      if (await File(path).exists()) return true;
    }
    for (final key in const [
      r'HKLM\SOFTWARE\Npcap',
      r'HKLM\SOFTWARE\WOW6432Node\Npcap',
    ]) {
      try {
        final result = await Process.run('reg', ['query', key]);
        if (result.exitCode == 0) return true;
      } catch (_) {}
    }
    for (final service in const ['npcap', 'npf']) {
      try {
        final result = await Process.run('sc', ['qc', service]);
        final output = '${result.stdout}\n${result.stderr}'.toLowerCase();
        if (result.exitCode == 0 &&
            (output.contains('npcap') ||
                output.contains(r'\npcap') ||
                output.contains('npcap packet driver'))) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  Future<bool?> _showNpcapRequiredDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('需要 Npcap 驱动'),
        content: const Text(
          '检测到当前连接包含 FakeTCP 服务器。\n'
          'Windows 需要先安装 Npcap 驱动后才能使用 FakeTCP。\n\n'
          '是否前往 astral.fan 查看安装教程？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('查看教程'),
          ),
        ],
      ),
    );
  }

  Future<void> _openNpcapTutorial() async {
    final uri = Uri.parse(_npcapTutorialUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法打开教程页面，请手动访问 astral.fan')),
      );
    }
  }

  Future<void> _handleDisconnect() async {
    await ServerConnectionManager.instance.disconnect();
  }

  Future<void> _toggleConnection() async {
    final state = ServiceManager().connectionState.connectionState.value;
    if (state == CoState.idle) {
      await _handleConnect();
    } else if (state == CoState.connecting) {
      await ServerConnectionManager.instance.cancelConnection();
    } else if (state == CoState.connected) {
      await _handleDisconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Watch((context) {
        final connectionState =
            ServiceManager().connectionState.connectionState.watch(context);

        if (connectionState == CoState.connecting) {
          if (!_animationController.isAnimating) {
            _animationController.repeat(reverse: true);
          }
        } else {
          if (_animationController.isAnimating) {
            _animationController.stop();
            _animationController.reset();
          }
        }

        final variant = connectionState == CoState.connected
            ? HUDButtonVariant.success
            : HUDButtonVariant.standard;
        final label = connectionState == CoState.idle
            ? 'CONNECT'
            : connectionState == CoState.connecting
                ? 'CANCEL'
                : 'DISCONNECT';

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 连接进度条
              if (connectionState == CoState.connecting)
                SizedBox(
                  height: 6,
                  width: 180,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 15),
                    curve: Curves.easeInOut,
                    builder: (context, value, _) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: AppTheme.bgPanel,
                        ),
                        child: FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryGlow],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              // 按钮
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: connectionState != CoState.idle ? 160 : 112,
                child: HUDButton(
                  onPressed: _toggleConnection,
                  variant: variant,
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (connectionState == CoState.connecting)
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _animationController.value * 2 * pi,
                              child: const Icon(Icons.close, size: 18),
                            );
                          },
                        )
                      else if (connectionState == CoState.connected)
                        const Icon(Icons.link, size: 18)
                      else
                        const Icon(Icons.power_settings_new, size: 18),
                      if (connectionState != CoState.idle) ...[
                        const SizedBox(width: 10),
                        Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
