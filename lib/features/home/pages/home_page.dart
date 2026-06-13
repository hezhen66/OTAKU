import 'package:astral/core/services/service_manager.dart';
import 'package:astral/core/models/room.dart';
import 'package:astral/shared/widgets/common/canvas_jump.dart';
import 'package:astral/shared/utils/dialogs/add_room_dialog.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

// ═══════════════════════════════════════════════════════════════
// 常量
// ═══════════════════════════════════════════════════════════════

const _cyan = Color(0xFF00E5FF);
const _dim = Color(0xFF5F7588);
const _cardBg = Color(0x660B141A);
const _cardBorder = Color(0x5900FFFF);

// ═══════════════════════════════════════════════════════════════
// 主页
// ═══════════════════════════════════════════════════════════════

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: 480,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ── 第一排：左右并列双卡片 ──────────
                Row(children: const [
                  Expanded(child: _BrowseRoomCard()),
                  SizedBox(width: 12),
                  Expanded(child: _CreateRoomCard()),
                ]),
                const SizedBox(height: 12),
                // ── 第二排：用户+网络 上下层面板 ────
                const _UserNetworkPanel(),
                const SizedBox(height: 24),
                // ── 第三排：游戏路径面板 ────────────
                const _GamePathPanel(),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(width: 3, height: 18, color: _cyan),
          const SizedBox(width: 10),
          const Text(
            'MULTIPLAYER LOBBY',
            style: TextStyle(
              fontFamily: 'Orbitron', fontSize: 13, color: _cyan,
              letterSpacing: 2, fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0x8800E5FF), Colors.transparent]),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        const Text('联机大厅', style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: _cyan,
          decoration: TextDecoration.none,
        )),
        const SizedBox(height: 4),
        const Text('选择或创建房间，开始联机游戏',
          style: TextStyle(fontSize: 12, color: _dim, decoration: TextDecoration.none)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 第一排左：CREATE ROOM 大卡片
// ═══════════════════════════════════════════════════════════════

class _CreateRoomCard extends StatefulWidget {
  const _CreateRoomCard();
  @override
  State<_CreateRoomCard> createState() => _CreateRoomCardState();
}

class _CreateRoomCardState extends State<_CreateRoomCard> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _h ? _cyan.withValues(alpha: 0.55) : _cardBorder;
    final bgColor = _h ? Colors.cyan.withOpacity(0.25) : Colors.cyan.withOpacity(0.12);
    final glow = _h
        ? [BoxShadow(color: _cyan.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1)]
        : null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: () => showAddRoomDialog(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 56,
          padding: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(4),
            boxShadow: glow,
          ),
          child: const Row(
            children: [
              Icon(Icons.add_circle_outline, size: 22, color: _cyan),
              SizedBox(width: 12),
              Text(
                'CREATE ROOM',
                style: TextStyle(
                  fontFamily: 'Orbitron', fontSize: 14,
                  fontWeight: FontWeight.bold, color: Colors.white,
                  letterSpacing: 2, decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 第一排右：当前房间卡片（动态房间名 + 门图标）
// ═══════════════════════════════════════════════════════════════

class _BrowseRoomCard extends StatefulWidget {
  const _BrowseRoomCard();
  @override
  State<_BrowseRoomCard> createState() => _BrowseRoomCardState();
}

class _BrowseRoomCardState extends State<_BrowseRoomCard> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final rooms = ServiceManager().roomState.rooms.watch(context);

      final borderColor = _h ? _cyan.withValues(alpha: 0.55) : _cardBorder;
      final bgColor = _h ? Colors.cyan.withOpacity(0.25) : Colors.cyan.withOpacity(0.12);
      final glow = _h
          ? [BoxShadow(color: _cyan.withValues(alpha: 0.2), blurRadius: 10, spreadRadius: 1)]
          : null;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _h = true),
        onExit: (_) => setState(() => _h = false),
        child: GestureDetector(
          onTap: () => CanvasJump.show(
            context,
            rooms: rooms.cast<Room>(),
            onSelect: (r) => ServiceManager().room.setRoom(r),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 56,
            padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: borderColor, width: 1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: glow,
            ),
            child: Row(children: [
              const Icon(Icons.meeting_room, size: 22, color: _cyan),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'BROWSE ROOM',
                  style: const TextStyle(
                    fontFamily: 'Orbitron', fontSize: 14,
                    fontWeight: FontWeight.bold, color: Colors.white,
                    letterSpacing: 2, decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ]),
          ),
        ),
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// 第二排：USER INFO 整体大面板
// ═══════════════════════════════════════════════════════════════

class _UserNetworkPanel extends StatelessWidget {
  const _UserNetworkPanel();

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final name = ServiceManager().playerState.playerName.watch(context);
      final ip = ServiceManager().networkConfigState.ipv4.watch(context);
      final dhcp = ServiceManager().networkConfigState.dhcp.watch(context);

      return Container(
        width: 480,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1E24).withOpacity(0.66),
          border: Border.all(color: _cardBorder, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ── 标题栏 ──────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(children: [
                  Container(width: 3, height: 14, color: _cyan),
                  const SizedBox(width: 8),
                  const Text('用户信息', style: TextStyle(
                    fontSize: 14, color: _cyan, fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  )),
                ]),
              ),
              // ── 用户名行 ────────────────────────
              _StackedRow(
                icon: Icons.person,
                label: '用户名',
                value: name,
                onTap: () => _showEditNameDialog(context, name),
              ),
              Container(height: 1, margin: const EdgeInsets.symmetric(horizontal: 20), color: _cyan.withValues(alpha: 0.15)),
              // ── 虚拟 IP 行 ──────────────────────
              _StackedRow(
                icon: Icons.lan,
                label: '虚拟 IP',
                value: ip,
                onTap: dhcp ? null : () => _showIpEditDialog(context, ip),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Switch(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      activeColor: _cyan,
                      value: dhcp,
                      onChanged: (v) => ServiceManager().networkConfig.updateDhcp(v),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(dhcp ? '自动' : '手动', style: const TextStyle(fontSize: 8, color: _dim)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ]),
      );
    });
  }
}

/// 上下双层错位行：图标 | 上层灰标签 + 下层白大字
class _StackedRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _StackedRow({
    required this.icon, required this.label, required this.value,
    this.onTap, this.trailing,
  });
  @override
  State<_StackedRow> createState() => _StackedRowState();
}

