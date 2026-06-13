import 'package:astral/shared/theme/app_theme.dart';
import 'package:astral/core/services/service_manager.dart';
import 'package:astral/shared/utils/ui/random_name.dart';
import 'package:astral/features/rooms/pages/room_page.dart';
import 'package:flutter/material.dart';

const _cyan = Color(0xFF00E5FF);
const _bg = Color(0xFF0B141C);
const _dim = Color(0xFF5F7588);

Future<void> showAddRoomDialog(BuildContext context) async {
  bool isEncrypted = true;
  bool isLanMode = false;
  String? name = RandomName();
  String? roomNumber;
  String? roomPassword;
  int maxPlayers = 8;

  await showDialog(
    context: context,
    barrierColor: const Color(0xFF0F141C).withValues(alpha: 0.25),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          return Material(
            type: MaterialType.transparency,
            child: Center(
              child: _DialogBody(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 20),
                    _Label('ROOM NAME'),
                    const SizedBox(height: 6),
                    _DarkInput(
                      controller: TextEditingController(text: name),
                      hint: 'Enter room name',
                      onChange: (v) => name = v,
                    ),
                    const SizedBox(height: 20),
                    Row(children: [
                      _Label('MAX PLAYERS'),
                      const Spacer(),
                      Text('$maxPlayers / 16', style: AppTheme.hudMono(color: _cyan)),
                    ]),
                    const SizedBox(height: 8),
                    _PlayerGrid(selected: maxPlayers, onSelect: (v) => setState(() => maxPlayers = v)),
                    const SizedBox(height: 20),
                    _LanWanToggle(lanMode: isLanMode, onChanged: (v) => setState(() => isLanMode = v)),
                    const SizedBox(height: 20),
                    _SecurityToggle(encrypted: isEncrypted, onChanged: (v) => setState(() => isEncrypted = v)),
                    if (!isEncrypted) ...[
                      const SizedBox(height: 12),
                      _Label('ROOM ID'),
                      const SizedBox(height: 6),
                      _DarkInput(hint: '输入房间号...', onChange: (v) => roomNumber = v),
                      const SizedBox(height: 10),
                      _Label('PASSWORD'),
                      const SizedBox(height: 6),
                      _DarkInput(hint: '输入房间密码...', onChange: (v) => roomPassword = v),
                    ],
                    const SizedBox(height: 24),
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      _CancelBtn(onTap: () => Navigator.of(ctx).pop()),
                      const SizedBox(width: 16),
                      _CreateBtn(onTap: () {
                        ServiceManager().uiState.maxPlayers.value = maxPlayers;
                        addEncryptedRoom(isEncrypted, name ?? RandomName(),
                            roomNumber ?? "", roomPassword ?? "",
                            maxPlayers: maxPlayers, isLanMode: isLanMode);
                        Navigator.of(ctx).pop();
                      }),
                    ]),
                  ],
                ),
                onClose: () => Navigator.of(ctx).pop(),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildTitle() {
  return Row(mainAxisSize: MainAxisSize.min, children: [
    const SizedBox(width: 3, height: 18, child: ColoredBox(color: _cyan)),
    const SizedBox(width: 10),
    const Text('CREATE ROOM',
        style: TextStyle(fontFamily: 'Orbitron', fontSize: 18,
            fontWeight: FontWeight.bold, color: Color(0xFFCFD8DC),
            letterSpacing: 2, decoration: TextDecoration.none)),
  ]);
}

// ── 弹窗外壳 ──────────────────────────────────

class _DialogBody extends StatelessWidget {
  final Widget child;
  final VoidCallback onClose;
  const _DialogBody({required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 470,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: _bg.withValues(alpha: 0.88),
        border: Border.all(color: _cyan, width: 1.5),
      ),
      child: Stack(children: [
        child,
        Positioned(bottom: 0, right: 0,
            child: CustomPaint(size: const Size(12, 12), painter: _CornerBR())),
        Positioned(top: 0, right: 0, child: _CloseBtn(onTap: onClose)),
      ]),
    );
  }
}

