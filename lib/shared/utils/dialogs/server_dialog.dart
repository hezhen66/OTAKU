import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/shared/widgets/hud/frosted_glass.dart';
import 'package:astral/shared/widgets/hud/hud_button.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/models/server_mod.dart';
import 'package:astral/shared/utils/network/blocked_servers.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';

Future<void> showAddServerDialog(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => ServerDialog(title: '添加服务器', confirmText: '添加'),
  );
}

Future<void> showEditServerDialog(
  BuildContext context, {
  required ServerMod server,
}) async {
  return showDialog(
    context: context,
    builder: (context) =>
        ServerDialog(title: '编辑服务器', confirmText: '保存', server: server),
  );
}

class ServerDialog extends StatefulWidget {
  final String title;
  final String confirmText;
  final ServerMod? server;

  const ServerDialog({
    super.key,
    required this.title,
    required this.confirmText,
    this.server,
  });

  @override
  State<ServerDialog> createState() => _ServerDialogState();
}

class _ServerDialogState extends State<ServerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  bool _tcp = true;
  bool _faketcp = false;
  bool _udp = true;
  bool _ws = false;
  bool _wss = false;
  bool _quic = false;
  bool _wg = false;
  bool _txt = false;
  bool _srv = false;
  bool _http = false;
  bool _https = false;

  @override
  void initState() {
    super.initState();
    if (widget.server != null) {
      _nameController.text = widget.server!.name;
      _urlController.text = widget.server!.url;
      _tcp = widget.server!.tcp;
      _faketcp = widget.server!.faketcp;
      _udp = widget.server!.udp;
      _ws = widget.server!.ws;
      _wss = widget.server!.wss;
      _quic = widget.server!.quic;
      _wg = widget.server!.wg;
      _txt = widget.server!.txt;
      _srv = widget.server!.srv;
      _http = widget.server!.http;
      _https = widget.server!.https;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _saveServer() {
    if (_formKey.currentState!.validate()) {
      final server = ServerMod(
        id: widget.server?.id ?? Isar.autoIncrement,
        enable: widget.server?.enable ?? false,
        name: _nameController.text,
        url: _urlController.text,
        tcp: _tcp,
        faketcp: _faketcp,
        udp: _udp,
        ws: _ws,
        wss: _wss,
        quic: _quic,
        wg: _wg,
        txt: _txt,
        srv: _srv,
        http: _http,
        https: _https,
      );

      if (widget.server == null) {
        ServiceManager().server.addServer(server);
      } else {
        ServiceManager().server.updateServer(server);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: FrostedGlassPanel(
        padding: const EdgeInsets.all(20),
        hasCornerCuts: true,
        showGlow: true,
        glowColor: AppTheme.primary,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title.toUpperCase(), style: AppTheme.hudTitle()),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '服务器名称',
                    hintText: '输入服务器名称',
                  ),
                  style: AppTheme.hudBody(),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '请输入服务器名称';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _urlController,
                  enabled: widget.server == null ||
                      !BlockedServers.isBlocked(widget.server!.url),
                  decoration: InputDecoration(
                    labelText: '服务器地址',
                    hintText: '输入服务器地址',
                    helperText: widget.server != null &&
                            BlockedServers.isBlocked(widget.server!.url)
                        ? '此服务器地址不可修改'
                        : null,
                  ),
                  style: AppTheme.hudBody(),
                  validator: (value) {
                    if (value == null || value.isEmpty) return '请输入服务器地址';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text('支持的协议:', style: AppTheme.hudBody()),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildProtocolSwitch('TCP', _tcp, (v) => setState(() => _tcp = v!)),
                    _buildProtocolSwitch('FAKETCP', _faketcp, (v) => setState(() => _faketcp = v!)),
                    _buildProtocolSwitch('UDP', _udp, (v) => setState(() => _udp = v!)),
                    _buildProtocolSwitch('WS', _ws, (v) => setState(() => _ws = v!)),
                    _buildProtocolSwitch('WSS', _wss, (v) => setState(() => _wss = v!)),
                    _buildProtocolSwitch('QUIC', _quic, (v) => setState(() => _quic = v!)),
                    _buildProtocolSwitch('WG', _wg, (v) => setState(() => _wg = v!)),
                    _buildProtocolSwitch('TXT', _txt, (v) => setState(() => _txt = v!)),
                    _buildProtocolSwitch('SRV', _srv, (v) => setState(() => _srv = v!)),
                    _buildProtocolSwitch('HTTP', _http, (v) => setState(() => _http = v!)),
                    _buildProtocolSwitch('HTTPS', _https, (v) => setState(() => _https = v!)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    HUDButton.text('CANCEL', compact: true,
                        onPressed: () => Navigator.of(context).pop()),
                    const SizedBox(width: 12),
                    HUDButton.text('SAVE', compact: true, onPressed: _saveServer),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildProtocolSwitch(String label, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: value, onChanged: onChanged),
        Text(label, style: AppTheme.hudBody(fontSize: 13)),
      ],
    );
  }
}