class _StackedRowState extends State<_StackedRow> {
  bool _h = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: _h ? _cyan.withValues(alpha: 0.04) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Icon(widget.icon, size: 26, color: _cyan),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.label, style: TextStyle(
                    fontSize: 11, color: Colors.grey.withValues(alpha: 0.8),
                    letterSpacing: 1.2, decoration: TextDecoration.none,
                  )),
                  const SizedBox(height: 4),
                  Text(widget.value, style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.bold,
                    color: Colors.white, decoration: TextDecoration.none,
                  ), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ]),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// 第三排：游戏路径面板 — 双状态 Hover 发光拐角
// ═══════════════════════════════════════════════════════════════

class _GamePathPanel extends StatefulWidget {
  const _GamePathPanel();
  @override
  State<_GamePathPanel> createState() => _GamePathPanelState();
}

class _GamePathPanelState extends State<_GamePathPanel> {
  String? _selectedGamePath;
  bool _hovering = false;

  String get _exeName {
    if (_selectedGamePath == null) return '';
    final parts = _selectedGamePath!.split(RegExp(r'[\\/]'));
    return parts.last;
  }

  Future<void> _pickGameExecutable() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['exe'],
    );
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) setState(() => _selectedGamePath = path);
    }
  }

  void _clearPath() => setState(() => _selectedGamePath = null);

  void _launchGame() async {
    if (_selectedGamePath == null) return;
    try {
      final exe = File(_selectedGamePath!);
      if (!exe.existsSync()) {
        if (mounted) _showSysSnack('所选文件不存在，请重新选择');
        return;
      }
      final proc = await Process.start(exe.path, [], workingDirectory: exe.parent.path);
      // 监控进程退出
      proc.exitCode.then((code) {
        if (code != 0 && mounted) {
          _showSysSnack('游戏进程异常退出 (code: $code)');
        }
      });
    } catch (e) {
      if (mounted) _showSysSnack('无法启动游戏: $e');
    }
  }

  void _showSysSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xE60A1622),
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.only(bottom: 600, left: 20, right: 20),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasPath = _selectedGamePath != null;
    const cornerColor = Colors.orangeAccent;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Container(
        width: 220, height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1E24).withOpacity(0.66),
          border: Border.all(color: cornerColor.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.zero,
          boxShadow: _hovering
              ? [BoxShadow(color: cornerColor.withValues(alpha: 0.08), blurRadius: 6)]
              : null,
        ),
        child: Stack(children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _CornerPainter(alpha: _hovering ? 0.15 : 0.0)),
            ),
          ),
          if (!hasPath)
            Positioned.fill(child: _buildEmpty())
          else
            Positioned.fill(child: _buildLoaded()),
        ]),
      ),
    );
  }

  /// 状态 A：未添加
  Widget _buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_circle_outline, size: 30, color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 6),
        const Text('SET GAME PATH', style: TextStyle(
          fontFamily: 'Orbitron', fontSize: 11, color: _dim,
          letterSpacing: 1.5, decoration: TextDecoration.none,
        )),
        const SizedBox(height: 14),
        _HoverButton(
          onTap: _pickGameExecutable,
          builder: (h) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: h ? Colors.orange.withOpacity(0.1) : Colors.transparent,
              border: Border.all(
                color: h ? Colors.orange : Colors.orange.withOpacity(0.5),
                width: 0.8,
              ),
              borderRadius: BorderRadius.zero,
            ),
            child: const Text('SELECT EXE', style: TextStyle(
              fontFamily: 'Orbitron', fontSize: 11, color: Colors.orange,
              letterSpacing: 2, fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            )),
          ),
        ),
      ],
    );
  }

  /// 状态 B：橘色战术面板
  Widget _buildLoaded() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        // 手柄图标
        const Icon(Icons.sports_esports, size: 32, color: Colors.orangeAccent),
        const SizedBox(height: 8),
        // exe 文件名
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _exeName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'monospace', fontSize: 11,
              color: Colors.white, decoration: TextDecoration.none,
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 底部双按钮
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Expanded(
              child: _HoverButton(
                onTap: _launchGame,
                builder: (h) => Container(
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: h ? Colors.orangeAccent.withOpacity(0.15) : Colors.transparent,
                    border: Border.all(
                      color: h ? Colors.orangeAccent : Colors.orangeAccent.withOpacity(0.5),
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.play_arrow, size: 14, color: Colors.orangeAccent),
                    SizedBox(width: 4),
                    Text('LAUNCH', style: TextStyle(
                      fontFamily: 'Orbitron', fontSize: 10,
                      fontWeight: FontWeight.bold, color: Colors.orangeAccent,
                      letterSpacing: 1, decoration: TextDecoration.none,
                    )),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _HoverButton(
                onTap: _clearPath,
                builder: (h) => Container(
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: h ? Colors.redAccent.withOpacity(0.15) : Colors.transparent,
                    border: Border.all(
                      color: h ? Colors.redAccent : Colors.redAccent.withOpacity(0.5),
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.close, size: 14, color: Colors.redAccent),
                    SizedBox(width: 4),
                    Text('CLEAR', style: TextStyle(
                      fontFamily: 'Orbitron', fontSize: 10,
                      fontWeight: FontWeight.bold, color: Colors.redAccent,
                      letterSpacing: 1, decoration: TextDecoration.none,
                    )),
                  ]),
                ),
              ),
            ),
          ]),
        ),
        const Spacer(),
      ],
    );
  }
}