// ── 组件 ──────────────────────────────────────

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'Orbitron', fontSize: 11,
          fontWeight: FontWeight.w500, color: _cyan,
          letterSpacing: 3, decoration: TextDecoration.none));
}

class _DarkInput extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String> onChange;
  const _DarkInput({this.controller, required this.hint, required this.onChange});
  @override
  State<_DarkInput> createState() => _DarkInputState();
}

class _DarkInputState extends State<_DarkInput> {
  late final TextEditingController _ctrl;
  @override
  void initState() { super.initState(); _ctrl = widget.controller ?? TextEditingController(); }
  @override
  void dispose() { if (widget.controller == null) _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        border: Border.all(color: _cyan.withValues(alpha: 0.15), width: 1),
      ),
      child: TextField(
        controller: _ctrl,
        style: const TextStyle(fontFamily: 'Orbitron', fontSize: 16,
            fontWeight: FontWeight.bold, color: Color(0xFFCFD8DC),
            decoration: TextDecoration.none),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(fontFamily: 'Orbitron', fontSize: 13, color: _dim),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        onChanged: widget.onChange,
      ),
    );
  }
}

// ── LAN/WAN ───────────────────────────────────

class _LanWanToggle extends StatelessWidget {
  final bool lanMode; final ValueChanged<bool> onChanged;
  const _LanWanToggle({required this.lanMode, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _ToggleBtn(label: '局域网', icon: Icons.wifi, active: lanMode,
          onTap: () => onChanged(true)),
      const SizedBox(width: 8),
      _ToggleBtn(label: '服务器', icon: Icons.dns, active: !lanMode,
          onTap: () => onChanged(false)),
    ]);
  }
}

class _ToggleBtn extends StatefulWidget {
  final String label; final IconData icon; final bool active; final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.icon, required this.active, required this.onTap});
  @override
  State<_ToggleBtn> createState() => _ToggleBtnState();
}

class _ToggleBtnState extends State<_ToggleBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.active
                ? const Color(0x990C1D28)
                : _hovered
                    ? _cyan.withValues(alpha: 0.08)
                    : Colors.transparent,
            border: Border.all(
                color: widget.active
                    ? _cyan.withValues(alpha: 0.65)
                    : _hovered
                        ? _cyan.withValues(alpha: 0.4)
                        : Colors.transparent,
                width: widget.active || _hovered ? 0.65 : 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, size: 14,
                color: widget.active ? _cyan : (_hovered ? _cyan : _dim)),
            const SizedBox(width: 6),
            Text(widget.label,
                style: TextStyle(fontFamily: 'Orbitron', fontSize: 11,
                    color: widget.active ? _cyan : (_hovered ? _cyan : _dim),
                    letterSpacing: 1.5, decoration: TextDecoration.none)),
          ]),
        ),
      ),
    );
  }
}

// ── SECURITY ──────────────────────────────────

class _SecurityToggle extends StatelessWidget {
  final bool encrypted; final ValueChanged<bool> onChanged;
  const _SecurityToggle({required this.encrypted, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _SecBtn(label: 'SECURE', icon: Icons.lock_outline, active: encrypted,
          onTap: () => onChanged(true)),
      const SizedBox(width: 8),
      _SecBtn(label: 'PUBLIC', icon: Icons.public_outlined, active: !encrypted,
          onTap: () => onChanged(false)),
    ]);
  }
}

class _SecBtn extends StatefulWidget {
  final String label; final IconData icon; final bool active; final VoidCallback onTap;
  const _SecBtn({required this.label, required this.icon, required this.active, required this.onTap});
  @override
  State<_SecBtn> createState() => _SecBtnState();
}

class _SecBtnState extends State<_SecBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: widget.active
                ? const Color(0x990C1D28)
                : _hovered
                    ? _cyan.withValues(alpha: 0.08)
                    : Colors.transparent,
            border: Border.all(
                color: widget.active
                    ? _cyan.withValues(alpha: 0.65)
                    : _hovered
                        ? _cyan.withValues(alpha: 0.4)
                        : Colors.transparent,
                width: widget.active || _hovered ? 0.65 : 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(widget.icon, size: 14,
                color: widget.active ? _cyan : (_hovered ? _cyan : _dim)),
            const SizedBox(width: 6),
            Text(widget.label,
                style: TextStyle(fontFamily: 'Orbitron', fontSize: 11,
                    color: widget.active ? _cyan : (_hovered ? _cyan : _dim),
                    letterSpacing: 1.5,
                    decoration: TextDecoration.none)),
          ]),
        ),
      ),
    );
  }
}

