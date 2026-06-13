import 'package:astral/core/services/service_manager.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

const _textColor = Color(0xFFC2D2E2);
const _ringInactive = Color(0xFF3B4E61);
const _ringActive = Color(0xFF00D2FF);
const _cancelColor = Color(0xFF00E5FF);

Future<void> showBgPickerDialog(BuildContext context) async {
  await showDialog(
    context: context,
    barrierColor: const Color(0xFF0F141C).withValues(alpha: 0.25),
    builder: (_) => const _BgDialog(),
  );
}

class _BgDialog extends StatefulWidget {
  const _BgDialog();
  @override
  State<_BgDialog> createState() => _BgDialogState();
}

class _BgDialogState extends State<_BgDialog> {
  static const _builtin = [
    ('背景6', 'assets/backgrounds/bg_main.png'),
    ('背景', 'assets/backgrounds/bg_alt.png'),
  ];
  static const double _baseH = 260;
  static const double _perItem = 50;
  static const double _maxH = 350;

  String _current() => ServiceManager().uiState.backgroundAsset.value;
  List<String> _custom() => ServiceManager().uiState.customBackgrounds.value;
  void _select(String path) {
    ServiceManager().uiState.backgroundAsset.value = path;
    ServiceManager().uiState.saveBackgroundPath(path);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'webp', 'mp4', 'mov', 'webm', 'avi', 'mkv'], allowMultiple: false);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    if (!_custom().contains(path)) {
      final list = [..._custom(), path];
      ServiceManager().uiState.customBackgrounds.value = list;
      ServiceManager().uiState.saveBackgroundList(list);
    }
    _select(path);
  }

  void _removeCustom(String path) {
    final list = List<String>.from(_custom());
    list.remove(path);
    ServiceManager().uiState.customBackgrounds.value = list;
    ServiceManager().uiState.saveBackgroundList(list);
    if (_current() == path) _select(_builtin.first.$2);
  }

  double _height(int count) {
    final h = _baseH + count * _perItem;
    return h > _maxH ? _maxH : h;
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final current = ServiceManager().uiState.backgroundAsset.watch(context);
      final customs = ServiceManager().uiState.customBackgrounds.watch(context);
      final dialogH = _height(customs.length);
      final needsScroll = customs.length * _perItem > (_maxH - _baseH);

      return Center(
        child: Container(
          width: 380,
          height: dialogH,
          decoration: BoxDecoration(
            color: const Color(0xFF141D2A).withValues(alpha: 0.88),
            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.55), width: 1),
          ),
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: const Text('选择背景',
                    style: TextStyle(fontFamily: 'Orbitron', fontSize: 16,
                        fontWeight: FontWeight.bold, color: Colors.white,
                        decoration: TextDecoration.none)),
              ),
              Expanded(
                child: needsScroll
                    ? SingleChildScrollView(
                        child: _buildList(current, customs),
                      )
                    : _buildList(current, customs),
              ),
              const SizedBox(height: 8),
              const _CancelButton(),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildList(String current, List<String> customs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 所有背景 — 分割线上面
        ..._builtin.map((o) => _BgOption(
              label: o.$1, isCustom: false,
              isSelected: current == o.$2,
              onTap: () => _select(o.$2),
            )),
        ...customs.asMap().entries.map((e) => _BgOption(
              label: e.value.split(RegExp(r'[/\\]')).last,
              isCustom: true,
              isSelected: current == e.value,
              onTap: () => _select(e.value),
              onRemove: () => _removeCustom(e.value),
            )),
        const SizedBox(height: 4),
        Divider(color: const Color(0xFF1E2D3D).withValues(alpha: 0.5), thickness: 1, height: 1),
        const SizedBox(height: 8),
        // 添加按钮 — 分割线下面
        _AddCustomRow(onTap: _pickFile),
      ],
    );
  }
}

// ── 选项行 ────────────────────────────────────

class _BgOption extends StatefulWidget {
  final String label;
  final bool isCustom;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  const _BgOption({required this.label, this.isCustom = false,
    required this.isSelected, required this.onTap, this.onRemove});
  @override
  State<_BgOption> createState() => _BgOptionState();
}

class _BgOptionState extends State<_BgOption> {
  bool _hovered = false, _xHovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() { _hovered = false; _xHovered = false; }),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          color: _hovered ? const Color(0xFF17202E) : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(width: 16, height: 16,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  border: Border.all(color: widget.isSelected ? _ringActive : _ringInactive, width: 1.5)),
                child: widget.isSelected
                    ? const Center(child: SizedBox(width: 7, height: 7,
                        child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: _ringActive))))
                    : null),
              const SizedBox(width: 14),
              Expanded(child: Text(widget.label,
                  style: const TextStyle(fontFamily: 'Orbitron', fontSize: 14, color: Colors.white,
                      fontWeight: FontWeight.normal, letterSpacing: 1.5, decoration: TextDecoration.none),
                  overflow: TextOverflow.ellipsis)),
              if (widget.isCustom && widget.onRemove != null)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _xHovered = true),
                  onExit: (_) => setState(() => _xHovered = false),
                  child: GestureDetector(
                    onTap: widget.onRemove,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: _xHovered ? Colors.red.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.close_rounded, size: 14,
                          color: _xHovered ? Colors.redAccent : const Color(0xFF5F7588)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 添加自定义 ─────────────────────────────────

class _AddCustomRow extends StatefulWidget {
  final VoidCallback onTap;
  const _AddCustomRow({required this.onTap});
  @override
  State<_AddCustomRow> createState() => _AddCustomRowState();
}

class _AddCustomRowState extends State<_AddCustomRow> {
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
          duration: const Duration(milliseconds: 120),
          color: _hovered ? const Color(0xFF17202E) : Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            const Icon(Icons.add_photo_alternate_outlined, size: 18, color: Colors.white70),
            const SizedBox(width: 10),
            const Text('添加自定义图片...',
                style: TextStyle(fontFamily: 'Orbitron', fontSize: 14, color: Colors.white70,
                    letterSpacing: 0.5, decoration: TextDecoration.none)),
          ]),
        ),
      ),
    );
  }
}

// ── 取消按钮 ───────────────────────────────────

class _CancelButton extends StatefulWidget {
  const _CancelButton();
  @override
  State<_CancelButton> createState() => _CancelButtonState();
}

class _CancelButtonState extends State<_CancelButton> {
  bool _hovered = false, _pressed = false;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() { _hovered = false; _pressed = false; }),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) { setState(() => _pressed = false); Navigator.of(context).pop(); },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _pressed ? _cancelColor.withValues(alpha: 0.25)
                  : _hovered ? _cancelColor.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('取消',
                style: TextStyle(fontFamily: 'Orbitron', fontSize: 14, fontWeight: FontWeight.bold,
                    color: _cancelColor, decoration: TextDecoration.none)),
          ),
        ),
      ),
    );
  }
}