/// Hover 按钮
class _HoverButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget Function(bool hovered) builder;
  const _HoverButton({required this.onTap, required this.builder});
  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool _h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => setState(() => _h = true),
    onExit: (_) => setState(() => _h = false),
    child: GestureDetector(onTap: widget.onTap, child: widget.builder(_h)),
  );
}

/// 四角发光拐角 Painter
class _CornerPainter extends CustomPainter {
  final double alpha; // 0 = 隐藏, >0 = 显示
  _CornerPainter({this.alpha = 0.0});
  @override
  void paint(Canvas canvas, Size size) {
    if (alpha <= 0) return;
    final p = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    const L = 10.0;
    const off = 4.0; // 向内偏移，不与边框对齐
    final w = size.width, h = size.height;
    for (final path in [
      Path()..moveTo(off, off + L)..lineTo(off, off)..lineTo(off + L, off),
      Path()..moveTo(w - off - L, off)..lineTo(w - off, off)..lineTo(w - off, off + L),
      Path()..moveTo(w - off, h - off - L)..lineTo(w - off, h - off)..lineTo(w - off - L, h - off),
      Path()..moveTo(off + L, h - off)..lineTo(off, h - off)..lineTo(off, h - off - L),
    ]) { canvas.drawPath(path, p); }
  }
  @override
  bool shouldRepaint(_CornerPainter old) => old.alpha != alpha;
}