// ── 2×8 网格 ──────────────────────────────────

class _PlayerGrid extends StatelessWidget {
  final int selected; final ValueChanged<int> onSelect;
  const _PlayerGrid({required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 8, shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 1.6,
      children: List.generate(16, (i) {
        final n = i + 1;
        return _GridTile(n: n, sel: n <= selected, onTap: () => onSelect(n));
      }),
    );
  }
}

class _GridTile extends StatefulWidget {
  final int n; final bool sel; final VoidCallback onTap;
  const _GridTile({required this.n, required this.sel, required this.onTap});
  @override
  State<_GridTile> createState() => _GridTileState();
}

class _GridTileState extends State<_GridTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final sel = widget.sel;
    final bgColor = sel ? _cyan.withValues(alpha: 0.1)
        : _hovered ? _cyan.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.2);
    final border = sel ? Border.all(color: _cyan, width: 1.5)
        : _hovered ? Border.all(color: _cyan.withValues(alpha: 0.5), width: 1)
        : null;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(color: bgColor, border: border),
          alignment: Alignment.center,
          child: Text('${widget.n}',
              style: TextStyle(fontFamily: 'Orbitron', fontSize: 13,
                  fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                  color: sel ? Colors.white : _dim,
                  decoration: TextDecoration.none)),
        ),
      ),
    );
  }
}

// ── 按钮 ──────────────────────────────────────

class _CreateBtn extends StatefulWidget {
  final VoidCallback onTap; const _CreateBtn({required this.onTap});
  @override
  State<_CreateBtn> createState() => _CreateBtnState();
}

class _CreateBtnState extends State<_CreateBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? _cyan.withValues(alpha: 0.15) : const Color(0x1800E5FF),
            border: Border.all(
                color: _hovered ? _cyan : _cyan.withValues(alpha: 0.65),
                width: 0.65),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add_circle_outline, size: 16,
                color: _hovered ? _cyan : _dim),
            const SizedBox(width: 8),
            Text('CREATE ROOM',
                style: TextStyle(fontFamily: 'Orbitron', fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _hovered ? _cyan : _dim,
                    letterSpacing: 2, decoration: TextDecoration.none)),
          ]),
        ),
      ),
    );
  }
}

class _CancelBtn extends StatefulWidget {
  final VoidCallback onTap; const _CancelBtn({required this.onTap});
  @override
  State<_CancelBtn> createState() => _CancelBtnState();
}

class _CancelBtnState extends State<_CancelBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? _cyan.withValues(alpha: 0.15) : const Color(0x1800E5FF),
            border: Border.all(
                color: _hovered ? _cyan : _cyan.withValues(alpha: 0.65),
                width: 0.65),
          ),
          child: Text('CANCEL',
              style: TextStyle(fontFamily: 'Orbitron', fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _hovered ? _cyan : _dim,
                  letterSpacing: 2, decoration: TextDecoration.none)),
        ),
      ),
    );
  }
}

// ── 关闭 ──────────────────────────────────────

class _CloseBtn extends StatefulWidget {
  final VoidCallback onTap; const _CloseBtn({required this.onTap});
  @override
  State<_CloseBtn> createState() => _CloseBtnState();
}

class _CloseBtnState extends State<_CloseBtn> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: _hovered ? _cyan.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(
                color: _hovered ? _cyan : _cyan.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(Icons.close, size: 14, color: _hovered ? _cyan : _dim),
        ),
      ),
    );
  }
}

// ── Corner Painters ──────────────────────────

class _CornerBR extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = _cyan.withValues(alpha: 0.55)..style = PaintingStyle.stroke..strokeWidth = 1;
    canvas.drawPath(Path()..moveTo(0, size.height)..lineTo(size.width, size.height)..lineTo(size.width, 0), p);
  }
  @override bool shouldRepaint(_) => false;
}