// ═══════════════════════════════════════════════════════════════
// 弹窗：修改用户名
// ═══════════════════════════════════════════════════════════════

void _showEditNameDialog(BuildContext context, String name) {
  final c = TextEditingController(text: name);
  showDialog(
    context: context,
    builder: (ctx) => _HudDialog(
      title: '修改用户名',
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: OutlineInputBorder(borderSide: BorderSide(color: _cyan, width: 0.8)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _cyan, width: 0.8)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _cyan)),
        ),
      ),
      onConfirm: () {
        ServiceManager().appSettings.updatePlayerName(c.text);
        Navigator.pop(ctx);
      },
      onCancel: () => Navigator.pop(ctx),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// 弹窗：修改虚拟 IP
// ═══════════════════════════════════════════════════════════════

void _showIpEditDialog(BuildContext context, String ip) {
  final c = TextEditingController(text: ip);
  showDialog(
    context: context,
    builder: (ctx) => _HudDialog(
      title: '修改虚拟 IP',
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          border: OutlineInputBorder(borderSide: BorderSide(color: _cyan, width: 0.8)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _cyan, width: 0.8)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _cyan)),
        ),
      ),
      onConfirm: () {
        ServiceManager().networkConfig.updateIpv4(c.text);
        Navigator.pop(ctx);
      },
      onCancel: () => Navigator.pop(ctx),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// 通用 HUD Dialog + 文字按钮
// ═══════════════════════════════════════════════════════════════

class _HudDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  const _HudDialog({
    required this.title, required this.child,
    required this.onConfirm, required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: Center(
      child: Container(
        width: 320, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF0B141C).withValues(alpha: 0.95),
          border: Border.all(color: _cyan.withValues(alpha: 0.55), width: 1),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(title, style: const TextStyle(
            fontFamily: 'Orbitron', fontSize: 16, fontWeight: FontWeight.bold,
            color: Colors.white, decoration: TextDecoration.none,
          )),
          const SizedBox(height: 16),
          child,
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            _DialogTextBtn(label: 'CANCEL', onTap: onCancel),
            const SizedBox(width: 12),
            _DialogTextBtn(label: '确认', color: _cyan, onTap: onConfirm),
          ]),
        ]),
      ),
    ),
  );
}

class _DialogTextBtn extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _DialogTextBtn({required this.label, required this.onTap, this.color});

  @override
  State<_DialogTextBtn> createState() => _DialogTextBtnState();
}

class _DialogTextBtnState extends State<_DialogTextBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? Colors.white54;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? c.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(color: _hovered ? c : c.withValues(alpha: 0.4), width: 0.8),
          ),
          child: Text(widget.label, style: TextStyle(
            fontFamily: 'Orbitron', fontSize: 13,
            fontWeight: widget.color != null ? FontWeight.bold : FontWeight.w500,
            color: _hovered ? c : c.withValues(alpha: 0.8),
            letterSpacing: 1.5, decoration: TextDecoration.none,
          )),
        ),
      ),
    );
  }
}
